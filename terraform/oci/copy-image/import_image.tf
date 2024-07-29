resource "null_resource" "import-image" {
  depends_on = [time_sleep.wait_60_seconds, null_resource.copy_objects]
  count = length(local.regions)

  triggers = {
    region_index = count.index
  }

  provisioner "local-exec" {
    command = <<EOF
      oci compute image import from-object --compartment-id ${var.compartment_id} -ns ${var.os_namespace} --bucket-name ${var.bucket_name}_${local.regions[count.index]} --name ${var.base_image_name} --region ${local.regions[count.index]} --display-name ${var.imported_image_name}
    EOF
  }
}
