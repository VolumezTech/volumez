### Networking ###
region                 = "us-phoenix-1"
ad_number              = 1
subnet_cidr_block_list = ["10.1.20.0/24"]
fault_domains          = ["FAULT-DOMAIN-1"]

### Credentials ###
tenancy_ocid        = ""
compartment_ocid    = ""
config_file_profile = "DEFAULT"

### VLZ ###
vlz_refresh_token   = ""
vlz_s3_path_to_conn = ""
vlz_rest_apigw      = ""

### Media ###
media_image_id            = "ocid1.image.oc1.phx.aaaaaaaajxeqzy3z5qwcwtksj76ymu5gxt24qbv22r7lzukux7dbfugdwyka"
media_num_of_instances    = 4
media_shape               = "VM.DenseIO.E4.Flex"
media_num_of_ocpus        = 8
media_memory_in_gbs       = 128
media_use_placement_group = false
media_ignore_cpu_mem_req  = false

### App ###
app_image_id            = "ocid1.image.oc1.phx.aaaaaaaajxeqzy3z5qwcwtksj76ymu5gxt24qbv22r7lzukux7dbfugdwyka"
app_num_of_instances    = 1
app_shape               = "VM.Standard.E5.Flex"
app_num_of_ocpus        = 8
app_memory_in_gbs       = 128
app_use_placement_group = false
app_ignore_cpu_mem_req  = false