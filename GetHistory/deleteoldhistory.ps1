#deletes old files in the specified path
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$path1 = "D:\BrowserHistory\Chrome"
$path2 = "D:\BrowserHistory\Edge"

#creates loop and deletes the paths and upon pressing enter does the same task
do {
    Remove-Item -Path $path1 -Recurse -Force
    Remove-Item -Path $path2 -Recurse -Force
    Write-Host "Deleted"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} while ($x.VirtualKeyCode -eq 13)
