
param location string = resourceGroup().location

param vmName string

@allowed([
  '2008-R2-SP1'
  '2012-Datacenter'
  '2012-R2-Datacenter'
  '2016-Nano-Server'
  '2016-Datacenter-with-Containers'
  '2016-Datacenter'
  '2019-Datacenter'
])
param windowsOSVersion string = '2019-Datacenter'

param adminUsername string

@secure()
param adminPasswordOrKey string

param vmSize string = 'Standard_D2_v3'

param createNewStorageAccount bool = false

param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Storage account type')
param storageAccountType string = 'Standard_LRS'

param createNewVnet bool = false

param vnetName string = 'VirtualNetwork'

param addressPrefixes array = [
  '10.0.0.0/16'
]

param subnetName string

param subnetPrefix string

param vnetResourceGroupName string = resourceGroup().name

param createNewPublicIP bool = false

param publicIPName string = 'PublicIp'

param publicIPDns string = 'linux-vm-${uniqueString(resourceGroup().id)}'

var subnetId = createNewVnet ? subnet.id : resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

resource storageAccount 'Microsoft.Storage/storageAccounts@2017-06-01' = if (createNewStorageAccount) {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: storageAccountType
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2017-09-01' = if (createNewPublicIP) {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: publicIPDns
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-08-01' = {
  name: 'default-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2017-09-01' = if (createNewVnet) {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2017-09-01' = if (createNewVnet) {
  name: '${vnet.name}/${subnetName}'
  properties: {
    addressPrefix: subnetPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2017-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2017-03-30' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
