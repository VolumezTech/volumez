# Volumez

Terraform code which creates VPC resources, Media & Application nodes with vlzconnector configuration
Terraform creates VPC,subnets,instances and security groups.

# Requirements
* Terraform > 0.14  
* AWS credentials as environment variables 
* kubectl (for EKS examples)
* Helm (for EKS examples)
* awscli (for EKS examples)

# EC2
---

### Input ###
Mandatory: Tenant Token (JWT Access Token) 

### Usage ###
> Create with default values
```
export TF_VAR_tenant_token=$TENANT_TOKEN
terraform init
terraform apply
```

> Custom variables
```
export TF_VAR_tenant_token=$TENANT_TOKEN
terraform init
terraform apply -var="region=us-east-1" -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
terraform destroy
```

### Examples ###  
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

### Input ### 
Mandatory: CSI Driver Token (Refresh Token)  

### Usage (Terraform) ###
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

> Output
```
terraform output
```
Example output:
```
cluster_endpoint = "https://759E02F3CB0F242849E6FEE7CF93DF86.gr7.us-east-1.eks.amazonaws.com"
cluster_id = "Volumez-eks-xWG3D5gq"
cluster_name = "Volumez-eks-xWG3D5gq"
cluster_security_group_id = "sg-0a2afe43ebc6abd06"
region = "us-east-1"
```

### Usage (helm) ###
> Configure kubectl

Configure kubectl so that you can connect to an EKS cluster: 
```aws eks --region <region> update-kubeconfig --name <cluster_name>```
**region** and **cluster_name** parameters can be fount in Terraform's output

> Deploy CSI driver deployment with helm 
```
cd kubernetes/helm
helm install vlz volumez-csi --set vlzAuthToken=$CSI_DRIVER_TOKEN
```
> Uninstall CSI driver
```
helm uninstall vlz
```

### Examples ### 
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

### Application deployment ###
**power_starter** and **mix_and_match** are supporting the creation of application nodes. In these examples 2 node groups will be created in a single EKS. In order to deploy your application use the following node affinity configuration:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: instance-type
            operator: In
            values:
            - volumez-app-ng            
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```
