#Not done.. More info is needed
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$exePath = "C:\Users\$user\`Wavesor Software`\SWUpdater\SWUpdater.exe"

if (Test-Path $exePath) {
    Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
    Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
}
else {
    Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green
}
