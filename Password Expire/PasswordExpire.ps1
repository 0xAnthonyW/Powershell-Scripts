#Created by Anthony
# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
# {
#     Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
# }
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
Set-LocalUser -Name $user -PasswordNeverExpires $True