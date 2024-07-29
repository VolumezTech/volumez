# Export the custom image to Object Storage
resource "null_resource" "export_image" {
  provisioner "local-exec" {
    command = "oci compute image export to-object --image-id ${var.custom_image_ocid} --bucket-name ${var.bucket_name}_${var.region} --region ${var.region} --namespace ${var.os_namespace} --name ${var.base_image_name}"
  }
}

resource "time_sleep" "wait_15_min" {
  depends_on = [null_resource.export_image]

  create_duration = "900s"
}
