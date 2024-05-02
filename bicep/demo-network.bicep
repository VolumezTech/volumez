param snetName string
param vnetName string
param location string
param projectName string
param deployBastion bool

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.5' = {
  name: 'deploy-vnet-${uniqueString(deployment().name)}'
  params: {
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: vnetName
    location : location
    subnets: [
      {
        addressPrefix: '10.0.0.0/24'
        name: 'AzureBastionSubnet'
      }
      {
        addressPrefix: '10.0.1.0/24'
        name: snetName
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        natGatewayResourceId: natGateway.outputs.resourceId
      }
    ]  
  }
  dependsOn : [ networkSecurityGroup, natGateway ]  
}


module bastionHost 'br/public:avm/res/network/bastion-host:0.2.1' = if (deployBastion) {
  name: 'deploy-bastion-${uniqueString(deployment().name)}'
  params: {
    name: 'bas-${projectName}-${uniqueString(deployment().name)}'
    virtualNetworkResourceId: resourceId('Microsoft.Network/VirtualNetworks', vnetName )
    location : location
    publicIPAddressObject: {
      alregionMethod: 'Static'
      name: 'pip-${projectName}-net'
      publicIPPrefixResourceId: ''
      skuName: 'Standard'
      skuTier: 'Regional'
      zones: [ 1 ]
    }
  }
  dependsOn : [ virtualNetwork ]
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.3' = {
  name: 'deploy-nsg-${uniqueString(deployment().name)}'
  params: {
    name: 'nsg-${projectName}-${uniqueString(deployment().name)}'
    location : location
    securityRules: [
      {
        name: 'allow_ssh_in'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'allow_ssh_out'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
          direction: 'Outbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'allow_ping'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 200
          protocol: 'Icmp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'allow_fio_in'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '8765'
          direction: 'Inbound'
          priority: 300
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'allow_fio_out'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '8765'
          direction: 'Outbound'
          priority: 300
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }                      
    ]
  }
}

module publicIpPrefix 'br/public:avm/res/network/public-ip-prefix:0.3.0' = {
  name: 'deploy-ppipfx-${uniqueString(deployment().name)}'
  params: {
    name: 'pipfx-${projectName}-${uniqueString(deployment().name)}'
    prefixLength: 30
    location : location
  }
}

module natGateway 'br/public:avm/res/network/nat-gateway:1.0.4' = {
  name: 'deploy-ngw-${uniqueString(deployment().name)}'
  params: {
    name: 'ngw-${projectName}-${uniqueString(deployment().name)}'
    zones: [ 1 ]
    location : location
    publicIPPrefixResourceIds: [ publicIpPrefix.outputs.resourceId ]
  }
  dependsOn: [
    publicIpPrefix
  ]
}
