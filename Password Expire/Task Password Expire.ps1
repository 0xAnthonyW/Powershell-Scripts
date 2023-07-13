# Created By Anthony
# Task Password Expire v1.1
# Sets up Scheduled Task to run the PasswordExpire Script in the background.
# Run PowerShell as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -file C:\Users\admin\Desktop\PasswordExpire.ps1"
$tasksetting = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $tasksetting
Register-ScheduledTask 'PassExpire' -InputObject $task