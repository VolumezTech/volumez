# Volumez

Terraform code which creates VPC resources, Media & Application nodes with vlzconnector configuration

# Requirements
* Terraform > 0.14  
* AWS credentials as environment variables 

# Input
Mandatory: tenant_token 

# Usage 
> Create with default values
```
export TF_VARS_tenant_token=123
terraform init
terraform apply
```

> Custom variables
```
export TF_VARS_tenant_token=123
terraform init
terraform apply -var="region=us-east-1" -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
terraform destroy
```

# Examples
> easy_starter

default region: us-east-1  
4 media nodes accross 2 AZ's  
media node type: i3.large  
default OS: Red Hat 8.5  

> power_starter

default region: us-east-1  
8 media nodes accross 2 AZ's  
1 application node  
media node type: i3en.3xlarge  
application node type: m5n.xlarge  
default OS: Red Hat 8.5  
