uses './variables/param-demo-normal.bicep'


func replaceMultiple(input string, replacements { *: string }) string => reduce(
  items(replacements), input, (cur, next) => replace(string(cur), next.key, next.value))


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
    snetName : snetName
    vnetName : vnetName
    location : location
    projectName : projectName
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
    name: 'ppg-${projectName}-${deployment().name}'
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
    adminUsername: '${projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: vmAppOffer
      publisher: vmAppPublisher
      sku: vmAppSku
      version: vmAppVersion
    }

    name: 'vm-${projectName}-app${deployment().name}${i}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc-${projectName}-app${i}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, snetName)
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
  dependsOn : [ demonetwork ]
}]



module mediaVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.3' = [for i in range(1, nrMediaVms): {

  name: 'vmDeployment-media${deployment().name}${i}'
  params: {
    adminUsername: '${projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: vmMediaOffer
      publisher: vmMediaPublisher
      sku: vmMediaSku
      version: vmMediaVersion
    }
    name: 'vm-${projectName}-media${deployment().name}${i}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            enablePublicIP: false
            name: 'ipc-${projectName}-media${i}'
            subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, snetName)
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
    // Non-required parameters
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: false
    location : location
    encryptionAtHost: false
  }
  dependsOn : [ demonetwork ]
}]


