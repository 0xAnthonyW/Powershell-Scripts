# Created By Anthony
# User Utilities v1.2.5
# This script is used to reset the password, time zone and network adapter for a user. It assumes the user has been granted the required permissions to execute the functions.
# Run PowerShell as Admin.

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

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
    Write-Host ""
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
        # Install Sound Driver
        $drivers = "D:\Drivers\sp102373 -Audio.exe"
        Start-Process -FilePath $drivers -ArgumentList "/s" -Wait
        Write-Output "Sound Driver Installed"
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
        #$smartcarddrivers = "D:\Drivers\sp98312 - Smart Card Reader.exe"
        #Start-Process -FilePath $smartcarddrivers -ArgumentList "/s" -Wait
        Write-Output "Smart Card Driver Installed"
       $opencert = Read-Host -Prompt "Do you want to open the Certficates? (Y/N)"
        if ($opencert -eq "Y") #fix
        {
            rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,1,3
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
            $chromeInstaller = "D:\Software\ChromeStandaloneSetup64.exe"
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
