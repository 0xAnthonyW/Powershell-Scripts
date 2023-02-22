<<<<<<< HEAD
# Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$exePath = "C:\Users\$user\`Wavesor Software`\WaveBrowser\wavebrowser.exe"
#Task Name WaveBrowser-StartAtLogin
#$exePath = "C:\Users\$user\`Wavesor Software`\SWUpdater\SWUpdater.exe"
$taskName = 'Wavesor*'
$tasks = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($tasks)
{
    Write-Host "The following tasks were found with the name '$taskName':" -ForegroundColor Yellow
    $tasks | ForEach-Object {
        Write-Host $_.TaskName
        # Enable User Account Control (UAC) consent prompt.
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5
        # Check if the SWUpdater.exe file exists in the user's profile folder. If it does, prompt for admin interaction.
        if (Test-Path $exePath)
        {
            Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
            Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
        }
        else
        {
            Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green
        }
    }
    Read-Host "Press Enter to continue."
}
else
{
    Write-Host "No tasks were found with the name '$taskName'." -ForegroundColor Green
    # Check if the SWUpdater.exe file exists in the user's profile folder. If it does, prompt for admin interaction.
    if (Test-Path $exePath)
    {
        Write-Host "The executable file SWUpdater.exe exists in the user's profile folder." -ForegroundColor Red
        Read-Host "Admin Interaction Required: Please inspect the file further and take appropriate action. Press Enter to continue."
    }
    else
    {
        Write-Host "The executable file SWUpdater.exe does not exist in the user's profile folder." -ForegroundColor Green
    }
}
=======
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
>>>>>>> 6115bf0643fa15723143b1a52134158b5ed28ef8
