# Created By Anthony
# Windows Blocker Cleaner v1.0
# Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Removes the key and all its subkeys and values
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse -Force

# Removes the key and all its subkeys and values
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Recurse -Force

# Removes the key and all its subkeys and values
Remove-Item -Path "HKLM:\SYSTEM\Setup\UpgradeNotification" -Force

# Removes the key and all its subkeys and values
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\PCHC" -Recurse -Force

# Removes the key and all its subkeys and values
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "SvOfferDeclined"

Read-Host "Cleaned"

PAUSE