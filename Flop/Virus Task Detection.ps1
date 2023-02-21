if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
$taskName = 'Wavesor*'
$tasks = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($tasks)
{
    Write-Host "The following tasks were found with the name '$taskName':" -ForegroundColor Yellow
    $tasks | ForEach-Object {
        Write-Host $_.TaskName
    }
    Read-Host "Press Enter to continue."
}
else
{
    Write-Host "No tasks were found with the name '$taskName'." -ForegroundColor Green
    Read-Host "Press Enter to continue."
}
