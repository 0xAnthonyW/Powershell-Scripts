#dont run as admin
#basically to replace test.ps1
#todo maybe work on recycle bin again...
$TaskPass = 'C:\Users\admin\Desktop\TaskPasswordExpire.ps1'
$flipme = 'C:\Users\admin\Desktop\Software\FlipMe.ps1'
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire'
$software = 'D:\Software'
$softwareDestination = 'C:\Users\admin\Desktop\Software'

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
#Software Folder
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
## Sets the Real Time Clock to 'Central Standard Time'
Set-TimeZone -Name 'Central Standard Time' -PassThru
Write-Host "Timezone has been set to CST" -ForegroundColor Green
##passwordexpire folder setup
Start-Sleep -Seconds 10
Move-Item -Path 'C:\Users\admin\Desktop\PassExpire\PasswordExpire.ps1' -Destination $Destination 
Move-Item -Path 'C:\Users\admin\Desktop\PassExpire\TaskPasswordExpire.ps1' -Destination $Destination 
Remove-Item -Path $PassExpirePath -Recurse
#main
##TaskPasswordExpire
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $TaskPass"
Write-Host "Password Expire is done" -ForegroundColor Green
Start-Sleep -Seconds 20
##Flip Me
Start-Process Powershell -Wait "-ExecutionPolicy Bypass -File $flipme"
Write-Host "Flipping is done" -ForegroundColor Green
Read-Host "All done press enter to exit"
## not done more to be done almost fully automated