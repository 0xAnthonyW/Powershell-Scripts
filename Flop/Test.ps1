#dont run as admin
#work in progress more to add
#todo maybe work on recycle bin again...
$var = 'C:\Users\admin\Desktop\PassExpire\TaskPasswordExpire.ps1'
$var2 = 'C:\Users\admin\Desktop\Software\FlipMe.ps1'
$UsbPath = 'D:\PassExpire'
$Destination = 'C:\Users\admin\Desktop'
$PassExpirePath = 'C:\Users\admin\Desktop\PassExpire' #PassExpire path is still set to desktop not in a folder

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
Start-Process Powershell "-ExecutionPolicy Bypass -File $var"
Start-Sleep -Seconds 20
Start-Process Powershell "-ExecutionPolicy Bypass -File $var2"
PAUSE