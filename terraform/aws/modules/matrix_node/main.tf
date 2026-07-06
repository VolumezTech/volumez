# Matrix cluster node group: one EC2 instance per node with two NICs.
#
# - eth0: management subnet (SSH, internet). source_dest_check is disabled on
#   the instance because Pacemaker floating VIPs move IPs that AWS would
#   otherwise drop.
# - eth1: service subnet with a STATIC IP — cidrhost(service_subnet_cidr,
#   service_ip_start + index). The install expects media nodes to start at .4
#   (AWS reserves .0-.3) and gateway nodes at .50, in order.
#
# The hostname is pinned via cloud-init (preserve_hostname) — it flows into
# the cluster configuration, so it must be stable across reboots.

resource "aws_instance" "node" {
  count = var.num_of_nodes

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.mgmt_subnet_id
  vpc_security_group_ids      = [var.mgmt_sg_id]
  associate_public_ip_address = var.assign_public_ip
  placement_group             = var.placement_group_name != "" ? var.placement_group_name : null
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  # Pacemaker floating VIPs: AWS drops traffic to IPs not assigned to an ENI
  # unless the source/destination check is off.
  source_dest_check = false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    delete_on_termination = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # First-boot configuration:
  # - Pin the hostname (via runcmd — cloud-init's own set_hostname module is
  #   disabled by preserve_hostname, which we want so nothing overwrites it
  #   on later boots).
  # - Switch to classic NIC naming (eth0/eth1) — the Matrix installation
  #   expects the service interface to be literally eth1, while stock cloud
  #   images use predictable names (ens5/ens6). Requires one reboot, which
  #   cloud-init performs automatically at the end of the first boot.
  user_data                   = <<-EOF
    #cloud-config
    preserve_hostname: true
    runcmd:
      - hostnamectl set-hostname ${var.hostname_prefix}-${count.index}
      - |
        # Expand an LVM root to fill the EBS volume — cloud-init growpart only
        # handles plain-partition roots, so LVM-based images boot with the
        # image's original root size. No-op when the root is not LVM.
        ROOT_SRC=$(findmnt -n -o SOURCE /)
        case "$ROOT_SRC" in
        /dev/mapper/*)
          VG=$(lvs --noheadings -o vg_name "$ROOT_SRC" 2>/dev/null | tr -d ' ')
          PV=$(pvs --noheadings -o pv_name -S vg_name="$VG" 2>/dev/null | tr -d ' ')
          if [ -n "$PV" ]; then
            DISK="$${PV%p[0-9]*}"
            PART="$${PV##*p}"
            growpart "$DISK" "$PART" || true
            pvresize "$PV" || true
            lvextend -l +100%FREE "$ROOT_SRC" || true
            xfs_growfs / || resize2fs "$ROOT_SRC" || true
          fi
          ;;
        esac
      - grubby --update-kernel=ALL --args="net.ifnames=0 biosdevname=0"
      - sed -i 's/^interface-name=.*/interface-name=eth0/' /etc/NetworkManager/system-connections/*.nmconnection || true
    power_state:
      mode: reboot
      message: cloud-init applying classic NIC naming (eth0/eth1)
  EOF
  user_data_replace_on_change = true

  tags = {
    Name      = "${var.hostname_prefix}-${count.index}"
    Terraform = "true"
  }
}

# eth1 — service network interface with the static cluster IP
resource "aws_network_interface" "service" {
  count = var.num_of_nodes

  subnet_id         = var.service_subnet_id
  security_groups   = [var.service_sg_id]
  source_dest_check = false
  private_ips       = [cidrhost(var.service_subnet_cidr, var.service_ip_start + count.index)]

  tags = {
    Name      = "${var.hostname_prefix}-${count.index}-service-nic"
    Terraform = "true"
  }
}

resource "aws_network_interface_attachment" "service" {
  count = var.num_of_nodes

  instance_id          = aws_instance.node[count.index].id
  network_interface_id = aws_network_interface.service[count.index].id
  device_index         = 1
}
