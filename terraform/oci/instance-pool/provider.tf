terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "6.21.0" # Specify the desired version or version constraint here
    }
    
  }
}
provider "oci" {
  auth = "SecurityToken"
  config_file_profile = var.config_file_profile
  region = var.region
}
