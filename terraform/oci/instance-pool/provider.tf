# provider "oci" {
#   tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
#   user_ocid = "ocid1.user.oc1..aaaaaaaaorw7kon5ty2mioqixqjl2ampifttqefph4fqtxeobu3ncpn3gfaa" 
#   private_key_path = "/Users/nk/.oci/oci.pem"
#   fingerprint = "03:e2:d5:5e:a8:52:de:25:01:fa:6a:35:35:ae:5d:db"
#   region = "us-chicago-1"
# }

provider "oci" {
  auth = "SecurityToken"
  config_file_profile = "DEFAULT"
  region = var.region
}
