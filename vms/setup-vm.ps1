# Set the time zone
Set-TimeZone -Name "Central Standard Time"

# Disable Server Manager auto-start
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask

# Disable Firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

#Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install Software
choco install git azurepowershell azure-cli bicep vscode sysinternals microsoftazurestorageexplorer windows-admin-center -y

# Hide clock
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies' -Name 'Explorer'
New-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies' -Name 'Explorer'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideClock' -Value 1
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideClock' -Value 1
Stop-Process -Name 'explorer'

# Show system files and extensions
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowSuperHidden 1
Stop-Process -processname explorer
