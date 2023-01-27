#work in progress more to add
#todo add  task password expire and execute it, then run flip me. thats all for now. maybe work on recycle bin again...
#dont run as admin
# $var = '.\Test2.ps1'
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire'

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
PAUSE
# Start-Process Powershell "-ExecutionPolicy Bypass -File $var"
# Start-Sleep -Seconds 30
# Read-Host "Can you see me"