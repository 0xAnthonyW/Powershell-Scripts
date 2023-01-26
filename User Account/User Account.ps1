#Created by Anthony
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
#Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -like 'STU*' } | Remove-CimInstance
$in = Read-host "Enter Student Account Name"
#$Password = Read-Host -AsSecureString
$StuPassword = "Student" | ConvertTo-SecureString -AsPlainText -Force
New-LocalUser -Name "$in" -Description "$in" -Password $StuPassword -Verbose
Add-LocalGroupMember -Group "Users" -Member "$in"
Set-LocalUser -Name "$in"
net user $in /logonpasswordchg:yes
PAUSE