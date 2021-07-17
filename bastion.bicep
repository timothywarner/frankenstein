@description('Bastion virtual network name')
param virtualNetworkName string = 'hub-vnet'

@description('Bastion VNet address prefix')
param vNetIpPrefix string = '10.40.0.0/16'

@description('AzureBastionSubnet address prefix')
param bastionSubnetIpPrefix string = '10.40.5.0/24'

@description('Bastion host name')
param bastionHostName string = 'hub-bastion'

@description('Deployment location inherited from parent resource group')
param location string = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${bastionHostName}-pip-01'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetIpPrefix
      ]
    }
  }
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${virtualNetwork.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetIpPrefix
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subNet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
