#Created by Anthony
#Uses SYSTEM UID might change and see if i can use different id but for now this works.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -file C:\Users\admin\Desktop\PasswordExpire.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger
Register-ScheduledTask 'PassExpire' -InputObject $task
