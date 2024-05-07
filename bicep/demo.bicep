import { replaceMultiple } from './lib/util.bicep'
import * as var from './configs/demo-config.bicep'
import { getSize } from './configs/demo-config.bicep'

param tenant_token string
param deploySize string
param location string


var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})
var deploy_size = getSize(deploySize)
var uniqString  = uniqueString(deployment().name)
var rgName            = 'rg-${var.projectName}-${uniqString}'


module resourceGroup 'br/public:avm/res/resources/resource-group:0.2.3' = {
  name: 'deploy-rg-${uniqString}'
  scope: subscription()
  params: {
    name: rgName
    location: location
  }
}

/*
#######################################################################################
#
#  Network
#
#######################################################################################
*/


module demonetwork './demo-network.bicep' = {
  name: 'deploy-networkmodule-${uniqString}'
  scope: az.resourceGroup(rgName)
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
  name: 'deploy-ppg-${uniqString}'
  scope: az.resourceGroup(rgName)
  params: {
    name: 'ppg-${var.projectName}-${uniqString}'
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
  name: 'deploy-vm${i}-app${uniqString}'
  scope: az.resourceGroup(rgName)
  params: {
      adminUsername: '${var.projectName}User'
      availabilityZone: 0
      customData: cloudInitScript
      proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

      imageReference: {
        offer: var.vmAppOffer
        publisher: var.vmAppPublisher
        sku: var.vmAppSku
        version: var.vmAppVersion
      }

      name: 'vm${i}-${var.projectName}-app${uniqString}'
      nicConfigurations: [
        {
          ipConfigurations: [
            {
              enablePublicIP: true
              name: 'ipc${i}-${var.projectName}-app${uniqString}'
              subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
              zones: [
                var.zones
              ]
              pipConfiguration: {
                publicIpNameSuffix: '-pip-01'
                zones: [
                  var.zones
                ]
              }
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
      disablePasswordAuthentication: true
      location : location
      encryptionAtHost: false
    }
    dependsOn : [ demonetwork ]
  }
]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, deploy_size.nrMediaVms): {
  name: 'deploy-vm${i}-media${uniqString}'
  scope: az.resourceGroup(rgName)
  params: {
    adminUsername: '${var.projectName}User'
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: var.vmMediaOffer
      publisher: var.vmMediaPublisher
      sku: var.vmMediaSku
      version: var.vmMediaVersion
    }
    name: 'vm${i}-${var.projectName}-media${uniqString}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc${i}-${var.projectName}-media${uniqString}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
            zones: [
              var.zones
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
    vmSize: deploy_size.sizeMediaVm
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: true
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]


