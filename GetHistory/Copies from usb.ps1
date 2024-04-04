#Copyies Browser History files from source to target
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$targetinput = "C:\Users\admin\compare"
$targetraw = "C:\Users\admin\compare"
$targetkeywords = "C:\Users\admin\compare\"
 
$sourcechromeinput = "D:\BrowserHistory\Chrome\input"
$sourcechromekeywords = "D:\BrowserHistory\Chrome\keywords"
$sourcechromeraw = "D:\BrowserHistory\Chrome\raw"
$sourceEdgeinput = "D:\BrowserHistory\Edge\input"
$sourceEdgekeywords = "D:\BrowserHistory\Edge\keywords"
$sourceEdgeraw = "D:\BrowserHistory\Edge\raw"

#creates a loop to copy files from source to target

do {
    Copy-Item -Path $sourcechromeinput -Destination $targetinput -Recurse -Force
    Write-Host "Copying Chrome input files"
    Copy-Item -Path $sourcechromekeywords -Destination $targetkeywords -Recurse -Force
    Write-Host "Copying Chrome keywords files"
    Copy-Item -Path $sourcechromeraw -Destination $targetraw -Recurse -Force
    Write-Host "Copying Chrome raw files"
    Copy-Item -Path $sourceEdgeinput -Destination $targetinput -Recurse -Force
    Write-Host "Copying Edge input files"
    Copy-Item -Path $sourceEdgekeywords -Destination $targetkeywords -Recurse -Force
    Write-Host "Copying Edge keywords files"
    Copy-Item -Path $sourceEdgeraw -Destination $targetraw -Recurse -Force
    Write-Host "Copying Edge raw files"
    Write-Host "Files copied"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} while ($x.VirtualKeyCode -eq 13)
