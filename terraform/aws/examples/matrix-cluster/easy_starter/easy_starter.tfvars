# Volumez Matrix cluster — starter configuration
#
# Fill in allowed_ssh_cidrs (and optionally key_name), then:
#   terraform init
#   terraform apply -var-file=easy_starter.tfvars
# When it completes, send the `custom_ips_csv` output to Volumez.

# General
region                = "us-west-2"
target_az             = "a"
resources_name_prefix = "VolumezMatrix"

# Who may reach the nodes from outside (SSH / RDP / cluster UIs).
# Default: open to the whole internet (key-only SSH; fine for a short-lived
# test env). Narrow to your operators' network + the network Volumez
# connects from for anything longer-lived, e.g. ["203.0.113.7/32"].
allowed_ssh_cidrs = ["0.0.0.0/0"]

# IAM for HA floating IPs (VIPs): created automatically with the minimal
# EC2 permissions and attached to media + gateway nodes. Set to false and
# fill iam_instance_profile_name to bring your own role instead.
create_iam_instance_profile = true
iam_instance_profile_name   = ""

# Network (defaults match the layout the Matrix installation expects —
# coordinate with Volumez before changing the service network)
mgmt_vpc_cidr        = "10.0.0.0/16"
mgmt_subnet_cidr     = "10.0.80.0/24"
service_vpc_cidr     = "192.168.0.0/16"
service_subnet_cidr  = "192.168.100.0/24"
assign_public_ips    = true
create_bpa_exclusion = true
avoid_pg             = false

# Keys: leave empty to auto-generate a key pair
# (retrieve it later with: terraform output -raw ssh_private_key)
key_name = ""

# Media (DAOS storage) nodes — Rocky Linux 10 on NVMe instance-store types
media_node_count       = 5
media_node_type        = "r8idn.32xlarge"
media_node_ami         = "ami-07ae209e04e1dceaf" # Volumez Rocky 10 image (us-west-2, SSH user ec2-user); "default" = latest official Rocky 10 (SSH user rocky)
media_node_name_prefix = "media"
root_volume_size_gb    = 100

# Gateway nodes (optional)
gateway_node_count       = 0
gateway_node_type        = "i4i.4xlarge"
gateway_node_ami         = "ami-07ae209e04e1dceaf"
gateway_node_name_prefix = "gateway"

# Linux client (load generator) — RHEL 10, service IP 192.168.100.210
client_node_count       = 1
client_node_type        = "m6i.4xlarge"
client_node_ami         = "default" # latest official RHEL 10
client_node_name_prefix = "client"

# Active Directory Domain Controller (Windows Server 2022, mgmt network only)
enable_ad_dc = true
# REQUIRED when enable_ad_dc = true (RDP/WinRM login). Set it here or via the
# TF_VAR_ad_admin_password environment variable (a value set here overrides
# the environment variable):
# ad_admin_password = "..."
