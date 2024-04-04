#creates new folder
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


# Create new folders
New-Item -Path "C:\Users\admin\compare\raw" -ItemType Directory
New-Item -Path "C:\Users\admin\compare\input" -ItemType Directory
New-Item -Path "C:\Users\admin\compare\output" -ItemType Directory
New-Item -Path "C:\Users\admin\compare\keywords" -ItemType Directory

Write-Host "Folders created successfully"
Pause