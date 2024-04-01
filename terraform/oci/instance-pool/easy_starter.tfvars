### Networking ###
region                 = "us-chicago-1"
ad_number              = 2
subnet_cidr_block_list = ["10.1.20.0/24", "10.1.21.0/24"]

### Credentials ###
tenancy_ocid        = ""
compartment_ocid    = ""
config_file_profile = "DEFAULT"

### VLZ ###
vlz_refresh_token   = ""
vlz_s3_path_to_conn = ""
vlz_rest_apigw      = ""

### Media ###
media_image_id         = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
media_num_of_instances = 4
media_shape            = "VM.DenseIO.E4.Flex"
media_num_of_ocpus     = 8
media_memory_in_gbs    = 128

### App ###
app_image_id         = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
app_num_of_instances = 1
app_shape            = "VM.Standard.E5.Flex"
app_num_of_ocpus     = 94
app_memory_in_gbs    = 128
