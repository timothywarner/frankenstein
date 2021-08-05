# Set the time zone
Set-TimeZone -Name "Central Standard Time"

# Disable Firewall (careful!)
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install Software
choco install microsoft-edge powershell-core azurepowershell azure-cli bicep vscode -y

# Disable IE Enhanced Security Config
function Disable-IEESC {
  $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
  $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
  Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
  Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
  Stop-Process -Name Explorer
}
Disable-IEESC
