import { replaceMultiple } from './lib/util.bicep'
import { generatePassword } from './lib/util.bicep'
import * as var from './configs/demo-config.bicep'
import { getSize } from './configs/demo-config.bicep'

param randomNr1 int = dateTimeToEpoch(utcNow()) % 10
param randomNr2 int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'PT15H')) % 9
param randomNr3 int = dateTimeToEpoch(dateTimeAdd(utcNow(), '-PT39H')) % 8 
param randomNr4 int = dateTimeToEpoch(dateTimeAdd(utcNow(), '-PT17H')) % 26 
param randomNr5 int = dateTimeToEpoch(dateTimeAdd(utcNow(), '-PT8H')) % 25
param randomChar string[] = [ '!' , '@' , '#' , '[' , ']' , '^' , '&' , '>' , '<' , '_' ]
param randomNumber int[] = [ 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ]
param randomAlpha string[] = [ 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','U','V','W','X','Y','Z' ]
param baseRandomString string = uniqueString(newGuid())



param tenant_token string
@allowed([
  'small'
  'medium'
  'large'
  'xlarge'
])
param deploySize string
param location string = resourceGroup().location

param randomString string = generatePassword(baseRandomString,randomNr1, randomNr2, randomNr3, randomNr4, randomNr5, randomChar, randomNumber, randomAlpha)


var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})
var deploy_size = getSize(deploySize)



/*
#######################################################################################
#
#  Network
#
#######################################################################################
*/


module demonetwork './demo-network.bicep' = {
  name: 'deploy-networkmodule-${uniqueString(deployment().name)}'
  params: {
    snetName : var.snetName
    vnetName : var.vnetName
    location : location
    projectName : var.projectName
    deployBastion : false
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
  name: 'deploy-ppg-${uniqueString(deployment().name)}'
  params: {
    name: 'ppg-${var.projectName}-${uniqueString(deployment().name)}'
    location: location

    intent: {
      vmSizes: [
        deploy_size.sizeAppVm
        deploy_size.sizeMediaVm
      ]
    }
    zones: var.zones
  }
}

/*
#######################################################################################
#
#  Virtual Machines: app-vms  + media-vms
#
#######################################################################################
*/


module appVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, deploy_size.nrAppVms): {
  name: 'deploy-vm${i}-app${uniqueString(deployment().name)}'

  params: {
      adminUsername: var.username
      adminPassword: randomString
      availabilityZone: 0
      customData: cloudInitScript
      proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

      imageReference: {
        offer: var.vmAppOffer
        publisher: var.vmAppPublisher
        sku: var.vmAppSku
        version: var.vmAppVersion
      }

      name: 'vm${i}-${resourceGroup().name}-app${uniqueString(deployment().name)}'
      nicConfigurations: [
        {
          ipConfigurations: [
            {
              name: 'ipcp${i}-${var.projectName}-app${uniqueString(deployment().name)}'
              subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
              pipConfiguration: {
                publicIpNameSuffix: '-pipa${i}'
              }  
            }
            {
                name: 'ipc${i}-${var.projectName}-app${uniqueString(deployment().name)}'
                subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
                enablePublicIP: false
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
      vmSize: deploy_size.sizeAppVm 
      configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
      disablePasswordAuthentication: false
  
      location : location
      encryptionAtHost: false
    }
    dependsOn : [ demonetwork ]
  }
]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, deploy_size.nrMediaVms): {
  name: 'deploy-vm${i}-media${uniqueString(deployment().name)}'
  params: {
    adminUsername: var.username
    adminPassword: randomString
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: var.vmMediaOffer
      publisher: var.vmMediaPublisher
      sku: var.vmMediaSku
      version: var.vmMediaVersion
    }
    name: 'vm${i}-${resourceGroup().name}-media${uniqueString(deployment().name)}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipcp${i}-${var.projectName}-media${uniqueString(deployment().name)}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
            pipConfiguration : {
              publicIpNameSuffix: '-pipm${i}'
            }
          }
          {
            name: 'ipc${i}-${var.projectName}-media${uniqueString(deployment().name)}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
            enablePublicIP: false
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
    vmSize: deploy_size.sizeMediaVm
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]


