variable "region" { 
  type = string
  default = "us-chicago-1"  
}

variable "tenancy_ocid" {
  type = string
  description = "value of the tenancy OCID"
}

variable "compartment_ocid" {
  type = string
  description = "value of the compartment OCID"
}

### VLZ ###

variable "vlz_refresh_token" {
  type = string
  description = "VLZ Refresh Token"
  default = "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.Po6w0NTW8U99CTX4iP3tAkbMD0uoJunkSBwR-gC88DhPOJdhiczbNWJEPkk57LBqmgDZBliGtwe2nhjmERcZ_j29SJ5l0-WHyXbJhdBrk-mIfWaLZC0woaolc8TrPzPTyfyoMpqHLNICwb9c4B6l4CjbjBLkhVaGMAvb026a2fqAI4ROxPiwdQrM8jkzEcQySlkAXbmkLQPZCgp-Oxj9OCBVnpa2WzLewEOgbNnmGN_MxM_40wFsi7zCKlhB0jtsJowYnxOHD1x5-aPdTDnwYayMiGRIrXqFfTuidjn4vKnNNb2gqGc7PGPqe0cMnLikrwdT4GmStCuyzaEUBpdfzg.HC1tw_ZqXxecHWc_.XDZR1NRIieWcf2l3Gd8rOosPUamXQl0sEyys3cTAmd6haoxKKFj-sA3Uot2Ji2euXr-81WnCXhamstTSM5RyECduYWRz5d13893FMmQbLQ1XKkKw6wlvK3RuOuLioRIHYPBCzhVNddwT9Uz35Wrn4K9sYW_FLAD-1_jRhteI_z5Ii0-9iDONYBvldKczF-jyUCy73VvIYT24PWhfWG3FyHBnd7r5zH1iUjc5LvsuAjBItY0HeqVzXGLqwHuqcO6FjbeZJ8Yubph_QCyWl-xiPj8L7M1o1FAJwmxPDwj1iMhz4P90O4O3AxIhpJ2DnC2-65xvVXJ-vDuRwJENtpCT2lbLFfSOlZChsEECT6DH7n0K0sPBmQID2ei4rC_8-5Z72nU0e-1p2A4Lt0fofOlNiyjRzrzTK-RA7XdpI6dEYDswNzLzRs7CRDTHV7tpTrq80DCMz-peg-6OCmG-OyEE56zKsy05yK1qvqbRrqzNJvQLIXWi3PSBsH5GgK5CX-r9lFfOrf1d-xmCfL6tJlNDOcDjFUNZJM-HpyR6rEkO3eqTHTEibXGaWXHVo8IeZxnlH2o5VPR94RA78qYAXhd3X7IfnZJmziECMhD7BJdGy_Lx2ytaJIka3gaKMaFfEAROrpPDDE-hRGXA5AuLbny1Pj0K1fZb832Kil4fpPTXvhYDK9B60ftBZSib0IBPBKC-9niaYum4rZ87ExdLldvqCddDVXEEnAoegz9tqV9FPv-jz8jlnDw3x6hVPlpuMt34-upIUS-K87WKcGfhcbeXkFwK-WGKOgqLC6TS_yWRG4JLI66hxaqZRgQuNw9vJPIi94bcBYfPj85-VbFyW0s0aR8cY0GMzgw6lWHS1KztJC11_4K_fOXAPfVOVOZMkekcJr-JknMk45zVLvBxDUeaWabMiK8v2-Qcap1yze6XNM3sGcmYrORlzEs39eddyd18yigSUIa_oJPEdC4J8OiE0sDmo8NFrvaUa8tTJQmTIa7jquzW5TYfJyF3YFQMB8o0vy_B2Kf8cvMR00z2z__SUaSrcDqMmBz7V8pxWSRKANMDx45K02T1tETvqWFczJTIKuafc3526x2oii_qwy9nMPrGO76SvvsZIDIbmCJKQuX4noECdrhULenZfrRoaFjQcLGtuyOXQZ_6yy992yrQZfRuaE7z5QkJ3ZcsLpFpKV5OO7g3DjFbx4f09RuSBrUwzm9Oh_7mMwHvKV-TDWl7aEQBC7aeocNu9GF--naVMWVo3pO1Ez4Heh1xUcFP2Bszs6fbCrV2CQnSlvDuXPZ5kgywLfO9jmPPdUTwNxM7NSsFfIYIRacYImlehq0.c0aZbyKloFV_gfFBhh4WCA"
}

variable "vlz_s3_path_to_conn" {
    type = string
    description = "S3 Path to Connector"
    #example = "https://<bucket-name>.s3.amazonaws.com/connector/<folder-name>/ubuntu"
}

variable "vlz_rest_apigw" {
    type = string
    description = "VLZ REST API Gateway"
    #example = https://<apigw-id>.execute-api.<region>.amazonaws.com/dev
}

### Media ###

variable "image_id" {
  type = string
  description = "Image OCID"
  #default = "ocid1.image.oc1.iad.aaaaaaaah4rpzimrmnqfaxcm2xe3hdtegn4ukqje66rgouxakhvkaxer24oa"
  default = "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla"
}

variable "num_of_instances" {
  type = number
  description = "Number of instances to be created"
  default = 1
}