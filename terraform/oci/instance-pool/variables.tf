variable "region" {
  type    = string
  default = "us-chicago-1"
}

variable "tenancy_ocid" {
  type        = string
  description = "value of the tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "value of the compartment OCID"
}

variable "config_file_profile" {
  type        = string
  description = "Name of the configure profile in ~/.oci/config"
  default     = "DEFAULT"
}

### VLZ ###

variable "vlz_refresh_token" {
  type        = string
  description = "VLZ Refresh Token"
}

variable "vlz_s3_path_to_conn" {
  type        = string
  description = "S3 Path to Connector"
  #example = "https://<bucket-name>.s3.amazonaws.com/connector/<folder-name>/ubuntu"
}

variable "vlz_rest_apigw" {
  type        = string
  description = "VLZ REST API Gateway"
  #example = https://<apigw-id>.execute-api.<region>.amazonaws.com/dev
}

### Media ###

variable "image_id" {
  type        = string
  description = "Image OCID"
  #default = "ocid1.image.oc1.iad.aaaaaaaah4rpzimrmnqfaxcm2xe3hdtegn4ukqje66rgouxakhvkaxer24oa"
  default = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
}

variable "num_of_instances" {
  type        = number
  description = "Number of instances to be created"
  default     = 1
}
