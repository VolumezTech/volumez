# Volumez

Terraform code which creates VPC resources, Media & Application nodes with vlzconnector configuration
Terraform creates VPC,subnets,instances and security groups.

# Requirements
* Terraform > 0.14  
* kubectl
* Helm
* AWS credentials as environment variables 

# EC2
---

#### Input ####
Mandatory: Tenant Token (JWT Access Token) 

#### Usage ###
> Create with default values
```
export TF_VAR_tenant_token=123
terraform init
terraform apply
```

> Custom variables
```
export TF_VAR_tenant_token=123
terraform init
terraform apply -var="region=us-east-1" -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
terraform destroy
```

### Examples
> easy_starter

* default region: us-east-1  
* 4 media nodes accross 2 AZ's  
* media node type: i3en.3xlarge  
* default OS: Red Hat 8.5  

> power_starter

* default region: us-east-1  
* 8 media nodes accross 2 AZ's  
* 1 application node  
* media node type: i3en.3xlarge  
* application node type: m5n.xlarge  
* default OS: Red Hat 8.5  

> mix_and_match

No default values, the following should be set in order to execute the terraform:
1. region                   - target region
2. number_of_zone           - number of AZ's to create the media/app nodes in. (evenlly spread between AZ's)
3. placement_group_strategy - Placement grpoup strategy. The placement strategy. Can be 'cluster', 'partition' or 'spread'
4. tenant_token             - Tenant token to access Cognito run vlzconnector service
5. media_node_count         - Number of media nodes to create
6. media_node_type          - Media EC2 type
7. app_node_count           - number of performance hosts
8. app_node_type            - EC2 type for application node

# EKS
---

### Input ####
Mandatory: CSI Driver Token (Refresh Token)  

#### Usage (Terraform) ###
> Create with default values
```
terraform init
terraform apply
```

> Custom variables
```
terraform init
terraform apply -var="region=us-east-1" -var="media_node_count=4" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
terraform destroy
```
#### Usage (helm) ###
> Deploy CSI driver deployment with helm
```
cd kubernetes/helm
helm install vlz volumez-csi --set vlzAuthToken=$CSI_DRIVER_TOKEN
```
> Uninstall CSI driver
```
helm uninstall volumez-csi
```

### Examples  
> easy_starter
* default region: us-east-1  
* 4 media nodes
* media node type: i3en.3xlarge  

> power_starter
* default region: us-east-1  
* 8 media nodes  
* 1 application node  
* media node type: i3en.3xlarge  
* application node type: m5n.xlarge  

> mix_and_match

No default values, the following should be set in order to execute the terraform:
1. region                   - target region
2. media_node_count         - Number of media nodes to create
3. media_node_type          - Media EC2 type
4. app_node_count           - number of performance hosts
5. app_node_type            - EC2 type for application node