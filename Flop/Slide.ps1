# Created By Anthony
# Slide V0.4.2
# Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
# Disable User Account Control (UAC) consent prompt.
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
Write-Host "UAC DISABLED"

# Set up some variables for the script.
$UsbPath = 'D:\PassExpire'
$WindowsBlocker = 'D:\Win11Blocker\WindowsBlocker.ps1'
$software = 'D:\Software'
$Destination = 'C:\Users\admin\Desktop'
$TaskPass = Join-Path $Destination 'TaskPasswordExpire.ps1'
$flipme = Join-Path $Destination 'Software\FlipMe.ps1'
$PassExpirePath = Join-Path $Destination 'PassExpire'
$passfilePath = Join-Path $Destination 'PasswordExpire.ps1'
$taskfilePath = Join-Path $Destination 'TaskPasswordExpire.ps1'
$softwareDestination = Join-Path $Destination 'Software'
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$exePath = "C:\Users\$user\`Wavesor Software`\SWUpdater\SWUpdater.exe"
$WTaskName = 'Wavesor*'
$tasks = Get-ScheduledTask -TaskName $WTaskName -ErrorAction SilentlyContinue
$oldtaskexpire = Join-Path $Destination 'Task Password Expire.ps1'
$UsernamePrefix = "STU"
$GroupName = "Student"
$PTaskName = "PassExpire"
$AdminAccount = "admin"
$mswordexe = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
$mswordexe2 = "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE"
$mswordexe3 = "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"

# Disable the "Turn off display after" and "Sleep after" settings for both power plans.
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0

# Sets the administrator account password to never expire.
Set-LocalUser -Name $AdminAccount  -PasswordNeverExpires $True

#Sets brightness to 100%
(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)

if ($tasks)
{
    Write-Host "The following tasks were found with the name '$WTaskName':" -ForegroundColor Yellow
    $tasks | ForEach-Object {
        Write-Host $_.TaskName
        # Enable User Account Control (UAC) consent prompt.
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5
        
        # Check if the SWUpdater.exe file exists in the user's profile folder. If it does, prompt for admin interaction.
        if (Test-Path $exePath)
        {
            Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
            Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
        }
        else
        {
            Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green
        }
    }
    Read-Host "Press Enter to continue."
}
else
{
    Write-Host "No tasks were found with the name '$WTaskName'." -ForegroundColor Green
    
    # Check if the SWUpdater.exe file exists in the user's profile folder. If it does, prompt for admin interaction.
    if (Test-Path $exePath)
    {
        Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
        Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
    }
    else
    {
        Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green
        #main
        #Moves Software to Desktop
        if (Test-Path $softwareDestination) 
        {
            Remove-Item -Path $softwareDestination -Force -Recurse
            Copy-Item -Path $software -Recurse -Destination $Destination -Force
            Write-host "Software has been copied to $Destination " -ForegroundColor Green
        }
        else
        {
            Copy-Item -Path $software -Recurse -Destination $Destination -Force
            Write-host "Software has been copied to $Destination " -ForegroundColor Green
        }
        
        # Set the system's timezone to Central Standard Time.
        Set-TimeZone -Name 'Central Standard Time' -PassThru
        Write-Host "Timezone has been set to CST" -ForegroundColor Green
        Start-Sleep -Seconds 4
        # Remove and replace PassExpire folder with copy from USB
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
        Start-Sleep -Seconds 5
        # Check if the Student group exists, and create it if not
        try
        {
            $Group = Get-LocalGroup -Name $GroupName -ErrorAction Stop
            Write-Output "Group $GroupName exists"
        }
        catch
        {
            $Group = New-LocalGroup -Name $GroupName
            Write-Output "Created group $GroupName"
        }

        $Users = Get-LocalUser | Where-Object { $_.Name -like "$UsernamePrefix*" }

        # Adds the STU to the Student Group 
        foreach ($user in $Users)
        {
            try
            {
                # Check if the user is directly or indirectly a member of the group
                Get-LocalGroupMember -Group $GroupName -Member $user.Name -ErrorAction Stop
                Write-Output "User $($user.Name) is already a member of $GroupName"
            }
            catch
            {
                if ($null -ne $user.Name -and "" -ne $user.Name)
                {
                    # Add user to the 'Students' group
                    Add-LocalGroupMember -Group $Group -Member $user.Name
                    Write-Output "Added $($user.Name) to $GroupName"
                }
            }
        }
        
        # Empty the Recycle Bin.
        Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas -ArgumentList { /c rd /s /q c:\$Recycle.bin }
        Write-host "Recyclebin Cleared" -ForegroundColor Green
        
        # Run the FlipMe script.
        Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
        Write-Host "Flipping is done" -ForegroundColor Green
        # Checks the Version of Windows if its 22H2
        $registryPaths = @{
            "Path1" = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion";
            "Path2" = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion"
        }
        
        function Get-DisplayVersion ($registryPath)
        {
            $displayVersion = (Get-ItemProperty -Path $registryPath).DisplayVersion
            return $displayVersion
        }
        
        # Checks if the Display Versions match and are 22H2
        function Get-DisplayVersions($registryPaths) 
        {
            $displayVersions = @{}
        
            foreach ($entry in $registryPaths.GetEnumerator()) 
            {
                $displayVersions[$entry.Name] = Get-DisplayVersion -registryPath $entry.Value
            }
        
            return $displayVersions
        }
        $displayVersions = Get-DisplayVersions -registryPaths $registryPaths
        
        # Checks if the Display Versions match and are 22H2 and runs WindowsBlocker if they do
        if (($null -ne $displayVersions["Path1"]) -and ($null -ne $displayVersions["Path2"]))
        {
            if ($displayVersions["Path1"] -ieq $displayVersions["Path2"] -and $displayVersions["Path1"] -ieq "22H2") 
            {
                Write-Host "Both Display Versions match and are 22H2." -ForegroundColor Green
                Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $WindowsBlocker"
                Write-Host "WindowsBlocker is done." -ForegroundColor Green
            } 
            elseif ($displayVersions["Path1"] -ieq $displayVersions["Path2"])
            {
                Write-Host "Display Versions match but are not 22H2." -ForegroundColor Yellow
            }
            else
            {
                Write-Host "Display Versions Mismatch Detected. No further action needed" -ForegroundColor White
            }
        }

        # Checks if MS Word is installed and creates a shortcut on the desktop        
        if (Test-Path $mswordexe) 
        {
            Write-Host "MS Word is installed" -ForegroundColor Green
            $shell = New-Object -ComObject WScript.Shell
            #$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Word.lnk")
            $shortcut1 = $shell.CreateShortcut("$env:USERPROFILE\..\Public\Desktop\Word 2016.lnk")
            #$shortcut.TargetPath = $mswordexe
            $shortcut1.TargetPath = $mswordexe
            #$shortcut.Save()
            $shortcut1.Save()
        }
        elseif (Test-Path $mswordexe2) 
        {
            Write-Host "MS Word is installed" -ForegroundColor Green
            $shell = New-Object -ComObject WScript.Shell
            #$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Word.lnk")
            $shortcut1 = $shell.CreateShortcut("$env:USERPROFILE\..\Public\Desktop\Word 2016.lnk")
            #$shortcut.TargetPath = $mswordexe2
            $shortcut1.TargetPath = $mswordexe2
            #$shortcut.Save()
            $shortcut1.Save()
        }
        elseif (Test-Path $mswordexe3) 
        {
            Write-Host "MS Word is installed" -ForegroundColor Green
            $shell = New-Object -ComObject WScript.Shell
            #$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Word.lnk")
            $shortcut1 = $shell.CreateShortcut("$env:USERPROFILE\..\Public\Desktop\Word 2016.lnk")
            #$shortcut.TargetPath = $mswordexe3
            $shortcut1.TargetPath = $mswordexe3
            #$shortcut.Save()
            $shortcut1.Save()
        }
        else 
        {
            # If MS Word is not installed, it will install it
            Write-Host "MS Word is not installed" -ForegroundColor Yellow
            Start-Process -FilePath "C:\Users\admin\Desktop\Software\Current_Software\Office2016Client\SYSMAN_Office_2016_V2.1.5.iso"
        }
        

        # Enable User Account Control (UAC) consent prompt.
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5
        Read-Host "UAC Enabled Press Enter to Exit"
        
        # Set the "Turn off display after" and "Sleep after" settings to 10 minutes for the "Plugged in" power plan, and 5 minutes for the "On battery" power plan.
        powercfg -change -monitor-timeout-ac 10
        powercfg -change -standby-timeout-ac 10
        powercfg -change -monitor-timeout-dc 5
        powercfg -change -standby-timeout-dc 5

        #Sets brightness to 100%
        (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)
        Read-Host "All done press enter to exit"
    }
}

