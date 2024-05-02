import { replaceMultiple } from './lib/util.bicep'
import * as var from './configs/param-demo-normal.bicep'

@secure()
param adminPassword string
param tenant_token string
param nrAppVms int
param nrMediaVms int
param location string
param vnetName string
param subnetName string
param sizeAppVm string = 'Standard_D64_v5'
param sizeMediaVm string = 'Standard_L8as_v3'
param rgName string
param rgNameNetwork string

var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})


module proximityPlacementGroup 'br/public:avm/res/compute/proximity-placement-group:0.1.2' = {
  scope : resourceGroup(rgName)
  name: 'proximityPlacementGroupDeployment'
  params: {
    name: 'ppg-${var.projectName}-${deployment().name}'
    location: location
  }
}


/*
#######################################################################################
#
#  Virtual Machines: app-vms  + media-vms
#
#######################################################################################
*/

module appVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, nrAppVms): {
  scope : resourceGroup(rgName)
  name: 'vmDeployment-app${deployment().name}${i}'
  params: {
    adminUsername: '${var.projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId
    imageReference: {
      offer: var.vmAppOffer
      publisher: var.vmAppPublisher
      sku: var.vmAppSku
      version: var.vmAppVersion
    }
    name: 'vm-${var.projectName}-app${deployment().name}${i}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc-${var.projectName}-app${deployment().name}${i}'
            subnetResourceId:  resourceId(rgNameNetwork,'Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetName)
            zones: [
              '1'
            ]
          }
        ]
        nicSuffix: '-nic${i}'
      }
    ]
    osDisk: {
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
      caching: 'ReadWrite' 
    }
    osType: 'Linux'
    vmSize: sizeAppVm 
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
}]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, nrMediaVms): {
  scope : resourceGroup(rgName)
  name: 'vmDeployment-media${deployment().name}${i}'
  params: {
    adminUsername: '${var.projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId
    imageReference: {
      offer: var.vmMediaOffer
      publisher: var.vmMediaPublisher
      sku: var.vmMediaSku
      version: var.vmMediaVersion
    }
    name: 'vm-${var.projectName}-media${deployment().name}${i}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc-${var.projectName}-media${i}'
            subnetResourceId:  resourceId(rgNameNetwork,'Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetName)
            zones: [
              '1'
            ]
          }
        ]
        nicSuffix: '-nic${i}'
      }
    ]
    osDisk: {
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
      caching: 'ReadWrite' 
    }
    osType: 'Linux'
    vmSize: sizeMediaVm
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
}]

output snetResID string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, subnetName)


