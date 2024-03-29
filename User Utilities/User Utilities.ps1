# Created By Anthony
# User Utilities v1.2.9
# This script is used to reset the password, time zone and network adapter for a user. It assumes the user has been granted the required permissions to execute the functions.
# Run PowerShell as Admin.

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

#Variables
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$TaskPass = Join-Path $Destination 'TaskPasswordExpire.ps1'
$PassExpirePath = Join-Path $Destination 'PassExpire'
$passfilePath = Join-Path $Destination 'PasswordExpire.ps1'
$taskfilePath = Join-Path $Destination 'TaskPasswordExpire.ps1'
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$oldtaskexpire = Join-Path $Destination 'Task Password Expire.ps1'
$PTaskName = "PassExpire"


# Gets the student account
$Student = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
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
    Write-Host "11) Notfication"
    Write-Host "12) Qr Code"
}

Try
{
    # This function resets the password of the user to 'Student' and sets it to require a change at next login.
    function Reset-Password
    {
        Param([string]$Student)
        # Sets the Password Never Expires to false to ensure logonpasswordchg can be set
        Set-LocalUser -Name $Student -PasswordNeverExpires $False
        # Resets the password of the user to 'Student'
        net user $Student "Student" /logonpasswordchg:yes
        Write-Host "Password for user $Student has been reset to 'Student' and set to user must change password at next login" -ForegroundColor Green
        $promptpass = Read-Host -Prompt "Do you want to set passexpire script and scheduled task? (Y/N)"
        if ($promptpass -eq "Y")
        {
            if (Test-Path $PassExpirePath) 
            {
                Write-Host "Removing existing $PassExpirePath..." -ForegroundColor Yellow
                Remove-Item $PassExpirePath -Force -Recurse
            }
            Copy-Item $UsbPath -Destination $Destination -Force -Recurse
            Get-ChildItem $Destination -Recurse | Select-Object -ExpandProperty FullName

            # Copies PasswordExpire.ps1
            if (!(Test-Path $passfilePath -PathType Leaf))
            {
                Write-Host "Copying PasswordExpire.ps1 to $Destination..." -ForegroundColor Green
                Copy-Item (Join-Path $PassExpirePath 'PasswordExpire.ps1') $Destination -Force
            }
            else 
            {
                Write-Host "Removing existing $passfilePath..." -ForegroundColor Yellow
                Remove-Item $passfilePath -Force -Recurse
                Copy-Item (Join-Path $PassExpirePath 'PasswordExpire.ps1') $Destination -Force
            }
            # Checks for old task password expire file that has a space in the name
            if (Test-Path $oldtaskexpire) 
            {
                Write-Host "Removing existing Old Task Password Expire" -ForegroundColor Yellow
                Remove-Item -Path $oldtaskexpire -Force -Recurse
            }
            else
            {
                Write-Host "Old Task Password Expire file does not exist." -ForegroundColor Green
            }
            # Copies TaskPasswordExpire.ps1
            if (!(Test-Path $taskfilePath -PathType Leaf))
            {
                Write-Host "Copying TaskPasswordExpire.ps1 to $Destination..." -ForegroundColor Green
                Copy-Item (Join-Path $PassExpirePath 'TaskPasswordExpire.ps1') $Destination -Force
            }
            else 
            {
                Write-Host "Removing existing $taskfilePath..." -ForegroundColor Yellow
                Remove-Item $taskfilePath -Force -Recurse
                Copy-Item (Join-Path $PassExpirePath 'TaskPasswordExpire.ps1') $Destination -Force
            }
            # Removes PassExpire Desktop Folder
            Remove-Item -Path $PassExpirePath -Recurse -Force
            Write-Host "PassExpire Folder has been removed" -ForegroundColor Green
            # Check if the scheduled task exists
            $Task = Get-ScheduledTask -TaskName $PTaskName -ErrorAction SilentlyContinue

            if ($Task)
            {
                # If the task exists, delete it
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
            # Run the TaskPasswordExpire script.
            Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
            Write-Host "Password Expire is done" -ForegroundColor Green
        }
        else 
        {
            Write-Host "Done"
        }
    }

    # This function sets the Real Time Clock to 'Central Standard Time'
    function Reset-TimeZone
    {
        # Sets the Real Time Clock to 'Central Standard Time'
        Set-TimeZone -Name 'Central Standard Time' -PassThru
        Write-Host "Timezone has been set to CST" -ForegroundColor Green
    }

    # This function resets the network adapter, clears the DNS cache and releases/renews IP configuration
    function Reset-NetworkAdapter
    {
        Restart-NetAdapter -Name "Wi*"
        Write-Host "Network adapter restarted" -ForegroundColor Green
        # Clears Dns Cache
        Clear-DnsClientCache
        Start-Sleep -Seconds 5
        ipconfig /flushdns
        Write-Host "Flushed DNS" -ForegroundColor Green
        # Release and Renew the ip configuration
        Start-Sleep -Seconds 5
        ipconfig /Release
        Start-Sleep -Seconds 5
        ipconfig /Renew
        Write-Host "IP configuration renew & released!" -ForegroundColor Green
        netsh winsock reset
        Start-Sleep -Seconds 5
        netcfg -d
        Write-Host "Network adapter has been Reset" -ForegroundColor Green
        Start-Sleep -Seconds 4
        Restart-Computer -force
    }
    
    function Install-SoundDriver
    {
        $drivers1 = "D:\Updates\HP830Drivers\sp135924 Audio.exe"
        $drivers2 = "D:\Drivers\sp102373 -Audio.exe"
    
        if (Test-Path $drivers1) 
        {
            Start-Process -FilePath $drivers1 -ArgumentList "/s" -Wait
            Write-Output "Sound Driver Installed from first path"
        }
        elseif (Test-Path $drivers2) 
        {
            Start-Process -FilePath $drivers2 -ArgumentList "/s" -Wait
            Write-Output "Sound Driver Installed from second path"
        }
        else 
        {
            Write-Output "Failed to install sound driver: files not found at either path"
        }
    }
    
    function Add-User
    {
        #Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -like 'STU*' } | Remove-CimInstance
        $in = Read-host "Enter Student Account Name"
        #$Password = Read-Host -AsSecureString
        $StuPassword = "Student" | ConvertTo-SecureString -AsPlainText -Force
        New-LocalUser -Name "$in" -Description "$in" -Password $StuPassword -Verbose
        Add-LocalGroupMember -Group "Users" -Member "$in"
        Set-LocalUser -Name "$in"
        net user $in /logonpasswordchg:yes
        PAUSE
    }

    function Remove-User
    {
        # List all local users and prompt the user to select a user to delete
        $users = Get-LocalUser | Select-Object Name | Sort-Object Name
        Write-Host "The following local users are found on this computer:"
        $i = 1
        foreach ($user in $users)
        {
            Write-Host "$i) $($user.Name)"
            $i++
        }

        $userToDelete = Read-Host "Enter the number of the user you wish to delete"
        if ([int]$userToDelete -ge 1 -and [int]$userToDelete -le $users.Count)
        {
            $user = $users[[int]$userToDelete - 1]
            $user = $user.Name
            Write-Host "You have selected user '$user' to delete"
            $confirm = Read-Host "Are you sure you want to delete user '$user'? (Y/N)"
            if ($confirm -eq "Y")
            {
                Remove-LocalUser -Name $user -Confirm:$false
                Write-Host "User '$user' has been deleted"
            }
            else
            {
                Write-Host "User '$user' has not been deleted"
            }
        }
        else
        {
            Write-Host "Invalid input. Please enter a number between 1 and $($users.Count)"
        }
    }
    function Install-SmartCardDriver
    {
        # Install Smart Card Driver
        $smartcarddrivers = "D:\Drivers\sp98312 - Smart Card Reader.exe"
        Start-Process -FilePath $smartcarddrivers -ArgumentList "/s" -Wait
        Write-Output "Smart Card Driver Installed"
        $opencert = Read-Host -Prompt "Do you want to open the Certficates? (Y/N)"
        if ($opencert -eq "Y")
        {
            rundll32.exe shell32.dll, Control_RunDLL inetcpl.cpl, 1, 3
        }
        else
        {
            Write-Host "Done"
        }
    }
    function Reset-Program
    {
        # Uninstall Chrome
        $chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        Start-Process -FilePath $chromePath -ArgumentList "/uninstall" -Wait

        # Delete Chrome installation folder
        $chromeFolder = "C:\Program Files (x86)\Google\Chrome"
        Remove-Item -Path $chromeFolder -Recurse -Force
    
        # Delete Chrome registry keys
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

        # Prompt user to choose installation type
        $installType = Read-Host "Enter installation type (online/offline)"

        if ($installType -eq "offline")
        {
            # Install Chrome offline
            $chromeInstaller = "D:\Software\Current_Software\ChromeStandaloneSetup64.exe"
            if (Test-Path $chromeInstaller)
            {
                # Install Chrome offline
                Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
            }
            else
            {
                Write-Host "Chrome offline installer not found at $chromeInstaller"
            }
        }
        else
        {
            # Download and install latest version of Chrome
            $chromeUrl = "https://dl.google.com/chrome/install/standalone/GoogleChromeStandaloneEnterprise64.msi"
            $chromeInstaller = "$env:TEMP\ChromeInstaller.msi"
            Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $chromeInstaller /quiet" -Wait
        }
    }
    # LockDown Browser update
    function Install-LockDownBrowser
    {
        #Lockdown Browser
        $OldLockdownPath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab"
        $Lockdown2Path = "D:\Software\Lockdown Browser\LockDownBrowserLab-2-1-0-01.zip"
        $LockdownDestinationPath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab 2"
        $Lockdown2ExePath = "C:\Program Files (x86)\Respondus\LockDown Browser Lab 2\LockDownBrowserLab-2-1-0-01\LockDownBrowserLab.exe"

        # Respondus® LockDown Browser
        if (!(Test-Path $OldLockdownPath))
        {
            Write-Host "Installing Respondus® LockDown Browser..." -ForegroundColor Red
            Start-Process msiexec.exe -Wait -ArgumentList '/i C:\Users\Admin\Desktop\Software\Current_Software\LockDown_Browser\Lockdown.msi /quiet /norestart'
            Write-Host "Installed Respondus® LockDown Browser" -ForegroundColor Green
        }
        else
        {
            Write-Host "Respondus® LockDown Browser is already installed." -ForegroundColor Green
        }
        Start-Sleep -Seconds 5
        #Delete old shortcut
        $ShortcutPath = "$env:USERPROFILE\Desktop\LockDown Browser 2 Lab.lnk"
        if (Test-Path $ShortcutPath)
        {
            Remove-Item $ShortcutPath -Force
        }
        else
        {
            Write-Host "Shortcut not found on user's desktop."
        }
        Start-Sleep -Seconds 5
        $ShortcutPath1 = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus\LockDown Browser 2 Lab.lnk"
        if (Test-Path $ShortcutPath1)
        {
            Remove-Item $ShortcutPath1 -Force
            Write-Host "Second Shortcut successfully deleted."
        }
        else
        {
            Write-Host "Second Shortcut not found at the specified location."
        }

        Start-Sleep -Seconds 5
        $PublicDesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonDesktopDirectory)
        $ShortcutPath = "$PublicDesktopPath\LockDown Browser 2 Lab.lnk"
        if (Test-Path $ShortcutPath)
        {
            Remove-Item $ShortcutPath -Force
        }
        else
        {
            Write-Host "Shortcut not found on public desktop."
        }

        # Respondus® LockDown Browser 2
        if (!(Test-Path $Lockdown2ExePath))
        {
            Write-Host "Installing Respondus® LockDown Browser..." -ForegroundColor Red
    
            # Ensure the destination directory exists
            if (-not (Test-Path $LockdownDestinationPath))
            {
                New-Item -ItemType Directory -Path $LockdownDestinationPath
            }

            # copy the zip to $LockdownDestinationPath
            Copy-Item -Path $Lockdown2Path -Destination $LockdownDestinationPath
            Start-Sleep -Seconds 5

            # unzip the zip
            $ZipDestination = Join-Path $LockdownDestinationPath "LockDownBrowserLab-2-1-0-01.zip"
            if (Test-Path $ZipDestination)
            {
                Expand-Archive -Path $ZipDestination -DestinationPath $LockdownDestinationPath
                Start-Sleep -Seconds 5

                # delete the zip
                Remove-Item -Path $ZipDestination
                Start-Sleep -Seconds 5
            }
            else
            {
                Write-Host "Failed to copy the ZIP file." -ForegroundColor Red
            }

            # Create Desktop Shortcut for Lockdown Browser
            $shell = New-Object -ComObject WScript.Shell
            $shortcut2 = $shell.CreateShortcut("$env:USERPROFILE\..\Public\Desktop\LockDown Browser Lab 2.lnk")
            $shortcut2.TargetPath = $Lockdown2ExePath
            $shortcut2.Save()
            Write-Host "Installed Respondus® LockDown Browser 2" -ForegroundColor Green

            $StartMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Respondus LockDown Browser 2 Lab.lnk"
            $shell2 = New-Object -ComObject WScript.Shell
            $Shortcut3 = $shell2.CreateShortcut($StartMenuPath)
            $Shortcut3.TargetPath = $Lockdown2ExePath
            $Shortcut3.Save()

            Write-Host "Created shortcut for Respondus® LockDown Browser 2" -ForegroundColor Green
        }
        else
        {
            Write-Host "Respondus® LockDown Browser is already installed." -ForegroundColor Green
        }
    }

    # Removes the request notification from the web browsers
    function Remove-Notfication 
    {
        if ((Test-Path -LiteralPath "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome") -ne $true)
        { 

            New-Item "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome" -force -ea SilentlyContinue 
        }
        if ((Test-Path -LiteralPath "Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge") -ne $true)
        { 
            
            New-Item "Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge" -force -ea SilentlyContinue 
        }
        New-ItemProperty -LiteralPath 'Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord
        New-ItemProperty -LiteralPath 'Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord
        # Reset Chrome and Edge settings
        # Note: You'll need to identify the correct registry keys or command-line methods for resetting these settings.
        # As a placeholder, I'll use registry paths but they might not correspond to actual reset settings. 
        # Set-ItemProperty -Path "Path_to_Chrome_Reset_Settings" -Name "PropertyName" -Value "Value"
        # Set-ItemProperty -Path "Path_to_Edge_Reset_Settings" -Name "PropertyName" -Value "Value"

        # Clear temp
        $tempPath = $env:TEMP
        Get-ChildItem -Path $tempPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

        # Read-host check extensions for malware
        $userInput = Read-Host -Prompt "Please check your extensions for malware. Press enter when done."

        # Handle site permissions (notifications blocked for URLs)
        # Again, you'd need to identify the right registry keys or methods to implement this. Placeholder code below.
        # Set-ItemProperty -Path "Path_to_Site_Permissions" -Name "NotificationsBlockedForUrls" -Value "BlockedValue"
    }

    function New-QrCode
    {
        Import-Module QRCodeGenerator
        $inputText = Read-Host "Enter the text you want to convert to QR Code [Serial Number]"
        $outputDirectory = $HOME

        # Ensure output directory exists
        if (-not (Test-Path -Path $outputDirectory))
        {
            New-Item -ItemType Directory -Path $outputDirectory
        }
        
            $outputFilePath = Join-Path $outputDirectory "qr_$inputText.png"
            New-PSOneQRCodeText -Text $inputText -Width 50 -OutPath $outputFilePath
            Write-Host "QR Code Generated saved to $outputDirectory" -ForegroundColor Green
    }

    # The options menu provides the user with a choice of functions. Depending on the option chosen, the appropriate function is run.
    Try
    {
        while ($true)
        {
            Show-Menu
            $userinput = Read-Host "Enter your choice"

            switch ($userinput)
            {
                '1'
                {
                    Reset-Password $Student
                    PAUSE
                }
                '2'
                {
                    Set-LocalUser -Name $Student -PasswordNeverExpires $True
                    Write-Host "Password has been set to not expire" -ForegroundColor Green
                    PAUSE
                }
                '3'
                {
                    Reset-TimeZone
                    PAUSE
                }
                '4'
                {
                    Reset-NetworkAdapter
                    PAUSE
                }
                '5'
                {
                    Add-User
                    PAUSE
                }
                '6'
                {
                    Remove-User
                    PAUSE
                }
                '7'
                {
                    Install-SmartCardDriver
                    PAUSE
                }
                '8'
                {
                    Install-SoundDriver
                    PAUSE
                }
                '9'
                {
                    Reset-Program
                    PAUSE
                }
                '10'
                {
                    Install-LockDownBrowser
                    PAUSE
                }
                '11'
                {
                    Remove-Notfication
                    PAUSE
                }
                '12'
                {
                    New-QrCode
                    PAUSE
                }
                default
                {
                    Write-Host "Invalid input. Please enter a valid option." -ForegroundColor Red
                }
            }
            $exit = Read-Host "Do you want to exit? (Y/N)"
            if ($exit -eq 'Y')
            {
                exit
            }
            else 
            {
                Clear-Host # Clear the console
                # The options will be refreshed in the next iteration of the while loop
            }
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Something went wrong. Error message: $ErrorMessage" -ForegroundColor Red
    }
}
Catch
{
    Write-Host 'Error Detected!'
    Write-Host $Error[0].Exception
}
PAUSE
