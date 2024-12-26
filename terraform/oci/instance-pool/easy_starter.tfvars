### Networking ###
region                 = "us-ashburn-1"
ad_number              = 2
subnet_cidr_block_list = ["10.1.20.0/24", "10.1.21.0/24"] # 2 subnets
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
media_image_id             = "ocid1.image.oc1.iad.aaaaaaaac3eshnn5mcmwpwnvy76lnb5wzzlr2dew4ilbb5gfealimrostriq"
media_num_of_instances     = 2
media_shape                = "BM.Standard3.64"
media_num_of_ocpus         = 8
media_memory_in_gbs        = 128
media_use_placement_group  = false
media_ignore_cpu_mem_req   = true
media_secondary_vnic_index = 1


### App ###
app_image_id             = "ocid1.image.oc1.iad.aaaaaaaac3eshnn5mcmwpwnvy76lnb5wzzlr2dew4ilbb5gfealimrostriq"
app_num_of_instances     = 2
app_shape                = "BM.Standard3.64"
app_num_of_ocpus         = 8
app_memory_in_gbs        = 128
app_use_placement_group  = false
app_ignore_cpu_mem_req   = true
app_secondary_vnic_index = 1 
