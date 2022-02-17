# Get Comfortable with Azure Bicep

## Meta

* Short link to this Gist: **[timw.info/bicep2022](https://gist.github.com/timothywarner/19217a7401e23d9e00da8839b13c0261)**
* [Tim's website](https://techtrainertim.com/)
* [Tim's Twitter](http://twitter.com/techtrainertim)
* [Tim's "Frankenstein" repository](https://github.com/timothywarner/frankenstein)

## Tools

* [PowerShell 7](https://github.com/PowerShell/PowerShell)
* [Azure PowerShell](https://docs.microsoft.com/powershell/azure/install-az-ps)
* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
* [Visual Studio Code](https://code.visualstudio.com/)
  * [PowerShell extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
  * [ARM Tools extension](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
  * [Azure CLI extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli)
  * [Azure Bicep extension](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#vs-code-and-bicep-extension)
* [Azure Bicep repository (releases)](https://github.com/Azure/bicep/releases)
* [Azure Bicep PowerShell module](https://github.com/PSBicep/PSBicep)
* [Azure Bicep CI/CD with Azure DevOps](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/add-template-to-azure-pipelines?tabs=CLI)
* [Azure Bicep CI/CD with GitHub Actions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions?tabs=CLI)

## Training

* [ARM/Bicep Template Reference](https://docs.microsoft.com/en-us/azure/templates/)
* [Bicep docs](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
* [Bicep @ Microsoft Learn](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep)
* [Bicep Playground](https://aka.ms/bicepdemo)
* [Bicep Authoring Devcontainer](https://github.com/Azure/vscode-remote-try-bicep)
* [Bicep Pluralsight course](https://www.pluralsight.com/courses/deploying-azure-resources-using-bicep)
* [Bicep private module registry](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/private-module-registry?tabs=azure-powershell)

## Common Bicep operations

### Install Bicep CLI in Azure CLI

```bash
az bicep install

az bicep version

az bicep upgrade
```

### Convert .bicep to .json

```bash
bicep build .\main.bicep --outfile .\arm-main.json

az bicep build --file .\main.bicep
```

### Convert .json to .bicep

```bash
bicep decompile .\arm-main.json --outfile .\arm.bicep

az bicep decompile --file .\arm-main.json
```

### Resource group deployments

#### PowerShell

```powershell
New-AzResourceGroupDeployment -ResourceGroupName 'test-rg' -TemplateFile '.\main.bicep' -WhatIf
```

#### Azure CLI

```bash
az deployment group create --resource-group 'test-rg' --template-file '.\main.bicep'
```

### Bicep PowerShell Module

#### Installation and discovery

```powershell
Install-Module -Name Bicep -Verbose -Force

Update-Help -Force -ErrorAction SilentlyContinue

Get-Command -Module Bicep

```

#### Create JSON parameter file from a Bicep file

```powershell
New-BicepParameterFile -Path '.\AzureFirewall.bicep' -Parameters All
```

#### Validate a Bicep file

```powershell
PS C:\> Test-BicepFile -Path 'MyBicep.bicep' -AcceptDiagnosticLevel 'Warning'
```
