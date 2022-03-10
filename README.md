# volumez

Terraform code which creates VPC resources, Media & Application nodes with vlzconnector configuration

# Requirements
* Terraform > 0.14  
* AWS credentials as environment variables 

# Input
Mandatory: tenant_token 

# Usage 
> Create with default values
```
terraform init
terraform apply -var="tenant_token=123"
```

> Custom variables
```
terraform init
terraform apply -var="tenant_token=123" -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
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
media node type: i3en.3xlarge  
default OS: Red Hat 8.5  
