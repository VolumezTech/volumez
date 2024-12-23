### Networking ###
region                 = "us-phoenix-1"
ad_number              = 2
subnet_cidr_block_list = ["10.1.20.0/24", "10.1.21.0/24"] # 2 subnets
fault_domains          = ["FAULT-DOMAIN-1"]

### Credentials ###
tenancy_ocid        = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
compartment_ocid    = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
config_file_profile = "DEFAULT"

### VLZ ###
vlz_refresh_token   = ""
vlz_s3_path_to_conn = "https://signup.volumez.com/oci_poc_14/ubuntu"
vlz_rest_apigw      = "https://oci.api.volumez.com"

### Media ###
media_image_id            = "ocid1.image.oc1.phx.aaaaaaaajxeqzy3z5qwcwtksj76ymu5gxt24qbv22r7lzukux7dbfugdwyka"
media_num_of_instances    = 1
media_shape               = "BM.DenseIO.E4.128"
media_num_of_ocpus        = 8
media_memory_in_gbs       = 128
media_use_placement_group = false
media_ignore_cpu_mem_req  = true

### App ###
app_image_id            = "ocid1.image.oc1.phx.aaaaaaaajxeqzy3z5qwcwtksj76ymu5gxt24qbv22r7lzukux7dbfugdwyka"
app_num_of_instances    = 1
app_shape               = "BM.DenseIO.E4.128"
app_num_of_ocpus        = 8
app_memory_in_gbs       = 128
app_use_placement_group = false
app_ignore_cpu_mem_req  = true