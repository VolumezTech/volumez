import { replaceMultiple } from './lib/util.bicep'
import * as var from './configs/param-demo-normal.bicep'

@secure()
param adminPassword string
param tenant_token string
param nrAppVms int
param nrMediaVms int
param deployBastion string
param deploySize string
param location string = resourceGroup().location

var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})
var deployBastionBool = bool(deployBastion)


/*
#######################################################################################
#
#  Network
#
#######################################################################################
*/


module demonetwork './demo-network.bicep' = {
  name: 'demoNetworkDeploy'
  params: {
    snetName : var.snetName
    vnetName : var.vnetName
    location : location
    projectName : var.projectName
    deployBastion : deployBastionBool
  }
}

/*
#######################################################################################
#
#  Proximity Placement Group 
#
#######################################################################################
*/

module proximityPlacementGroup 'br/public:avm/res/compute/proximity-placement-group:0.1.2' = {
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
            name: 'ipc-${var.projectName}-app${i}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
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
    vmSize: var.sizeAppVm 
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, nrMediaVms): {

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
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
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
    vmSize: var.sizeMediaVm
    // Non-required parameters
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]


