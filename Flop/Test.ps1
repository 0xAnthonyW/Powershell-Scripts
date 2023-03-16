#reverted back, isnt being used was a Proof of Concept
#dont run as admin
$var = '.\Test2.ps1'
Start-Process Powershell "-ExecutionPolicy Bypass -File $var"
Read-Host "Can you see me"
PAUSE
