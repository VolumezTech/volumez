### Networking ###
region                 = "us-phoenix-1"
ad_number              = 3
subnet_cidr_block_list = ["10.1.20.0/24"]
fault_domains          = ["FAULT-DOMAIN-1"]
 
### Credentials ###
tenancy_ocid        = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
compartment_ocid    = "ocid1.tenancy.oc1..aaaaaaaaij7gdgmcldaneftxyrhxiwpnaecvenjb42423cxhxmewlf65ca2q"
config_file_profile = "DEFAULT"
 
### VLZ ###
vlz_refresh_token   = "eIiwiYWxnIjoiUlNBLU9BRVAifQ.QPUWMqOmrJp_0riCEE_fweYM5d1oqN83IZjpubZt-BSV9dRC4ybraXiMmuog1Blb8F8gO14ybeCjGHxfl5me2xw2yOWSG3rDKHFrSI8e1GagqjctbdOXsJdBudsyhI46gXxmMYflY2_T9O_Y_eE-C6va9kK2G4kJbWCCj5Ndu3Gif6aoCdynI8AwvXQbGxjjl1t7op8IGZW0z4s-9XT734bJiez0YxqB3NXsnmxhVSyIjMQTQzMB-FlnBkQNJp1lxIA8Y9IDamz16mibMh6gYoG9X0pz5q7k2QN7wsiuO1wvzzErf3H_aEBUln9LtKPp8J5HnwV2sRMJSYQogJ2jd_6SCcjSqVczroARfpiGHry7uI9XkTYjuS3WHWS-SLTTBB_lg4WC2QWEoGq7iGpSFzmq55wX4PXFd-xgFVnjdMiWC1s0hE90H8pA7GynAWdKmY0wYQfocyNN0fbUvwcAd2bJvLZo922ADed3Cb-sm7vrNCTrNNjC6FPT4HYgYHJgQRnlmZIGdgJ4ok3P6MpT2tRFEKoRajnzkBFCgux_umtOjVdfRyUaDZ4EtlJ1-kFe0NcYwQq_FSsyV_G4oLElTkVFkjXfxwTGZS7ReuGgc7HBU0Ci5p0rM0WdO_4Src6eEymWjBUFWL9PuesQewFFI4vcdXpTLot0v82wWAHxicZElGrRIwAVdCUqad-Qm9lp46WdTfVgPUqcEtMiFGsNgMd4AmYUWDUxj7qachSSZc5ZZkAPUOfBQGVlMx102LIeDLVHtI-nV_-5QAcoxyeSz1gB7m2-jG1EACSxAXWgjs6H6WVNZmQiUcDKZvX0BPgcXZRhR7AEB7PdniomIhI-aBKGT_BWwS1eKjBMwJa9BfX76puxWxlZK0rXDIVG5-j5C4plVv-Gi5L_09T9lDG1-wFyqb7XZfZdAIovG77hdmo10j6ka_j-YvzDk5E5uByBuwOJAK8FerjHb75rlFo0XxPPpBAmWz0oUffg3XCknZUOQRVN-hAGJR2THIQDZ2x33ym_r6s07UqleXDiRlz9P3Af3PYxg23XdfHchM4qQc5Nl1Uspyhbfi-8loiSdArn2feY3Pgoh4fbzGqcF66iYPIher6SP2REAxlB5ZF6L5BRPFI_xq_Xg0fKNRi-BsiAsJlJpa6SJdXupbedFXD_vPFLWfGmRcphJ8MTlqKO4esWhNvOnyWQntLfSRNR2rd2xy-avmCoGMJodlK4GXKpTY33ONfQITNww0G8Cd4X4prWZNI4-L0F_Y_dabH-DqgWu4HCn8GvjGTmATpGF3Rg5FSuDDWcD0kAQipECKD-FfNLTrIam33W6xV0cPF7ClcvSGomD5791HI8qsoXsKQLNcSyZ75br7pZlk9A1rh8ioKH8p4CO_NXvW-3lb7utaAMY8JlsAAFHG2mG4h0F9dI3pEududfmWu7qiKpkoCwOrkfgNLdJ30YdqnvLKMkBKOWtGKAl3Gz7Iw9bKlyiw.JBSL0yYm4R9lu0uJ6IL0iQ"
vlz_s3_path_to_conn = "https://signup.volumez.com/oci_poc_14/ubuntu"
vlz_rest_apigw      = "https://oci.api.volumez.com"
 
### Media ###
#phx
#media_image_id            = "ocid1.image.oc1.phx.aaaaaaaaccib7h3sraiithx3imiqnxlf4vdld7s6unb7jc7fzpgesogtvkoa"
#media_image_id            = "ocid1.image.oc1.phx.aaaaaaaa2satrz5ifw3os6lxnzciwfdjiji5xu2jwprur77gcwvfgbsstika"
#media_image_id            = "ocid1.image.oc1.phx.aaaaaaaa6553ifuwu43cbpx462nettpz43luafhqjbm2o6u64ripvndzraca"
#media_image_id            = "ocid1.image.oc1.phx.aaaaaaaaq2ajmxjlud4gor7it26w2s26mdookgtcpkrzim66cb6cfougme2q"
#24.04
media_image_id            = "ocid1.image.oc1.phx.aaaaaaaa67rpopsmrc47xkucb7og73nufoqbtea26zolpjs7bdmxmkw7qwgq"
 
#iad
#media_image_id            = "ocid1.image.oc1.iad.aaaaaaaaccib7h3sraiithx3imiqnxlf4vdld7s6unb7jc7fzpgesogtvkoa"
media_num_of_instances    = 1
media_shape               = "VM.Standard.E5.Flex"
media_num_of_ocpus        = 1
media_memory_in_gbs       = 96
media_use_placement_group = false
media_ignore_cpu_mem_req  = false
 
### App ###
#phx
#app_image_id            = "ocid1.image.oc1.phx.aaaaaaaaccib7h3sraiithx3imiqnxlf4vdld7s6unb7jc7fzpgesogtvkoa"
#app_image_id            = "ocid1.image.oc1.phx.aaaaaaaa2satrz5ifw3os6lxnzciwfdjiji5xu2jwprur77gcwvfgbsstika"
#app_image_id            = "ocid1.image.oc1.phx.aaaaaaaa6553ifuwu43cbpx462nettpz43luafhqjbm2o6u64ripvndzraca"
#app_image_id            = "ocid1.image.oc1.phx.aaaaaaaaq2ajmxjlud4gor7it26w2s26mdookgtcpkrzim66cb6cfougme2q"
#24.04
app_image_id            = "ocid1.image.oc1.phx.aaaaaaaa67rpopsmrc47xkucb7og73nufoqbtea26zolpjs7bdmxmkw7qwgq"
#iad
#app_image_id            = "ocid1.image.oc1.iad.aaaaaaaaccib7h3sraiithx3imiqnxlf4vdld7s6unb7jc7fzpgesogtvkoa"
app_num_of_instances    = 1
app_shape               = "VM.Standard.E5.Flex"
app_num_of_ocpus        = 32
app_memory_in_gbs       = 64
app_use_placement_group = false
app_ignore_cpu_mem_req  = true