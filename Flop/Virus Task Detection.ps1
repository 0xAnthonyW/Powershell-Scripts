
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