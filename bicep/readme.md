# Volumez demo on Azure with bicep/arm

This demonstrates 2 deployment scenarios for your volumez environment on Azure:

- Standard resourcegroup deployment with pre configured network and vms
- Customized resourcegroup deployment where you can choose your vm size and choose an existing vnet and subnet.

This uses Bicep modules from the [Azure Verified Modules](https://github.com/Azure/bicep-registry-modules) github repo.

**Pre requisites**
- an Account with volumez, register [here](https://signup.volumez.com/); you need this to get your Tenant token
- a valid Azure subscription
- a valid user account/ service principal for your Azure subscription  with contributor permissions on the existing resourcegroups

## Standard VM deployment

This is ideal if you simply like to get started with default parameters. Just select an existing resourcegroup, define a password and the amount of application VMS and media vms. The tenant_token parameter is needed for communication with the Volumez backend, you can find this information in your volumez Account panel under developer info.
If you like to login to your VM, use the Bastion to connect; the default username is: volumezdemoUser.

![alt text](./documentation/standard.png)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition.json)

## Standard VMSS deployment


[![Deploy VMSS to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy-vmss.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition-vmss.json)


The following standard sizes are provided:

| Scenario | Nr of App VM's | App VM Size | Nr of Media VM's | Media VM Size |
|---|---|---|---|---|
|Small|1|Standard_D16_v5|2|Standard_L8s_v3|
|Medium|1|Standard_D32_v5|6|Standard_L8s_v3|
|Large|1|Standard_D64_v5|12|Standard_L8s_v3|
|Extra Large|1|Standard_D96_v5|18|Standard_L8s_v3|

More info on Azure VM Sizes can be found [here](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)

## Customized VM deploment

If you like to have more control of the deployment, use this to get started yourself. This is ideal as a starter for people with an **existing** environment; you like to have the VMS in a seperate resource group, customize the size of your VMS and use an **existing** Virtual network.  

The tenant_token parameter is needed for communication with the Volumez backend, you can find this information in your volumez Account panel under developer info. If you like to login to your VM, use the Bastion to connect; the default username is: volumezdemoUser

Please note that the creation of a new Resource Group or New Virtual Network is **NOT** supported in this scenario, you have to select an Existing Resource Group within the same region.

![alt text](./documentation/customized.png)
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy-custom.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition-custom.json)

[![Deploy to Azure](documentation/youtube.png)](https://youtu.be/FkZLBDdTn7I)

---

## Customization instructions

### With Azure ARM template

You can convert the bicep code here into arm code with this command:

```
az bicep build --file demo.bicep --outfile azuredeploy.json
```

You can edit and change the ARM temlate according to your desire and deploy the code using the portal or cli.

### With bicep code

You can also change the bicep code directly and then deploy the bicep code directly: 

```
az deployment group create -g bicep --template-file demo.bicep  -n deploymentName1
```

The uiDefinition files in this repository are customization files that help you with filling in the right parameters in the azure portal. 
Use [this](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/FormSandboxBlade) tool to edit or create your own portal UI forms.

## Settings

### Operating System

You can see an overview of all available major linux operating distributions on azure with this command:

```
for publisher in [ 'Debian' 'Redhat' 'SUSE' 'Canonical' 'OpenLogic' ]; do az vm image list -l westeurope --publisher $publisher --all -o table; done
```

You can change the operating systems in your config with the config file you are using in your bicep code, the following fields determine the OS of your VM: Offer, Publisher, SKU and Version. You can configure the OS for your APP VM's and your Media VM's.

### Zones

The zones for the VMs are configured via the Proximity Placement groups. More information [here](https://learn.microsoft.com/en-us/azure/virtual-machines/co-location).

You can configure the zones via the zones variable in the parameters file (within the config folder). Please note that the Proximity Placement group only supports 1 zone.


## Links

- Default VM Starter [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition.json)
- Default VMSS Starter [![Deploy VMSS to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy-vmss.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition-vmss.json)

- Customized VM starter  [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fazuredeploy-custom.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FVolumezTech%2Fvolumez%2Ffeature%2Fbicep-azure%2Fbicep%2Fportal-uidefinitions%2FuiDefinition-custom.json)
- [Volumez Sign up form](https://signup.volumez.com/)
- [Azure Verified Modules](https://github.com/Azure/bicep-registry-modules)
- [Azure VM Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Portal Form Designer](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/FormSandboxBlade); Tool to edit UI Input for - Azure Portal 
- [Proximity Placement Groups](https://learn.microsoft.com/en-us/azure/virtual-machines/co-location) 
