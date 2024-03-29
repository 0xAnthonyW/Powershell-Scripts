# Created By Anthony
# Win10Fresh v0.10.7
# Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Disable User Account Control (UAC) consent prompt.
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
Write-Host "UAC DISABLED" -ForegroundColor Yellow

# Disable the "Turn off display after" and "Sleep after" settings for both power plans.
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0

#Sets brightness to 100%
(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)

try
{
    # Rename 'ESD-ISO' to 'ESD-USB'
    $volumeToRename = Get-Volume | Where-Object { $_.FileSystemLabel -eq 'ESD-ISO' }
    if ($volumeToRename)
    {
        Set-Volume -DriveLetter $volumeToRename.DriveLetter -NewFileSystemLabel 'ESD-USB'
    }
}
catch
{
    # Log the error or just silently continue
    Write-Host "An error occurred: $_. Exception type: $($_.GetType().FullName)"
}

# Get a list of all volumes on the system
# Check if 'ESD-USB' is assigned to D:
$esdVolume = Get-Volume | Where-Object { $_.FileSystemLabel -eq 'ESD-USB' }

if ($esdVolume.DriveLetter -ne 'D')
{
    
    # Unmount any volume currently assigned to D:
    $dVolume = Get-Volume | Where-Object { $_.DriveLetter -eq 'D' }
    if ($dVolume)
    {
        $diskpartScript = @"
select volume D
remove letter=D
"@
        $diskpartScript | diskpart
    }
    
    # Assign 'ESD-USB' to D:
    $diskpartScript = @"
select volume $($esdVolume.DriveLetter)
assign letter=D
"@
    $diskpartScript | diskpart
}

# Get a list of all volumes on the system
$volumes = Get-Volume | Where-Object { $_.FileSystemLabel -eq 'UEFI_NTFS' }

foreach ($volume in $volumes)
{
    $driveLetter = $volume.DriveLetter
    $diskpartScript = @"
select volume $driveLetter
remove letter=$driveLetter
"@
    $diskpartScript | diskpart
}

# Set up some variables for the script.
$TaskPass = 'C:\Users\admin\Desktop\TaskPasswordExpire.ps1'
$TaskRTC = 'C:\Users\admin\Desktop\TaskRTC.ps1'
$flipme = 'C:\Users\admin\Desktop\Software\FlipMe.ps1'
$UsbPath = 'D:\PassExpire'
$RTCPath = 'D:\RealTimeClock'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire'
$RealTimeClockPath = 'C:\Users\admin\Desktop\RealTimeClock'
$software = 'D:\Software'
$softwareDestination = 'C:\Users\admin\Desktop\Software'
$updates = 'D:\Updates'
$updatesDestination = 'C:\Users\admin\Desktop\Updates'
$WindowsBlocker = 'D:\Win11Blocker\WindowsBlocker.ps1'
$AdminAccount = "admin"

while ($true)
{
    # UserAccount
    $studentAccount = Read-host "Enter Student Account Name"

    # Confirm before proceeding
    $confirmation = Read-Host "Are you sure you want to create the account for '$studentAccount'? (Y/N)"

    if ($confirmation -eq 'Y' -or $confirmation -eq 'y')
    {
        $StuPassword = "Student" | ConvertTo-SecureString -AsPlainText -Force
        New-LocalUser -Name "$studentAccount" -Description "$studentAccount" -Password $StuPassword -Verbose
        Add-LocalGroupMember -Group "Users" -Member "$studentAccount"
        Set-LocalUser -Name "$studentAccount"
        net user $studentAccount /logonpasswordchg:yes
        Start-Sleep -Seconds 10
        break # Exit the loop once the account is created
    }
    else
    {
        Write-Host "Account creation cancelled. Let's try again."
    }
}

# Sets the administrator account password to never expire.
Set-LocalUser -Name $AdminAccount  -PasswordNeverExpires $True

if (Test-Path $softwareDestination) 
{
    Remove-Item -Path $softwareDestination -Force -Recurse
    Copy-Item -Path $software -Recurse -Destination $Destination
    Write-host "Software has been copied to $Destination " -ForegroundColor Green
}
else
{
    Copy-Item -Path $software -Recurse -Destination $Destination
    Write-host "Software has been copied to $Destination " -ForegroundColor Green
}
# Updates Folder
if (Test-Path $updatesDestination) 
{
    Remove-Item -Path $updatesDestination -Force -Recurse
    Copy-Item -Path $updates -Recurse -Destination $Destination
    Write-host "Updates has been copied to $Destination " -ForegroundColor Green
}
else
{
    Copy-Item -Path $updates -Recurse -Destination $Destination
    Write-host "Updates has been copied to $Destination " -ForegroundColor Green
}

# Sets timezone
Set-TimeZone -Name 'Central Standard Time' -PassThru

# Drivers
$driverPaths = @(
    "D:\Updates\HP830Drivers\sp135655 LAN.exe",
    "D:\Updates\HP830Drivers\sp135924 Audio.exe",
    "D:\Updates\HP830Drivers\sp136847 Graphics.exe",
    "D:\Updates\HP830Drivers\sp137116 WLAN.exe",
    "D:\Updates\HP830Drivers\sp102081 - Intel Video.exe",
    "D:\Updates\HP830Drivers\sp112848 Smart Card Reader.exe",
    "D:\Updates\HP830Drivers\sp99654 - Ethernet.exe"
)

foreach ($driverPath in $driverPaths)
{
    Write-Host "Installing $driverPath"
    Start-Process -FilePath "$driverPath" -ArgumentList "/s" -Wait -NoNewWindow
}

Write-Host "All drivers installed" -ForegroundColor Green

# Updates
$UpdatePath = "C:\Users\Admin\Desktop\Updates\MSU"

$Updates = Get-ChildItem -Path $UpdatePath -Recurse | Where-Object { $_.Name -like "*msu*" }

ForEach ($update in $Updates)
{
    $UpdateFilePath = $update.FullName
    write-host "Installing update $($update.BaseName)"
    Start-Process -wait wusa -ArgumentList "/update $UpdateFilePath", "/quiet", "/norestart"
}
Write-Host "Updates installed" -ForegroundColor Green

# UpdateCabs
$updatecab = "D:\Updates\CABS"

$updatecabs = @(
    "D:\Updates\CABS\windows10.0-kb5001716-x64_af2a11098441f139526b0fd085ed3ac8a5a196f0.cab"
)

foreach ($updatecab in $updatecabs)
{
    Write-Host "Installing $updatecab"
    # Installs Cab using the -Online parameter because it means that the package is installed on the running operating system. 
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command Add-WindowsPackage -Online -PackagePath $updatecab"
}

Write-Host "All updatecabs installed" -ForegroundColor Green

## Needs further testing..
# # Function to install driver from INF file
# Function Install-Driver
# {
#     param (
#         [string]$infFile
#     )
#     pnputil /add-driver $infFile /install
# }

# # Define the root directory containing the driver folders
# $rootDir = "D:\Updates\Manual Driver"

# # Get all subdirectories under the root directory
# $directories = Get-ChildItem -Path $rootDir -Directory

# # Iterate through each subdirectory
# foreach ($dir in $directories)
# {
#     # Get the INF file in the current subdirectory
#     $infFile = Get-ChildItem -Path $dir.FullName -Recurse -Filter *.inf
    
#     # If an INF file is found, install the driver
#     if ($infFile)
#     {
#         # In case there are multiple INF files, this loop will handle them
#         foreach ($file in $infFile)
#         {
#             Write-Host "Installing driver from $($file.FullName)" -ForegroundColor Green
#             Install-Driver -infFile $file.FullName
#         }
#     }
#     else
#     {
#         Write-Host "No INF file found in $($dir.FullName)" -ForegroundColor Red
#     }
# }

# Define the directory containing the executable files
$exeDir = "D:\Updates\MISC"

# Get all executable files in the directory
$exeFiles = Get-ChildItem -Path $exeDir -Filter *.exe

# Iterate through each executable file
foreach ($exeFile in $exeFiles) {
    Write-Host "Installing $($exeFile.Name)" -ForegroundColor Green
    # Check if the executable file is the specific one that requires the /q switch
    if ($exeFile.Name -eq "windows-kb890830-x64-v5.118_1898d7783231ed14970911d2c4dd815be13e2a4a.exe") {
        # Start the executable with the /q switch for silent installation
        Start-Process -FilePath $exeFile.FullName -ArgumentList "/q" -NoNewWindow -Wait
    } else {
        # Start the executable with the /s switch for silent installation
        Start-Process -FilePath $exeFile.FullName -ArgumentList "/s" -NoNewWindow -Wait
    }
}


# Pass Expire
if (Test-Path $PassExpirePath) 
{
    Remove-Item -Path $PassExpirePath -Force -Recurse
    Copy-Item -Path $UsbPath -Recurse -Destination $Destination
    (Get-ChildItem $Destination -Recurse).FullName
}
else
{
    Copy-Item -Path $UsbPath -Recurse -Destination $Destination
    (Get-ChildItem $Destination -Recurse).FullName
}
Start-Sleep -Seconds 5
Move-Item -Path 'C:\Users\admin\Desktop\PassExpire\PasswordExpire.ps1' -Destination $Destination 
Move-Item -Path 'C:\Users\admin\Desktop\PassExpire\TaskPasswordExpire.ps1' -Destination $Destination 
Remove-Item -Path $PassExpirePath -Recurse

# TaskPasswordExpire
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
Start-Sleep -Seconds 4

# RealTimeClock Expire
if (Test-Path $RealTimeClockPath) 
{
    Remove-Item -Path $RealTimeClockPath -Force -Recurse
    Copy-Item -Path $RTCPath -Recurse -Destination $Destination
    (Get-ChildItem $Destination -Recurse).FullName
}
else
{
    Copy-Item -Path $RTCPath -Recurse -Destination $Destination
    (Get-ChildItem $Destination -Recurse).FullName
}
Start-Sleep -Seconds 5
Move-Item -Path 'C:\Users\admin\Desktop\RealTimeClock\RTC.ps1' -Destination $Destination 
Move-Item -Path 'C:\Users\admin\Desktop\RealTimeClock\RTC.xml' -Destination $Destination
Move-Item -Path 'C:\Users\admin\Desktop\RealTimeClock\TaskRTC.ps1' -Destination $Destination 
Remove-Item -Path $RealTimeClockPath -Recurse

Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskRTC"
Write-Host "TaskRTC has been created" -ForegroundColor Green
Start-Sleep -Seconds 4
Remove-Item -Path 'C:\Users\admin\Desktop\RTC.xml' -Force
Write-Host "TaskRTC.xml has been removed"  -ForegroundColor Green

# Flip Me
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
Write-Host "Flipping is done" -ForegroundColor Green
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $WindowsBlocker"

# UAC Enabled
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5
Write-Host "UAC Enabled" -ForegroundColor Green

# Set the "Turn off display after" and "Sleep after" settings to 10 minutes for the "Plugged in" power plan, and 5 minutes for the "On battery" power plan.
powercfg -change -monitor-timeout-ac 10
powercfg -change -standby-timeout-ac 10
powercfg -change -monitor-timeout-dc 5
powercfg -change -standby-timeout-dc 5

# Sets brightness to 100%
(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)
Read-Host "Press Enter to Exit"