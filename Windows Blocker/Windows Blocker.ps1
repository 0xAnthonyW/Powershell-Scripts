<# Created By Anthony Walters Make sure to check https://learn.microsoft.com/en-us/windows/release-health/release-information or https://learn.microsoft.com/en-us/lifecycle/products/windows-10-home-and-pro
for the Windows Version End Of Service Date #>
#todo need to find a way to get the Product Version Automatically mainly for windows 11 compatbility.
#Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

#Sets the Key Location Since location is not provided by default
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name WindowsUpdate -Force

#Sets the Key Location Since location is not provided by default
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name WindowsStore -Force

#Sets the Key Location Since location is not provided by default
New-Item -Path "HKLM:\SYSTEM\Setup" -Name UpgradeNotification -Force

#Sets the Key Location Since location is not provided by default
New-Item -Path "HKLM:\SOFTWARE\Microsoft" -Name PCHC -Force

#Opens Winver so you can note down the Windows Version Number then it will close after 5 seconds
# Start-Process Winver
# Start-Sleep -Seconds 5
# Stop-Process -Name Winver

# Prompt the user for the desired value of the TargetReleaseVersionInfo key
#$targetReleaseVersionInfo = Read-Host "Enter the desired TargetReleaseVersionInfo (Example: *22H2* *23H1* *23H2*)"

# Prompt the user for the desired value of the TargetReleaseVersionInfo key
$productVersion = Read-Host "Enter the desired ProductVersion (Example: *Windows 10* *Windows 11* *Windows 12*)"

PAUSE

#Set the value of the TargetReleaseVersionInfo key by automatically getting the windows version
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "DisplayVersion").DisplayVersion

# Set the value of the TargetReleaseVersionInfo key to the user-specified value
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $targetReleaseVersionInfo

# Set the value of the ProductVersion key to the user-specified value
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Value $productVersion

# Set the value of the TargetReleaseVersion key to 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -Value 1

# Set the value of the DisableOSUpgrade key to 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableOSUpgrade" -Value 1

# Set the value of the DisableOSUpgrade key to 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "DisableOSUpgrade" -Value 1

# Set the value of the UpgradeAvailable key to 0
Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\UpgradeNotification" -Name "UpgradeAvailable" -Value 0

# Hide Notfication Upgrade
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "SvOfferDeclined" -Value 1 -Type QWord

# Uninstall Windows PC Health Check [If GUID Changes go to HKEY_LOCAL_MACHINE:\Software\Microsoft\Windows\CurrentVersion\Uninstall to find it]
Start-Process -FilePath msiexec.exe -ArgumentList "/x {B1E7D0FD-7CFE-4E0C-A5DA-0F676499DB91} /qn" -Wait
Start-Process -FilePath msiexec.exe -ArgumentList "/x {6798C408-2636-448C-8AC6-F4E341102D27} /qn" -Wait
Start-Process -FilePath msiexec.exe -ArgumentList "/x {804A0628-543B-4984-896C-F58BF6A54832} /qn" -Wait


# Prevent Windows PC Health Check install
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PCHC" -Name "PreviousUninstall" -Value 1


<# Additional Reg Keys not needed for the moment but stored for incase of future use
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade AllowOSUpgrade /t REG_DWORD /d 0
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name OSUpgrade -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "OSUpgrade" -Value 0 -Type REG_DWORD
#>