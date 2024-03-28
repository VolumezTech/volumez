resource "oci_core_security_list" "volumez-sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.test_vcn.id
  display_name   = "volumez-sl-${random_string.deploy_id.result}"

  ingress_security_rules {
    protocol  = "all"
    source    = "10.0.0.0/8"
    stateless = true
  }
}