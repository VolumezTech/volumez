
func replaceMultiple(input string, replacements { *: string }) string => reduce(
  items(replacements), input, (cur, next) => replace(string(cur), next.key, next.value))

/*
#######################################################################################
#
#  Config/ variables
#
#######################################################################################
*/

@secure()
param adminPassword string
param tenant_token string
param nrAppVms int
param nrMediaVms int
param deployBastion string
param location string = resourceGroup().location
var deployBastionBool = bool(deployBastion) 
var sizeAppVm = 'Standard_D64_v5'
var sizeMediaVm = 'Standard_L8as_v3'
var projectName = 'volumezdemo'
var snetName = 'snet-${projectName}-vms'
var vnetName = 'vnet-${projectName}-services'


var signup_domain = 'signup.volumez.com'
var script = loadTextContent('./scripts/deploy_connector.sh')
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': signup_domain
})



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
    name: 'ppg-${projectName}'
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

  name: 'vmDeployment-app${i}'
  params: {
    adminUsername: '${projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: 'RHEL'
      publisher: 'RedHat'
      sku: '8_7'
      version: 'latest'
    }
    name: 'vm-${projectName}-app${i}'
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

  name: 'vmDeployment-media${i}'
  params: {
    adminUsername: '${projectName}User'
    adminPassword: adminPassword
    availabilityZone: 0
    customData: cloudInitScript
    proximityPlacementGroupResourceId: proximityPlacementGroup.outputs.resourceId

    imageReference: {
      offer: 'RHEL'
      publisher: 'RedHat'
      sku: '8_7'
      version: 'latest'
    }
    name: 'vm-${projectName}-media${i}'
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


