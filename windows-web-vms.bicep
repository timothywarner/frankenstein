@description('VM administrative username')
param adminUsername string = 'tim'

@allowed([
  'sshPublicKey'
  'password'
])
@description('VM authentication method')
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

param subscriptionId string = ''

param kvResourceGroup string = ''

@description('Virtual network name')
param vNetName string = 'hub-vnet'

@description('VNet address range')
param vNetAddressRange string = '10.40.0.0/16'

param webSubnetName string = 'web'

param webSubnetPrefix string = '10.40.1.0/24'

param dataSubnetName string = 'data'

param dataSubnetPrefix string = '10.40.2.0/24'

@minValue(1)
@maxValue(2)
@description('Number of VMs to deploy')
param numberOfInstances int = 2

@allowed([
  'Ubuntu'
  'Windows'
])
@description('OS Platform for the VM')
param OS string = 'Windows'

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Standard_A1_v2'
])
@description('description')
param vmSize string = 'Standard_A1_v2'

var virtualNetworkName_var = vNetName
var addressPrefix = vNetAddressRange
var subnet1Name = webSubnetName
var subnet2Name = dataSubnetName
var subnet1Prefix = webSubnetPrefix
var subnet2Prefix = dataSubnetPrefix
var subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_var, subnet1Name)
var subnet2Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_var, subnet2Name)
var imageReference = {
  Ubuntu: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18.04-LTS'
    version: 'latest'
  }
  Windows: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-Datacenter'
    version: 'latest'
  }
}
var networkSecurityGroupName_var = 'default-NSG'
var nsgOsPort = {
  Ubuntu: '22'
  Windows: '3389'
}
var linuxConfiguration = {
  disablePasswordAuthentication: false
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource networkSecurityGroupName 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName_var
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-${nsgOsPort[OS]}'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: nsgOsPort[OS]
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: virtualNetworkName_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: networkSecurityGroupName.id
          }
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
          networkSecurityGroup: {
            id: networkSecurityGroupName.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = [for i in range(1, numberOfInstances): {
  name: 'hub-vm-nic${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet1Ref
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName
  ]
}]

resource myvm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(1, numberOfInstances): {
  name: 'hub-vm${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'hub-vm${i}'
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: imageReference[OS]
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'hub-vm-nic${i}')
        }
      ]
    }
  }
}]

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'tim-keyvault-001'
  scope: resourceGroup(subscriptionId, kvResourceGroup)
}
