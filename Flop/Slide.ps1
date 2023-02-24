#V0.2.2
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
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire'
$software = 'D:\Software'
$softwareDestination = 'C:\Users\admin\Desktop\Software'
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$exePath = "C:\Users\$user\`Wavesor Software`\SWUpdater\SWUpdater.exe"
$taskName = 'Wavesor*'
$tasks = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

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
        # If the PassExpire folder exists, remove it and copy the files from the USB to the destination folder.
        if (Test-Path $PassExpirePath) 
        {
            Remove-Item -Path $PassExpirePath -Force -Recurse
            Copy-Item -Path $UsbPath -Recurse -Destination $Destination -Force
    (Get-ChildItem $Destination -Recurse).FullName
        }
        else
        {
            Copy-Item -Path $UsbPath -Recurse -Destination $Destination -Force
    (Get-ChildItem $Destination -Recurse).FullName
        }
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
        
        # Move the PasswordExpire and TaskPasswordExpire scripts to the destination folder.
        Start-Sleep -Seconds 4
        
        # Move the PasswordExpire and TaskPasswordExpire scripts to the destination folder.
        Copy-Item -Path 'C:\Users\admin\Desktop\PassExpire\PasswordExpire.ps1' -Destination $Destination -Force
        Copy-Item -Path 'C:\Users\admin\Desktop\PassExpire\TaskPasswordExpire.ps1' -Destination $Destination -Force
        Remove-Item -Path $PassExpirePath -Recurse -Force

        # Run the TaskPasswordExpire script.
        Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
        Write-Host "Password Expire is done" -ForegroundColor Green
        Start-Sleep -Seconds 5
        
        # Empty the Recycle Bin.
        Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas -ArgumentList { /c rd /s /q c:\$Recycle.bin }
        Write-host "Recyclebin Cleared" -ForegroundColor Green
        
        # Run the FlipMe script.
        Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
        Write-Host "Flipping is done" -ForegroundColor Green
        
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
