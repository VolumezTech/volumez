variable "region" {
  type    = string
  default = "us-chicago-1"
}

variable "ad_number" {
  type        = number
  description = "Availability Domain Number"
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

variable "media_image_id" {
  type        = string
  description = "Image OCID"
  #default = "ocid1.image.oc1.iad.aaaaaaaah4rpzimrmnqfaxcm2xe3hdtegn4ukqje66rgouxakhvkaxer24oa"
  default = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
}

variable "media_shape" {
  type        = string
  description = "Media Shape"
  default     = "VM.DenseIO.E4.Flex"
}

variable "media_memory_in_gbs" {
  type        = number
  description = "Memory in GBs"
  default     = 128
}

variable "media_num_of_ocpus" {
  type        = number
  description = "Memory in GBs"
  default     = 8
}

variable "media_num_of_instances" {
  type        = number
  description = "Number of instances to be created"
}

### App ###

variable "app_image_id" {
  type        = string
  description = "Image OCID"
  #default = "ocid1.image.oc1.iad.aaaaaaaah4rpzimrmnqfaxcm2xe3hdtegn4ukqje66rgouxakhvkaxer24oa"
  default = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
}

variable "app_shape" {
  type        = string
  description = "Media Shape"
  default     = "VM.DenseIO.E4.Flex"
}

variable "app_memory_in_gbs" {
  type        = number
  description = "Memory in GBs"
  default     = 128
}

variable "app_num_of_ocpus" {
  type        = number
  description = "Memory in GBs"
  default     = 8
}

variable "app_num_of_instances" {
  type        = number
  description = "Number of instances to be created"
}