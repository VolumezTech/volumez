# Volumez

Volumez is SaaS composable data infrastructure. With Volumez, you can deploy applications in your cloud with precise control of IO characteristics using a fully declarative interface

This is a guide of how you can create AWS/Azure environments (EKS/AKS or EC2/VM) and install the volumez connector.

# Get Started
* [Requirements](#requirements)  
* [AWS EC2 environment](#ec2)  
* [AWS EKS environment](#eks)  
* [Azure VM environment](#vm)  
* [Azure AKS environment](#aks)  

# Requirements
* Terraform > 0.14  
* AWS/Azure credentials as environment variables 
* kubectl (for EKS/AKS examples)
* Helm v3.8 (for EKS/AKS examples) 
* awscli (for EKS examples)
* Azure CLI (for AKS examples)

# EC2
---

### Inputs ###
Mandatory: 
1. Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target AWS region (example: us-east-1)

### Usage ###
> Create with default values
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_region=us-east-1
terraform init
terraform apply
```

> Custom variables (List of available variables can be found under Examples > mix_and_match)
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_region=us-east-1
terraform init
terraform apply -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_region=us-east-1
terraform destroy
```

### Examples ###  
> easy_starter

* 8 media nodes accross 2 AZ's  
* media node type: is4gen.2xlarge  
* default OS: Red Hat 8.7  

> power_starter

* 8 media nodes accross 2 AZ's  
* 1 application node  
* media node type: is4gen.2xlarge  
* application node type: m5n.xlarge  
* default OS: Red Hat 8.7  

> mix_and_match

No default values, the following should be set in order to execute the terraform:
1. region                   - target region
2. num_of_zones             - number of AZ's to create the media/app nodes in. (evenlly spread between AZ's)
3. placement_group_strategy - Placement group strategy. The placement strategy. Can be 'cluster', 'partition' or 'spread'
4. tenant_token             - Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
5. media_node_count         - Number of media nodes to create
6. media_node_type          - Media EC2 type
7. app_node_count           - number of performance hosts
8. app_node_type            - EC2 type for application node

# EKS
---

### Inputs ### 
Mandatory:  
1. CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target AWS region (example: us-east-1)  

### Usage (Terraform) - Create EKS cluster ###
> Create with default values
```
export TF_VAR_region=us-east-1
terraform init
terraform apply
```

> Custom variables (List of available variables can be found under Examples > mix_and_match)
```
export TF_VAR_region=us-east-1
terraform init
terraform apply -var="media_node_count=4" -var="media_node_type=i3en.3xlarge"
```

> Destroy
```
export TF_VAR_region=us-east-1
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

### Usage (helm) - Deploy Volumez-CSI configuration ###
> Configure kubectl

Configure kubectl so that you can connect to an EKS cluster:  
```aws eks --region <region> update-kubeconfig --name <cluster_name>```  
**region** and **cluster_name** parameters can be found in Terraform's output

> Deploy CSI driver deployment with helm 
```
helm repo add volumez-csi https://volumeztech.github.io/helm-csi
helm install volumez-csi volumez-csi/volumez-csi --set vlzAuthToken=eyJjdHkiOiJKV1QiLC -n vlz-csi-driver --create-namespace
```
> Upgrade CSI driver

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.
You can then run `helm search repo volumez-csi` to see the charts.<br/>

```
helm upgrade volumez-csi . -n vlz-csi-driver --set certmanager.installCRDs=false --set vlzAuthToken=eyJjdHkiOiJKV1QiLC
```

> Uninstall CSI driver
```
helm uninstall volumez-csi -n vlz-csi-driver
```

### Examples ### 
> easy_starter
* 6 media nodes
* media node type: i3en.3xlarge  

> power_starter
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
# VM
---

### Inputs ###
Mandatory: 
1. Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target Azure region (example: eastus)

### Usage ###
> Create with default values
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_resource_group_location=eastus
terraform init
terraform apply
```

> Custom variables (List of available variables can be found under Examples > mix_and_match)
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_resource_group_location=eastus
terraform init
terraform apply -var="media_node_type=Standard_L8as_v3"
```

> Destroy
```
export TF_VAR_tenant_token=eyJraWQiOiJhMUxrM1...
export TF_VAR_region=eastus
terraform destroy
```

### SSH To Node ### 
```
terraform output -raw tls_private_key > id_rsa
chmod 400 id_rsa
ssh -i id_rsa adminuser@<host-public-dns>
```

### Examples ###  
> easy_starter

* 16 media nodes (spread across 2 availability zones)
* media node type: Standard_L8as_v3
* default OS: Red Hat 8.7  

> mix_and_match

No default values, the following should be set in order to execute the terraform:
1. resource_group_location  - target region
2. zones                    - List of AZ's to create the media/app nodes in. (evenlly spread between AZ's)
3. tenant_token             - Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
5. num_of_media_node        - Number of media nodes to create
6. media_node_type          - Media VM type
7. num_of_app_node          - number of performance hosts
8. app_node_type            - VM type for application node

# AKS
---

### Inputs ### 
Mandatory:  
1. CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target Azure resource group region (example: East US)  

### Usage (Terraform) - Create AKS cluster ###
> Create with default values
```
export TF_VAR_resource_group_location=East US
terraform init
terraform apply -var-file="<varfile>.tfvars"
```

> Custom variables (List of available variables can be found under Examples > mix_and_match)
```
export TF_VAR_resource_group_location=East US
terraform init
terraform apply -var="media_node_count=4" -var="media_node_type=Standard_L8s_v3"
```

> Destroy
```
export TF_VAR_resource_group_location=East US
terraform destroy -var-file="<varfile>.tfvars"
```

> Output
```
terraform output
```
Example output:
```
cluster_name = "Volumez-aks-xWG3D5gq"
resource_group_name = "Volumez-aks-xWG3D5gq-rg"
```

### Usage (helm) - Deploy Volumez-CSI configuration ###
> Configure kubectl

Configure kubectl so that you can connect to an AKS cluster:  
```az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>```  
**resource-group-name** and **aks-cluster-name** parameters can be found in Terraform's output

> Deploy CSI driver deployment with helm 
```
helm repo add volumez-csi https://volumeztech.github.io/helm-csi
helm install volumez-csi volumez-csi/volumez-csi --set vlzAuthToken=eyJjdHkiOiJKV1QiLC -n vlz-csi-driver --create-namespace
```
> Upgrade CSI driver

If you had already added this repo earlier, run `helm repo update` to retrieve the latest versions of the packages.
You can then run `helm search repo volumez-csi` to see the charts.<br/>

```
helm upgrade volumez-csi . -n vlz-csi-driver --set certmanager.installCRDs=false --set vlzAuthToken=eyJjdHkiOiJKV1QiLC
```

> Uninstall CSI driver
```
helm uninstall volumez-csi -n vlz-csi-driver
```

### Examples ### 
> easy_starter
* 6 media nodes
* media node size: Standard_L8s_v3 

> power_starter

* 8 media nodes  
* 1 application node  
* media node size: Standard_L8s_v3
* application node size: Standard_D64_v5 

> mix_and_match

No default values, the following should be set in order to execute the terraform (will be prompted on command line):
1. resource_group_location  - Target region
2. media_node_count         - Number of media nodes to create
3. media_node_size          - Media node size
4. app_node_count           - Number of application nodes
5. app_node_size            - Application node size
6. k8s_version              - kubernetes cluster version (i.e: 1.24)

### Application deployment ###
**power_starter** and **mix_and_match** are supporting the creation of application nodes. In these examples 2 node groups will be created in a single AKS. In order to deploy your application use the following node affinity configuration:
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
          - key: nodepool-type
            operator: In
            values:
            - app           
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

