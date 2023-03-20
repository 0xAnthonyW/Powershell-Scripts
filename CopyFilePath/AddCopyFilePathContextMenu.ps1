if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
# Define the registry path for the "Copy File Path" option
$regPath = "HKCU:\Software\Classes\*\shell\Copy File Path"

# Create the "Copy File Path" key
New-Item -Path $regPath -Force | Out-Null

# Create the "command" subkey
New-Item -Path "$regPath\command" -Force | Out-Null

# Set the default value of the "command" subkey to the PowerShell command that copies the file path to the clipboard
Set-ItemProperty -Path "$regPath\command" -Name "(Default)" -Value "cmd.exe /c echo %1 | clip"


Read-Host "Done.."