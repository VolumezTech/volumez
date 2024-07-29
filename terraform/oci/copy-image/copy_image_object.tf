locals {
  regions = [
    "us-ashburn-1",
    # "us-phoenix-1",
    "eu-frankfurt-1",
    "uk-london-1",
    "us-chicago-1"
    // Add more regions as needed
  ]
}

resource "null_resource" "copy_objects" {
  count = length(local.regions)
  triggers = {
    region_index = count.index
  }
  provisioner "local-exec" {
    command = <<EOF
      oci os object copy --namespace ${var.os_namespace} --bucket-name ${var.bucket_name}_${var.region} --region ${var.region} --source-object-name ${var.base_image_name} --destination-namespace ${var.os_namespace} --destination-bucket ${var.bucket_name}_${local.regions[count.index]}  --destination-object-name ${var.base_image_name} --destination-region ${local.regions[count.index]} 
    EOF
  }
  depends_on = [ null_resource.export_image, time_sleep.wait_15_min ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.copy_objects]

  create_duration = "60s"
}
