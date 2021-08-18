param subscriptionId string = '2fbf906e-1101-4bc0-b64f-adc44e462fff'
param kvResourceGroup string = 'TIM'
param kvName string = 'tim-keyvault-001'

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvName
  scope: resourceGroup(subscriptionId, kvResourceGroup)
}

module vm 'windows-vm.bicep' = {
  name: 'deploy-win4-vm'
  params: {
    adminUsername: 'tim'
    adminPassword: kv.getSecret('adminPassword')
    vmName: 'win4'
    vmSize: 'Standard_D2_v3'
    windowsOSVersion: '2019-Datacenter'
    createNewVnet: false
    vnetName: 'consumer-vnet'
    vnetResourceGroupName: 'pluralsight'
    addressPrefixes: [
      '10.60.0.0/16'
      ]
    subnetName: 'web'
    subnetPrefix: '10.60.1.0/24'
    applyCSE: true
  }
}
