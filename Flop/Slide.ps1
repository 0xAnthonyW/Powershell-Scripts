#V0.2.4
#Needs Testing, Added User Group "Students" and adds the student to it (to work with passexpire and have checks)
#todo add more detection for virus detection
#Sets ExecutionPolicy
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Set up some variables for the script.
$TaskPass = 'C:\Users\admin\Desktop\TaskPasswordExpire.ps1'
$flipme = 'C:\Users\admin\Desktop\Software\FlipMe.ps1'
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = Join-Path $Destination 'PassExpire'
$passfilePath = Join-Path $Destination 'PasswordExpire.ps1'
$taskfilePath = Join-Path $Destination 'TaskPasswordExpire.ps1'
$software = 'D:\Software'
$softwareDestination = 'C:\Users\admin\Desktop\Software'
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$exePath = "C:\Users\$user\`Wavesor Software`\SWUpdater\SWUpdater.exe"
$taskName = 'Wavesor*'
$tasks = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$UsernamePrefix = "STU"
$GroupName = "Students"

# Disable the "Turn off display after" and "Sleep after" settings for both power plans.
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0

#Sets brightness to 100%
(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)

if ($tasks)
{
    Write-Host "The following tasks were found with the name '$taskName':" -ForegroundColor Yellow
    $tasks | ForEach-Object 
    {
        Write-Host $_.TaskName

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
    Write-Host "No tasks were found with the name '$taskName'." -ForegroundColor Green
    
    # Check if the SWUpdater.exe file exists in the user's profile folder. If it does, prompt for admin interaction.
    if (Test-Path $exePath)
    {
        Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
        Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
    }
    else
    {
        Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green

        #     # If the PassExpire folder exists, remove it and copy the files from the USB to the destination folder.
        #     if (Test-Path $PassExpirePath) 
        #     {
        #         Remove-Item -Path $PassExpirePath -Force -Recurse
        #         Copy-Item -Path $UsbPath -Recurse -Destination $Destination -Force
        # (Get-ChildItem $Destination -Recurse).FullName
        #     }
        #     else
        #     {
        #         Copy-Item -Path $UsbPath -Recurse -Destination $Destination -Force
        # (Get-ChildItem $Destination -Recurse).FullName
        #     }

        # If the software folder exists, remove it and copy the files from the USB to the destination folder.
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
        ##Testing
        # Remove and replace PassExpire folder with copy from USB
        if (Test-Path $PassExpirePath) 
        {
            Write-Host "Removing existing $PassExpirePath..." -ForegroundColor Yellow
            Remove-Item $PassExpirePath -Force -Recurse
        }
        Copy-Item $UsbPath -Destination $Destination -Force -Recurse
        Get-ChildItem $Destination -Recurse | Select-Object -ExpandProperty FullName

        # Copy PasswordExpire.ps1 if it doesn't exist
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

        # Copy TaskPasswordExpire.ps1 if it doesn't exist
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
        # Run the TaskPasswordExpire script.
        Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
        Write-Host "Password Expire is done" -ForegroundColor Green
        Start-Sleep -Seconds 5

        # Check if the group exists, and create it if not
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

        $GroupMembers = $Group | Get-LocalGroupMember | Select-Object -ExpandProperty Name

        $Users = Get-LocalUser | Where-Object { $_.Name -like "$UsernamePrefix*" }

        foreach ($user in $Users)
        {
            if ($GroupMembers -contains $user.Name)
            {
                continue
                Write-Output "User $user.Name is already a member of $GroupName"
            }
            elseif ($null -ne $user.Name -and "" -ne $user.Name)
            {
                # Add user to the 'Students' group
                Add-LocalGroupMember -Group $Group -Member $user.Name
                Write-Output "Added $user.Name to $GroupName"
            }
        }
        
        # Empty the Recycle Bin.
        Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas -ArgumentList { /c rd /s /q c:\$Recycle.bin }
        Write-host "Recyclebin Cleared" -ForegroundColor Green
        
        # Run the FlipMe script.
        Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
        Read-Host "Flipping is done. Press Enter to Exit" -ForegroundColor Green
        
        # Set the "Turn off display after" and "Sleep after" settings to 10 minutes for the "Plugged in" power plan, and 5 minutes for the "On battery" power plan.
        powercfg -change -monitor-timeout-ac 10
        powercfg -change -standby-timeout-ac 10
        powercfg -change -monitor-timeout-dc 5
        powercfg -change -standby-timeout-dc 5

        #Sets brightness to 100%
        (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 100)
        Read-Host "All done press enter to exit"
        ## not done more to be done almost fully automated
    }
}
