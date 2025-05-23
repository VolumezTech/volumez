# Volumez

Volumez is SaaS composable data infrastructure. With Volumez, you can deploy applications in your cloud with precise control of IO characteristics using a fully declarative interface

This is a guide of how you can create AWS/Azure environments (EKS/AKS or EC2/VM) and install the volumez connector.

# Requirements
* Terraform > 1.7.0  
* AWS/Azure credentials as environment variables 
* kubectl (for EKS/AKS examples)
* Helm v3.8 (for EKS/AKS examples) 
* awscli (for EKS examples)
* Azure CLI (for AKS examples)

# Usage
1. Clone the project:  
```git clone https://github.com/VolumezTech/volumez.git```
2. CD into relevant directory, Depeneds on what use-case you wish to execute (Example EC2):  
```cd volumez/terraform/aws/examples/ec2/complete/easy_starter```
3. Before execution, you can edit predifined "easy_starter.tfvars" or execute it as is:  
```vi easy_starter.tfvars```   or   ```terraform init && terraform apply -var-file="easy_starter.tfvars"```

# Get Started
* [AWS EC2 environment](#ec2)  
* [AWS EKS environment](#eks)  
* [Azure VM environment](#vm)  
* [Azure AKS environment](#aks)  
* [Azure VMSS](#vmss)  
* [Oracle Instance pool](#instance-pool)  
<br />
<br />
<br />
  

## EC2
---
### Prerequisite  ###
Minimum AWS IAM permissions.   

> iam_policy.json is located 
[here](https://github.com/VolumezTech/volumez/blob/master/terraform/aws/examples/ec2/complete/easy_starter)
<details>

```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "sts:GetCallerIdentity",
                  "ec2:DescribeKeyPairs",
                  "ec2:DescribeVpcs",
                  "ec2:DescribeNetworkAcls",
                  "ec2:DescribeRouteTables",
                  "ec2:DescribeSecurityGroups",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeInternetGateways",
                  "ec2:DescribeAddresses",
                  "ec2:DescribeNetworkInterfaces",
                  "ec2:DescribeAddressesAttribute",
                  "ec2:DescribeInstanceTypes",
                  "ec2:DescribeImages",
                  "ec2:DescribeNatGateways",
                  "iam:PassRole",
                  "ec2:DescribeInstances",
                  "ec2:DescribeSecurityGroupRules",
                  "ec2:DescribeTags",
                  "ec2:DescribeVolumes",
                  "ec2:DescribeInstanceCreditSpecifications",
                  "ec2:ImportKeyPair",
                  "ec2:CreateInternetGateway",
                  "ec2:CreateVpc",
                  "ec2:CreateTags",
                  "ec2:CreateSubnet",
                  "ec2:CreateRoute",
                  "ec2:CreateNetworkInterface",
                  "ec2:CreateSecurityGroup",
                  "ec2:CreateNatGateway",
                  "ec2:CreateRouteTable",
                  "ec2:AssociateRouteTable",
                  "ec2:RunInstances",
                  "ec2:AllocateAddress",
                  "ec2:ModifySubnetAttribute",
                  "ec2:AttachInternetGateway",
                  "ec2:ModifyVpcAttribute",
                  "ec2:DescribeVpcAttribute",
                  "ec2:DeleteVpc",
                  "ec2:DescribeInstanceAttribute",
                  "ec2:ModifyInstanceAttribute",
                  "ec2:TerminateInstances",
                  "ec2:DisassociateRouteTable",
                  "ec2:RevokeSecurityGroupIngress",
                  "ec2:RevokeSecurityGroupEgress",
                  "ec2:AuthorizeSecurityGroupEgress",
                  "ec2:AuthorizeSecurityGroupIngress",
                  "ec2:DeleteNatGateway",
                  "ec2:DetachNetworkInterface",
                  "ec2:DeleteNetworkInterface",
                  "ec2:DeleteSecurityGroup",
                  "ec2:DisassociateAddress",
                  "ec2:ReleaseAddress",
                  "ec2:DeleteRouteTable",
                  "ec2:DeleteRoute",
                  "ec2:DeleteSubnet",
                  "ec2:DetachInternetGateway",
                  "ec2:DeleteInternetGateway"
                  "ec2:DescribeInstanceStatus"
              ],
              "Resource": "*"
          }
      ]
  }
```
  </details>

### Inputs ###
> Mandatory: 
1. Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target AWS region (example: us-east-1)

> Existing Network Configuration (Optional, edit easy_starter.tfvars):  

Important Note, when using existing resources, for optimal performance make sure that the existing instances are part of a placement group ([link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html#placement-groups-cluster)) and provide it's id in the parameter below.

1. target_vpc_id - Existing VPC ID to add the relevant resources to. If provided, the resources will be created in this VPC instead of creating a new one.
2. target_subnet_id - Existing Subnet ID where the resources will be placed. If provided, the resources will be created in this subnet instead of creating a new one.
3. target_security_group_id - Existing Security Group ID to be associated with the resources. If provided, this security group will be used instead of creating a new one. Port 22 should be open.
4. target_placement_group_id - Existing Placement Group ID. If provided, this placement group will be used instead of creating a new one.

### Usage ###
> Create with default values
```
terraform init
terraform apply -var-file="easy_starter.tfvars"
```

> Custom variables (List of available variables can be found under Examples > mix_and_match)
```
terraform init
terraform apply -var="media_node_ami=ami-08895422b5f3aa64a" -var="media_node_type=i3en.3xlarge"
```

> Custom variables (edit easy_starter.tfvars if needed)  
```
# General Configuration
region  = "us-east-1"
resources_name_prefix = "volumez"
num_of_zones = 1
create_fault_domain = false
avoid_pg = true
deploy_bastion = true
key_name = ""
 
# Existing Network Configuration (Optional)
target_vpc_id             = ""
target_subnet_id          = ""
target_security_group_id  = ""
target_placement_group_id = ""
 
# Media Nodes
media_node_count = 2
media_node_type = "i4i.2xlarge"
media_node_iam_role = null
media_node_ami = "default"
media_node_ami_username = "default"
media_node_name_prefix = "media"
 
# App Nodes
app_node_count = 1
app_node_type = "m5n.xlarge"
app_node_iam_role = null
app_node_ami = "default"
app_node_ami_username = "default"
app_node_name_prefix = "app"
```

> Destroy
```
terraform destroy
```  
or  
```
terraform destroy -var-file="easy_starter.tfvars"
```  

### SSH To Node ### 
```
terraform output ssh_private_key > ssh_key; chmod 400 ssh_key; ssh -i ssh_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o "ProxyCommand=ssh -W %h:%p ec2-user@$(terraform output bastion_public_dns) -i ssh_key -o StrictHostKeyChecking=no" ec2-user@<media/app_nodes_private_ips>
```

### Examples ###  
> easy_starter

to use pre-defined easy starter variables you can use:

```
terraform apply -var-file="easy_starter.tfvars"
```

* 7 media nodes accross 2 AZ's  
* media node type: is4gen.2xlarge  
* default OS: Red Hat 8.7  


No default values, the following should be set in order to execute the terraform:
1. region                   - target region
2. num_of_zones             - number of AZ's to create the media/app nodes in. (evenlly spread between AZ's)
3. create fault domain      - when set to true, placement group starategy will be 'partition's, otherwise 'cluster'
4. tenant_token             - Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
5. media_node_count         - Number of media nodes to create
6. media_node_type          - Media EC2 type
7. app_node_count           - number of performance hosts
8. app_node_type            - EC2 type for application node

## EKS
---

### Inputs ### 
Mandatory:  
1. CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  

### Examples ### 
> easy_starter

to use pre-defined easy starter variables you can use:

```
terraform apply -var-file="easy_starter.tfvars"
```

using easy_starter.tfvars file as is will scale:
* 6 media nodes
* media node type: i3en.3xlarge  

Edit easy_starter.tfvars file with custom values you desire:

1. region              - region to deploy cluster
2. k8s_version         - kubernetes version
3. resource_prefix     - prefix for resources names
4. media_node_count    - number of media nodes
5. media_node_type     - instance type of media nodes
6. media_node_ami_type - AMI type of media nodes (AL2_x86_64/AL2_ARM_64 - needs to match instance type) 
7. app_node_count      - number of app nodes (if grater than 0, app node group will be created, if 0 it won't be created)
8. app_node_type       - instance type of app nodes
9. app_node_ami_type   - AMI type of app nodes (AL2_x86_64/AL2_ARM_64 - needs to match instance type) 


### Usage (Terraform) - Create EKS cluster ###
> Create 
```
terraform init
terraform apply -var-file="easy_starter.tfvars"
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

### Usage (helm) - Deploy Volumez-CSI configuration ###
> Configure kubectl

Configure kubectl so that you can connect to an EKS cluster:  
```aws eks --region <region> update-kubeconfig --name <cluster_name>```  
**region** and **cluster_name** parameters can be found in Terraform's output

> Deploy CSI driver with helm 
```
helm repo add volumez-csi https://volumeztech.github.io/helm-csi --force-update
helm install volumez-csi volumez-csi/volumez-csi --set vlzAuthToken=[YOUR_CSI_TOKEN] -n vlz-csi-driver --create-namespace
```

For detailed configuration options, please refer to the [volumez-csi chart README](https://github.com/VolumezTech/helm-csi/blob/main/charts/volumez-csi/README.md).

#### Install Only on Specific Node/Node-Group ####
To install `volumez-csi` on a specific node or node group, first label the node(s) appropriately.
Then, add the following flag to the end of your helm install command, replacing `<label-key>` and `<label-values>` with your actual labels:
```bash
--set-json 'csiNodeVlzplugin.affinity={"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"<label-key>","operator":"In","values":["<label-values>"]}]}]}}}'
```
i.e:
```bash
--set-json 'csiNodeVlzplugin.affinity={"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"nodepool-type","operator":"In","values":["app", "media"]}]}]}}}'
```

> Upgrade CSI driver

If you previously added this repository, run `helm repo update` to fetch the latest package versions.
Afterwards, you can run `helm search repo volumez-csi -l` to view the available charts.<br/>
To upgrade the chart:

```bash
helm upgrade volumez-csi volumez-csi/volumez-csi -n vlz-csi-driver 
```

> Uninstall CSI driver
```
helm uninstall volumez-csi -n vlz-csi-driver
```


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
## VM
---

### Inputs ###
Mandatory: 
1. Tenant Token (JWT Access Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target Azure region (example: eastus)

### Usage ###
> Create with default values
```
terraform init
terraform apply -var-file="easy_starter.tfvars"
```

> Destroy
```
terraform destroy
```

### SSH To Node ###
verify bastion was deployed (deploy_bastion=true in easy_starter.tfvars)

1. ```terraform output tls_private_key > ssh_key```
2. Go to Azure console and select the VM you want to ssh into
3. Click on Connect->Bastion
4. Select Authentication Type: SSH Private Key from Local File
5. Username: adminuser
6. Local File: upload ssh_key from stage 1

### Examples ###  
> easy_starter

to use pre-defined easy starter variables you can use:

```
terraform apply -var-file="easy_starter.tfvars"
```

* 16 media nodes (spread across 2 availability zones)
* media node type: Standard_L8s_v3
* default OS: Red Hat 8.7  

> custom configs

edit or copy easy_starter.tfvars to a new file and set values as you wish:
1. resource_group_location  - target region
2. resource_prefix          - prefix for resource group name
2. zones                    - List of AZ's to create the media/app nodes in. (evenlly spread between AZ's)
5. media_node_count        - Number of media nodes to create
6. media_node_type          - Media VM type
7. app_node_count          - number of performance hosts
8. app_node_type            - VM type for application node
9. image_publisher/offer/sku/version - OS image details

## AKS
---

### Inputs ### 
Mandatory:  
1. CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target Azure resource group region (example: East US)  

### Usage (Terraform) - Create AKS cluster ###
> Create with default values
```
terraform init
terraform apply -var-file="easy_starter.tfvars"
```

> Destroy
```
terraform destroy -var-file="easy_starter.tfvars"
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

> Deploy CSI driver with helm 
```bash
helm repo add volumez-csi https://volumeztech.github.io/helm-csi --force-update
helm install volumez-csi volumez-csi/volumez-csi --set vlzAuthToken=[YOUR_CSI_TOKEN] -n vlz-csi-driver --create-namespace
```

For detailed configuration options, please refer to the [volumez-csi chart README](https://github.com/VolumezTech/helm-csi/blob/main/charts/volumez-csi/README.md).

#### Install Only on Specific Node/Node-Group ####
To install `volumez-csi` on a specific node or node group, first label the node(s) appropriately.
Then, add the following flag to the end of your helm install command, replacing `<label-key>` and `<label-values>` with your actual labels:
```bash
--set-json 'csiNodeVlzplugin.affinity={"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"<label-key>","operator":"In","values":["<label-values>"]}]}]}}}'
```
i.e:
```bash
--set-json 'csiNodeVlzplugin.affinity={"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"nodepool-type","operator":"In","values":["app", "media"]}]}]}}}'
```

> Upgrade CSI driver

If you previously added this repository, run `helm repo update` to fetch the latest package versions.
Afterwards, you can run `helm search repo volumez-csi -l` to view the available charts.<br/>
To upgrade the chart:

```bash
helm upgrade volumez-csi volumez-csi/volumez-csi -n vlz-csi-driver 
```

> Uninstall CSI driver
```bash
helm uninstall volumez-csi -n vlz-csi-driver
```

### Examples ### 
> easy_starter

to use pre-defined easy starter variables you can use:
```
terraform apply -var-file="easy_starter.tfvars"
```

* 6 media nodes
* media node size: Standard_L8s_v3 

> mix_and_match

No default values, the following should be set in order to execute the terraform (will be prompted on command line):
1. resource_group_location  - Target region
2. media_node_count         - Number of media nodes to create
3. media_node_type          - Media node size
4. app_node_count           - Number of application nodes
5. app_node_type            - Application node size
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

## VMSS
---

### Inputs ### 
Mandatory:  
1. CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
2. Region - Target Azure resource group region (example: East US)  

### Usage ###
> Create with default values (you can also edit these values)
```
terraform init
terraform apply -var-file="easy_starter.tfvars"
```

> Custom variables (edit easy_starter.tfvars if needed)  
```
resource_group_location = "eastus"
resource_prefix = "volumez"

### 2.Target Resource Group (create the VMSS in an existing resource group) ###
target_resource_group_location = ""
target_resource_group_name = ""

### VMSS ###
vmss_type = "flexible" 
create_fault_domain = true 
platform_fault_domain_count can be 2-5 (set in variable below)
platform_fault_domain_count = 5


### Network ###
zones = ["1", "2"] 
target_proximity_placement_group_id = null
target_virtual_network_name = ""
target_subnet_id = null
deploy_bastion = false

### Media ###
media_node_type = "Standard_L8s_v3"
media_node_count = 20   
media_image_publisher = "Canonical"
media_image_offer = "0001-com-ubuntu-server-jammy" 
media_image_sku = "22_04-lts-gen2"
media_image_version = "latest"

vlz_refresh_token = ""
```

> Destroy
```
terraform destroy -var-file="easy_starter.tfvars"
```

> Explaining the variables

1. resource_prefix - Prefix for naming the resources that will be created by this Terraform (if creating a new resource-group)
2. resource_group_location - location to create resource group (if creating a new resource-group)
3. target_resource_group_location - location in which the resource group exists (if using existing resource-group)
4. target_resource_group_name - name of the resource group to created our vmss in (if using existing resource-group)
5. zones - list of availability zones. i.e: ["1"] (for single-zone), ["1", "2", ...] (for multi-zone) 
6. target_proximity_placement_group_id - proximity group id in which vmss will be scaled in. In case "zones" list contains more than one zone, this value will be ignored
7. target_virtual_network_name - vnet name in which vmss will be scaled in
8. target_subnet_id - subnet id in which vmss will be scaled in. 
9. media_node_type - VM size
10. media_node_count -  num of VMs in VMSS
11. media_image_* - marketplace OS configuration block
12. vlz_refresh_token - Refresh Token (CSI Token) - Can retrieve from Volumez portal under Developer Info
13. vmss_type - uniform or flexible orchestration
14. create_fault_domain - use more than 1 fault domain
platform_fault_domain_count - number of fault daomins to use (see limitations below)

> Fault Domain Count Limitations 
1. if vmss_type = "uniform/flexible" and create_fault_domain = false, platform_fault_domain_count will be 1
2. if vmss_type = "uniform" and create_fault_domain = true, platform_fault_domain_count will be 5
3. if vmss_type = "flexible" and create_fault_domain = true, platform_fault_domain_count can be 2 or 3 (set in variable below)
4. if vmss_type = "flexible" and create_fault_domain = true and Microsoft.Compute/VMOrchestratorZonalMultiFD is enabled, platform_fault_domain_count can be 2-5


### SSH To Node ###
verify bastion was deployed (deploy_bastion=true in easy_starter.tfvars)

1. ```terraform output tls_private_key > ssh_key```
2. Go to Azure console and select the VMSS instance you want to ssh into
3. Click on Connect->Bastion
4. Select Authentication Type: SSH Private Key from Local File
5. Username: adminuser
6. Local File: upload ssh_key from stage 1

## Instance Pool
---
### Path to Project ###
```
volumez/terraform/oci/instance-pool
```
### Inputs (easy_starter.tfvars) ### 
1. Networking  
  a. region    = Target Region (example: "us-chicago-1")  
  b. ad_number = Availability Domain Number (example: 3)

2. Credentials  
  a. tenancy_ocid        = OCI tenancy ID  
  b. compartment_ocid    = OCI compartment ID  
  c. config_file_profile = Profile name to use in oci config file (example: "DEFAULT". Location of the file is ~/.oci/config)  

3. VLZ
  a. vlz_refresh_token   = CSI Driver Token (Refresh Token) - Can be fetched from Volumez.com -> Sign in -> Developer Info  
  b. vlz_s3_path_to_conn = S3 path to VLZ connector (example: https://<bucket-name>.s3.amazonaws.com/<folder-name>/<os-name>)
  c. vlz_rest_apigw      = REST Api Gateway URL (example: https://<apigw-id>.execute-api.<region>.amazonaws.com/dev)

3. Media  
  a. media_image_id         = OCI Image ID for Media VMs (example: "ocid1.image.oc1.us-chicago-1.aaaaaaaablgbvtnll3bamfwk5vjqk4fjnwheqyhsyez2juynjs6ycm5rhsla")  
  b. media_num_of_instances = Number of Media VMs  
  c. media_shape            = OCI Media Shape  
  d. media_num_of_ocpus     = OCI Media number of OCPUS  
  e. media_memory_in_gbs    = OCI Media memory (gbs)  

4. App  
  a. app_image_id         = OCI Image ID for Application VMs  
  b. app_num_of_instances = Number of Application VMs  
  c. app_shape            = OCI Application Shape  
  d. app_num_of_ocpus     = OCI Application number of OCPUS  
  e. app_memory_in_gbs    = OCI Application memory (gbs)  

### Usage ###
> Create & Install VLZ connector
1. Edit easy_starter.tfvars with relevant values
2. Execute the Terraform:
```
  terraform init
  terraform apply -var-file="easy_starter.tfvars"
```

> Destroy
```
terraform destroy -var-file="easy_starter.tfvars"
```

### SSH into the VM ###
1. ```terraform output tls_private_key > ssh_key```
2. ```chmod 600 ssh_key```
3. Check the relevant username and Public IP via OCI console
4. ```ssh -i /path/to/ssh_key <username>@<pub-ip>```






