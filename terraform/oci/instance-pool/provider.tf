terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "6.4.0" # Specify the desired version or version constraint here
    }
    
  }
}
provider "oci" {
  tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaa3bldyp5nfksjriezjrp25hfvsspqabpigd25bajgtkwmtzdu44a"
  user_ocid = "ocid1.user.oc1..aaaaaaaagwxkesqykgxvl6brrotmo6i5dqhveb2lo2di22huj76zrxtbgzkq" 
  private_key_path = "/Users/itayginor/.oci/oci_api_key.pem"
  fingerprint = "ce:cd:d6:b5:0c:53:c2:00:a9:f4:bc:85:de:83:8c:99"
  region = "uk-london-1"
}
