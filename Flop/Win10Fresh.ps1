## dont run as admin
## work in progress more to add havent ran this yet
## todo maybe work on recycle bin again...
$TaskPass = 'C:\Users\admin\Desktop\TaskPasswordExpire.ps1'
$flipme = 'C:\Users\admin\Desktop\Software\FlipMe.ps1'
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire'
$usrAccount = 'D:\UserAccount.ps1'
$software = 'D:\Software'
$softwareDestination = 'C:\Users\admin\Desktop\Software'
$updates = 'D:\Updates'
$updatesDestination = 'C:\Users\admin\Desktop\Updates'
$Drivers = 'C:\Users\admin\Desktop\Updates\Scripts\830Drivers.bat'
$MSU = 'D:\Updates\Scripts\MSU.ps1'
$WindowsBlocker = 'C:\Users\admin\Desktop\Software\Updated-By-Anthony\WindowsBlocker-V1-2.ps1'
# UserAccount
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $usrAccount"
Start-Sleep -Seconds 10
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
Start-Process -FilePath "$Drivers"-Wait -NoNewWindow
# Start-Sleep -Seconds 20
Write-Host "Drivers installed" -ForegroundColor Green
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $MSU"
Write-Host "Updates installed" -ForegroundColor Green
## Pass Expire
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
##TaskPasswordExpire
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
Start-Sleep -Seconds 10
##Flip Me
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
Write-Host "Flipping is done" -ForegroundColor Green
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $WindowsBlocker"
Read-Host "All done press enter to exit"
## copy updated by anthony
## not done more to be done almost fully automated