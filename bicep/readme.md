# Deploy Volumez demo to Azure

The following demo uses the Bicep modules from the Microsoft Verified Modules github repo:
https://github.com/Azure/bicep-registry-modules


## Bicep

Create an Azure ARM template with this command:
```
az bicep build --file demo.bicep --outfile azuredeploy.json
```
Deploy direct via Bicep:
```
az deployment group create -g bicep --template-file demo.bicep  -n deploymentName1
```


The Bicep modules are converted to ARM templates and made available with the buttons below to give the Azure portal experience when deploying the resources:

| Description | Template |
|---|---|
| Deploy Simple Volumez demo |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchrisvugrinec%2Fvolumezdemo%2Fmaster%2F%2Fazuredeploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fchrisvugrinec%2Fvolumezdemo%2Fmaster%2FuiDefinition.json)|
| Deploy Customizable Volumez demo |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchrisvugrinec%2Fvolumezdemo%2Fmaster%2F%2Fazuredeploy-custom.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fchrisvugrinec%2Fvolumezdemo%2Fmaster%2FuiDefinition-custom.json)|
