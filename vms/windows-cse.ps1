# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install Software
choco install microsoft-edge powershell-core azurepowershell azure-cli bicep vscode -y