import { replaceMultiple } from './lib/util.bicep'
import * as var from './configs/demo-config.bicep'
import { getSize } from './configs/demo-config.bicep'

param tenant_token string
param deploySize string
param location string = resourceGroup().location

var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': var.signup_domain
})
var deploy_size = getSize(deploySize)
var sshPubKey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCv5fxJwqRgFpLkAJ3WglpnknOeczpXp1AUwz5IIjE8nRjq5mqgF4Iz9zHzWTijeOTCXceWnF5tu39favGT1rpyRTbhATUtBFZYCZghdIXZrEjvOufjQ+KKiHz9TeB4Tk9Pd0aLwG3gJbtRDzgUDEfn+npfetDEMYzs8sQQD8+vaSko13bHTdcnHcS8yYzC+tm8d1eNXB+pVemGHcfGgmjRQ9Satc3bqALK6+LIvqpQA8AcxJGveuyX1Nk9thUwVi0Q4/uDIKOExwkmikBgslmwXGYxxOBYpLjPFQZ+ZFj1APKbJhYmyldvrEQgMMqKTKUuhqqsb5vq/XRFCya/8b9wiejh3A8hBww4Y3oszYuszVPazdxw3+8h4TZyVEOG/E6KPJZnI783vF88tavbslfy81ieyUAifmoamLFFq0Bxh3nqMAOxrsIsFNLjfP4jE4gMpAAcTpTG/RkPTu46VOC1g5Mfci6QK+wFC5Jiw5AcQDJ4+ADq6KWVrmUToDCLPWs= chris@MacBook-Air.local'


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

resource sshPublicKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' = {
  name: 'sshkey-${uniqueString(deployment().name)}'
  location: location
}

module appVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, deploy_size.nrAppVms): {
  name: 'deploy-vm${i}-app${uniqueString(deployment().name)}'

  params: {
      adminUsername: 'localAdminUser'
      availabilityZone: 0
      customData: cloudInitScript
      proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

      imageReference: {
        offer: var.vmAppOffer
        publisher: var.vmAppPublisher
        sku: var.vmAppSku
        version: var.vmAppVersion
      }

      name: 'vm${i}-${var.projectName}-app${uniqueString(deployment().name)}'
      nicConfigurations: [
        {
          ipConfigurations: [
            {
              enablePublicIP: false
              name: 'ipc${i}-${var.projectName}-app${uniqueString(deployment().name)}'
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
          storageAccountType: 'Standard_LRS'
        }
        caching: 'ReadWrite' 
      }
      osType: 'Linux'
      vmSize: deploy_size.sizeAppVm 
      configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
      disablePasswordAuthentication: true
      publicKeys: [
        {
          keyData: sshPubKey
          path: '/home/localAdminUser/.ssh/authorized_keys'
        }
      ]
  
      location : location
      encryptionAtHost: false
    }
    dependsOn : [ demonetwork ]
  }
]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, deploy_size.nrMediaVms): {
  name: 'deploy-vm${i}-media${uniqueString(deployment().name)}'
  params: {
    adminUsername: 'localAdminUser'
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: var.vmMediaOffer
      publisher: var.vmMediaPublisher
      sku: var.vmMediaSku
      version: var.vmMediaVersion
    }
    name: 'vm${i}-${var.projectName}-media${uniqueString(deployment().name)}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc${i}-${var.projectName}-media${uniqueString(deployment().name)}'
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
    publicKeys: [
      {
        keyData: sshPubKey
        path: '/home/localAdminUser/.ssh/authorized_keys'
      }
    ]
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]


