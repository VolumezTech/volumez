# provider "oci" {
#   tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
#   user_ocid = "ocid1.user.oc1..aaaaaaaaizylfczn2ngerzxi5oef7obvlju6i3uhwywpvyfuzeheejrw3tea" 
#   private_key_path = "/Users/sharonkurelovsky/.oci/oci.pem"
#   fingerprint = "4b:ea:50:95:89:c2:8c:b2:79:98:77:74:f7:21:cc:a1"
#   region = "us-ashburn-1"
# }

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "6.4.0" # Specify the desired version or version constraint here
    }
    
  }
}
provider "oci" {
  auth = "SecurityToken"
  config_file_profile = var.config_file_profile
  region = var.region
}
