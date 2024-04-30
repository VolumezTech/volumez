locals {
  operator_template = "${path.module}/cloudinit/deploy_connector.template.yaml"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_number
}

data "cloudinit_config" "operator" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      local.operator_template, {
        operator_timezone   = "Asia/Jerusalem",
        vlz_refresh_token   = var.vlz_refresh_token,
        vlz_rest_apigw      = var.vlz_rest_apigw,
        vlz_s3_path_to_conn = var.vlz_s3_path_to_conn,
      }
    )
  }
}

### App Data ###
data "oci_core_instance_pool_instances" "app_pool" {
  depends_on = [oci_core_instance_pool.app_instance_pool]

  compartment_id   = var.tenancy_ocid
  instance_pool_id = oci_core_instance_pool.app_instance_pool.id
}

data "oci_core_instance" "app_instance" {
  instance_id = data.oci_core_instance_pool_instances.app_pool.instances[0].id
}

data "oci_core_vnic_attachments" "app_vnic2_attachments" {
  count = local.secondary_vnic_config

  compartment_id = var.tenancy_ocid
  instance_id    = data.oci_core_instance_pool_instances.app_pool.instances[0].id

  filter {
    name   = "subnet_id"
    values = [oci_core_subnet.vlz_subnet[1].id]
  }
}

#VNIC object by OCID
data "oci_core_vnic" "app_vnic2_id" {
  count = local.secondary_vnic_config

  vnic_id = lookup(data.oci_core_vnic_attachments.app_vnic2_attachments[count.index].vnic_attachments[0], "vnic_id")
}

data "oci_core_private_ips" "app_vnic2_ip" {
  count   = local.secondary_vnic_config
  vnic_id = data.oci_core_vnic.app_vnic2_id[count.index].id
}

### Media Data ###

data "oci_core_instance_pool_instances" "media_pool" {
  depends_on = [oci_core_instance_pool.media_instance_pool]

  for_each = oci_core_instance_pool.media_instance_pool

  compartment_id   = var.tenancy_ocid
  instance_pool_id = each.value.id
}

data "oci_core_instance" "media_instance" {
  for_each = { for k, v in data.oci_core_instance_pool_instances.media_pool : k => v.instances[0].id }

  instance_id = each.value
}
