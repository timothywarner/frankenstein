# Bicep operations
bicep decompile ./hub-vnet.json --outfile hub-vnet.bicep

bicep build ./hub-vnet.bicep --outfile ./hub-vnet.json

 bicep publish file.bicep --target br:twacr1.azurecr.io/bicep/vnet:v1

# Validate and deploy
$subscriptionID = ''
$tenantID = ''
$deploymentName = 'vnet1'
$resourceGroupName = 'test-rg'
$templatePath = './hub-vnet.bicep'
$context = Get-AzContext

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
  -TemplateFile $templatePath

New-AzResourceGroupDeployment -Name $deploymentName `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile $templatePath `
  -Mode Incremental `
  -WhatIf # Verbose #TODO: integrate with PowerShell background jobs