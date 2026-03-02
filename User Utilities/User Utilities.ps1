# Created By Anthony
# User Utilities v1.3.0
# This script is used to reset the password, time zone and network adapter for a user.
# It assumes the user has been granted the required permissions to execute the functions.
# Run PowerShell as Admin.

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Variables
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$TaskPass = Join-Path $Destination 'TaskPasswordExpire.ps1'
$PassExpirePath = Join-Path $Destination 'PassExpire'
$passfilePath = Join-Path $Destination 'PasswordExpire.ps1'
$oldtaskexpire = Join-Path $Destination 'Task Password Expire.ps1'
$PTaskName = "PassExpire"
$Student = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name

# Helper: Copy a file from source to destination, removing any existing copy first
function Copy-FileForce
{
    Param(
        [string]$Source,
        [string]$Dest,
        [string]$FileName
    )
    $destFile = Join-Path $Dest $FileName
    if (Test-Path $destFile)
    {
        Write-Host "Removing existing $destFile..." -ForegroundColor Yellow
        Remove-Item $destFile -Force
    }
    Write-Host "Copying $FileName to $Dest..." -ForegroundColor Green
    Copy-Item (Join-Path $Source $FileName) $Dest -Force
}

function Show-Menu
{
    Write-Host "Choose an option:"
    Write-Host "1) Reset Password"
    Write-Host "2) Set Password Never Expires"
    Write-Host "3) Reset Time Zone"
    Write-Host "4) Reset Network Adapter"
    Write-Host "5) Create User"
    Write-Host "6) Delete User"
    Write-Host "7) Smart Card Driver"
    Write-Host "8) Audio Driver"
    Write-Host "9) Reinstall Chrome"
    Write-Host "10) Lockdown Browser"
    Write-Host "11) Notification"
    Write-Host "12) Qr Code"
}

# This function resets the password of the user to 'Student' and sets it to require a change at next login.
function Reset-Password
{
    Param([string]$Student)
    Set-LocalUser -Name $Student -PasswordNeverExpires $False
    net user $Student "Student" /logonpasswordchg:yes
    Write-Host "Password for user $Student has been reset to 'Student' and set to user must change password at next login" -ForegroundColor Green

    $promptpass = Read-Host -Prompt "Do you want to set passexpire script and scheduled task? (Y/N)"
    if ($promptpass -ne "Y") { Write-Host "Done"; return }

    if (Test-Path $PassExpirePath)
    {
        Write-Host "Removing existing $PassExpirePath..." -ForegroundColor Yellow
        Remove-Item $PassExpirePath -Force -Recurse
    }
    Copy-Item $UsbPath -Destination $Destination -Force -Recurse

    Copy-FileForce -Source $PassExpirePath -Dest $Destination -FileName 'PasswordExpire.ps1'

    if (Test-Path $oldtaskexpire)
    {
        Write-Host "Removing existing Old Task Password Expire" -ForegroundColor Yellow
        Remove-Item -Path $oldtaskexpire -Force
    }

    Copy-FileForce -Source $PassExpirePath -Dest $Destination -FileName 'TaskPasswordExpire.ps1'

    Remove-Item -Path $PassExpirePath -Recurse -Force
    Write-Host "PassExpire Folder has been removed" -ForegroundColor Green

    $Task = Get-ScheduledTask -TaskName $PTaskName -ErrorAction SilentlyContinue
    if ($Task)
    {
        try
        {
            Unregister-ScheduledTask -TaskName $PTaskName -Confirm:$false
            Write-Host "Task '$PTaskName' has been deleted." -ForegroundColor Green
        }
        catch
        {
            Write-Host "Error: Unable to delete task '$PTaskName'." -ForegroundColor Red
            Read-Host "Press Enter to continue."
        }
    }
    else
    {
        Write-Host "Task '$PTaskName' not found." -ForegroundColor Green
    }

    Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
    Write-Host "Password Expire is done" -ForegroundColor Green
}

function Reset-TimeZone
{
    Set-TimeZone -Name 'Central Standard Time' -PassThru
    Write-Host "Timezone has been set to CST" -ForegroundColor Green
}

function Reset-NetworkAdapter
{
    Restart-NetAdapter -Name "Wi*"
    Write-Host "Network adapter restarted" -ForegroundColor Green
    Clear-DnsClientCache
    Start-Sleep -Seconds 3
    ipconfig /flushdns
    Write-Host "Flushed DNS" -ForegroundColor Green
    Start-Sleep -Seconds 3
    ipconfig /Release
    Start-Sleep -Seconds 3
    ipconfig /Renew
    Write-Host "IP configuration renew & released!" -ForegroundColor Green
    netsh winsock reset
    Start-Sleep -Seconds 3
    netcfg -d
    Write-Host "Network adapter has been Reset" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Restart-Computer -Force
}

function Install-SoundDriver
{
    $driverPaths = @(
        "D:\Updates\HP830Drivers\sp135924 Audio.exe",
        "D:\Drivers\sp102373 -Audio.exe"
    )

    foreach ($path in $driverPaths)
    {
        if (Test-Path $path)
        {
            Start-Process -FilePath $path -ArgumentList "/s" -Wait
            Write-Output "Sound Driver Installed from $path"
            return
        }
    }
    Write-Output "Failed to install sound driver: files not found at any path"
}

function Add-User
{
    $in = Read-Host "Enter Student Account Name"
    $StuPassword = "Student" | ConvertTo-SecureString -AsPlainText -Force
    New-LocalUser -Name "$in" -Description "$in" -Password $StuPassword -Verbose
    Add-LocalGroupMember -Group "Users" -Member "$in"
    Set-LocalUser -Name "$in"
    net user $in /logonpasswordchg:yes
    PAUSE
}

function Remove-User
{
    $users = Get-LocalUser | Select-Object Name | Sort-Object Name
    Write-Host "The following local users are found on this computer:"
    $i = 1
    foreach ($u in $users)
    {
        Write-Host "$i) $($u.Name)"
        $i++
    }

    $userToDelete = Read-Host "Enter the number of the user you wish to delete"
    if ([int]$userToDelete -lt 1 -or [int]$userToDelete -gt $users.Count)
    {
        Write-Host "Invalid input. Please enter a number between 1 and $($users.Count)" -ForegroundColor Red
        return
    }

    $selectedUser = $users[[int]$userToDelete - 1].Name
    Write-Host "You have selected user '$selectedUser' to delete"
    $confirm = Read-Host "Are you sure you want to delete user '$selectedUser'? (Y/N)"
    if ($confirm -eq "Y")
    {
        Remove-LocalUser -Name $selectedUser -Confirm:$false
        Write-Host "User '$selectedUser' has been deleted" -ForegroundColor Green
    }
    else
    {
        Write-Host "User '$selectedUser' has not been deleted"
    }
}

function Install-SmartCardDriver
{
    $smartcarddrivers = "D:\Drivers\sp98312 - Smart Card Reader.exe"
    Start-Process -FilePath $smartcarddrivers -ArgumentList "/s" -Wait
    Write-Output "Smart Card Driver Installed"
    $opencert = Read-Host -Prompt "Do you want to open the Certificates? (Y/N)"
    if ($opencert -eq "Y")
    {
        rundll32.exe shell32.dll, Control_RunDLL inetcpl.cpl, 1, 3
    }
}

function Reset-Program
{
    $chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    Start-Process -FilePath $chromePath -ArgumentList "/uninstall" -Wait

    $chromeFolder = "C:\Program Files (x86)\Google\Chrome"
    Remove-Item -Path $chromeFolder -Recurse -Force

    $chromeRegKeys = @(
        "HKCU:\Software\Google\Chrome",
        "HKCU:\Software\Policies\Google\Chrome",
        "HKLM:\Software\Google\Chrome",
        "HKLM:\Software\Policies\Google\Chrome",
        "HKLM:\Software\Policies\Google\Update",
        "HKLM:\Software\WOW6432Node\Google\Enrollment"
    )
    foreach ($key in $chromeRegKeys)
    {
        Remove-ItemProperty -Path $key -Name * -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    }

    $installType = Read-Host "Enter installation type (online/offline)"

    if ($installType -eq "offline")
    {
        $chromeInstaller = "D:\Software\Current_Software\ChromeStandaloneSetup64.exe"
        if (Test-Path $chromeInstaller)
        {
            Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
        }
        else
        {
            Write-Host "Chrome offline installer not found at $chromeInstaller" -ForegroundColor Red
        }
    }
    else
    {
        $chromeUrl = "https://dl.google.com/chrome/install/standalone/GoogleChromeStandaloneEnterprise64.msi"
        $chromeInstaller = "$env:TEMP\ChromeInstaller.msi"
        Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $chromeInstaller /quiet" -Wait
    }
}

function Install-LockDownBrowser
{
    $OldLockdownPath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab"
    $Lockdown2Path = "D:\Software\Lockdown Browser\LockDownBrowserLab-2-1-0-01.zip"
    $LockdownDestinationPath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab 2"
    $Lockdown2ExePath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab 2\LockDownBrowserLab-2-1-0-01\LockDownBrowserLab.exe"

    # Install original LockDown Browser if missing
    if (!(Test-Path $OldLockdownPath))
    {
        Write-Host "Installing Respondus LockDown Browser..." -ForegroundColor Red
        Start-Process msiexec.exe -Wait -ArgumentList '/i C:\Users\Admin\Desktop\Software\Current_Software\LockDown_Browser\Lockdown.msi /quiet /norestart'
        Write-Host "Installed Respondus LockDown Browser" -ForegroundColor Green
    }
    else
    {
        Write-Host "Respondus LockDown Browser is already installed." -ForegroundColor Green
    }

    # Remove old shortcuts
    $shortcutLocations = @(
        "$env:USERPROFILE\Desktop\LockDown Browser 2 Lab.lnk",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus\LockDown Browser 2 Lab.lnk",
        "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonDesktopDirectory))\LockDown Browser 2 Lab.lnk"
    )
    foreach ($shortcut in $shortcutLocations)
    {
        if (Test-Path $shortcut)
        {
            Remove-Item $shortcut -Force
            Write-Host "Removed shortcut: $shortcut" -ForegroundColor Yellow
        }
    }

    # Install LockDown Browser 2 if missing
    if (!(Test-Path $Lockdown2ExePath))
    {
        Write-Host "Installing Respondus LockDown Browser 2..." -ForegroundColor Red

        if (-not (Test-Path $LockdownDestinationPath))
        {
            New-Item -ItemType Directory -Path $LockdownDestinationPath | Out-Null
        }

        Copy-Item -Path $Lockdown2Path -Destination $LockdownDestinationPath
        $ZipDestination = Join-Path $LockdownDestinationPath "LockDownBrowserLab-2-1-0-01.zip"

        if (Test-Path $ZipDestination)
        {
            Expand-Archive -Path $ZipDestination -DestinationPath $LockdownDestinationPath
            Remove-Item -Path $ZipDestination
        }
        else
        {
            Write-Host "Failed to copy the ZIP file." -ForegroundColor Red
            return
        }

        # Create shortcuts
        $shell = New-Object -ComObject WScript.Shell

        $desktopShortcut = $shell.CreateShortcut("$env:USERPROFILE\..\Public\Desktop\LockDown Browser Lab 2.lnk")
        $desktopShortcut.TargetPath = $Lockdown2ExePath
        $desktopShortcut.Save()

        $startMenuShortcut = $shell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus LockDown Browser 2 Lab.lnk")
        $startMenuShortcut.TargetPath = $Lockdown2ExePath
        $startMenuShortcut.Save()

        Write-Host "Installed Respondus LockDown Browser 2" -ForegroundColor Green
    }
    else
    {
        Write-Host "Respondus LockDown Browser 2 is already installed." -ForegroundColor Green
    }
}

function Remove-Notification
{
    $regPaths = @(
        "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome",
        "Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge"
    )
    foreach ($regPath in $regPaths)
    {
        if (!(Test-Path -LiteralPath $regPath))
        {
            New-Item $regPath -Force -ErrorAction SilentlyContinue | Out-Null
        }
        New-ItemProperty -LiteralPath $regPath -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord -Force | Out-Null
    }

    Get-ChildItem -Path $env:TEMP -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    Read-Host -Prompt "Please check your extensions for malware. Press Enter when done."
}

function New-QrCode
{
    Import-Module QRCodeGenerator
    $inputText = Read-Host "Enter the text you want to convert to QR Code [Serial Number]"
    $outputFilePath = Join-Path $HOME "qr_$inputText.png"
    New-PSOneQRCodeText -Text $inputText -Width 50 -OutPath $outputFilePath
    Write-Host "QR Code Generated saved to $HOME" -ForegroundColor Green
}

# Main menu loop
try
{
    while ($true)
    {
        Show-Menu
        $userinput = Read-Host "Enter your choice"

        switch ($userinput)
        {
            '1'  { Reset-Password $Student; PAUSE }
            '2'  { Set-LocalUser -Name $Student -PasswordNeverExpires $True; Write-Host "Password has been set to not expire" -ForegroundColor Green; PAUSE }
            '3'  { Reset-TimeZone; PAUSE }
            '4'  { Reset-NetworkAdapter; PAUSE }
            '5'  { Add-User; PAUSE }
            '6'  { Remove-User; PAUSE }
            '7'  { Install-SmartCardDriver; PAUSE }
            '8'  { Install-SoundDriver; PAUSE }
            '9'  { Reset-Program; PAUSE }
            '10' { Install-LockDownBrowser; PAUSE }
            '11' { Remove-Notification; PAUSE }
            '12' { New-QrCode; PAUSE }
            default { Write-Host "Invalid input. Please enter a valid option." -ForegroundColor Red }
        }

        $exit = Read-Host "Do you want to exit? (Y/N)"
        if ($exit -eq 'Y') { exit }
        Clear-Host
    }
}
catch
{
    Write-Host "Something went wrong. Error message: $($_.Exception.Message)" -ForegroundColor Red
}
PAUSE
