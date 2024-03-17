locals {
  operator_template = "${path.module}/cloudinit/deploy_connector.template.yaml"
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