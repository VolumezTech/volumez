import { replaceMultiple } from './lib/util.bicep'
import * as var from './configs/demo-config.bicep'
import { getSize } from './configs/demo-config.bicep'


var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})

@allowed([
  'small'
  'medium'
  'large'
  'xlarge'
])
param deploySize string
param tenant_token string
param location string = resourceGroup().location

@secure()
param adminPassword string = '!${uniqueString(newGuid())}99?'
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
    //zones: var.vmss_zones
  }
}

/*
#######################################################################################
#
#  Virtual Machine Scale Set vmss 
#
#######################################################################################
*/

module virtualMachineScaleSet 'br/public:avm/res/compute/virtual-machine-scale-set:0.1.1' = {
  name: 'deploy-vmss-media${uniqueString(deployment().name)}'
  params: {
    // Required parameters
    adminUsername: var.username
    imageReference: {
      offer: var.vmAppOffer
      publisher: var.vmAppPublisher
      sku: var.vmAppSku
      version: var.vmAppVersion
    }
    //proximityPlacementGroupResourceId : proximityPlacementGroup.outputs.resourceId
    customData: cloudInitScript
    name: 'vmss-${resourceGroup().name}-media${uniqueString(deployment().name)}'
    adminPassword: adminPassword
    osDisk: {
      createOption: 'fromImage'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
      caching: 'ReadWrite' 
    }
    osType: 'Linux'
    skuName: deploy_size.sizeAppVm 
    disablePasswordAuthentication: false
    encryptionAtHost: false
    location: location
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig1'
            properties: {
              publicIPAddressConfiguration: {
                name: 'pip-cvmsslinmin'
              }
              subnet: {
                id: resourceId('Microsoft.Network/VirtualNetworks/subnets', var.vnetName, var.snetName)
              }
            }
          }
        ]
        nicSuffix: '-nic01'
      }
    ]
  }
  dependsOn : [ demonetwork ]
}
