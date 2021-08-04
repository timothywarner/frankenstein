param adminUserName string = 'tim'
param vmHostName string = 'vm1'

@secure()
param adminPassword string
param vnetName string = 'hub-vnet'
param vnetAddressRange string = '10.40.0.0/16'
param vnetSubnetName string = 'web'
param vnetSubnetAddressRange string = '10.40.1.0/24'

@allowed([
  '2016-Nano-Server'
  '2019-Datacenter-with-Containers'
  '2019-Datacenter-Core'
  '2019-Datacenter'
])
param windowsOSVersion string = '2019-Datacenter'

@allowed([
  'Standard_D2_v3'
  'Standard_B2ms'
])
param vmSize string = 'Standard_D2_v3'

param location string = resourceGroup().location

var nicName = '${vmHostName}-nic'
var virtualNetworkName = vnetName
var addressPrefix = vnetAddressRange
var subnetName = vnetSubnetName
var subnetPrefix = vnetSubnetAddressRange
var vmName = vmHostName
var subnetRef = '${vn.id}/subnets/${subnetName}'
var networkSecurityGroupName = 'default-NSG'

resource sg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        'properties': {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: sg.id
          }
        }
      }
    ]
  }
}

resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nInter.id
        }
      ]
    }
  }
}


