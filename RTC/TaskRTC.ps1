# Task RTC Fix
# 1.0.0
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Import the task from the exported XML file
$taskXml = Get-Content 'C:\Users\admin\Desktop\RTC.xml' | Out-String

# Register the task using the imported XML
Register-ScheduledTask -Xml $taskXml -TaskName 'RTC'
