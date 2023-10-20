# Real Time Clock Fix
# 1.0.0
# This script checks for an active internet connection and syncs system time

# Set the number of tries to check for internet
function Write-LogMessage {
    param (
        [string]$Message,
        [string]$Path = "$env:USERPROFILE\Desktop\RTC_Log.txt"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp $Message"
    Add-Content -Path $Path -Value $logEntry
}

# This script checks for an active internet connection and syncs system time

# Set the number of tries to check for internet
$tries = 5
$connected = $false

# Try to ping Google's DNS server up to $tries times
for ($i=1; $i -le $tries; $i++) {
    $logMessage = "Attempt $i of $tries to check internet connection..."
    Write-LogMessage -Message $logMessage
    $pingResult = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction SilentlyContinue
    if ($pingResult.StatusCode -eq 0) {
        $connected = $true
        break
    } else {
        Start-Sleep -Seconds 10
    }
}

# If connected to the internet, sync the time
if ($connected) {
    $logMessage = "Internet connection established. Synchronizing system time..."
    Write-LogMessage -Message $logMessage

    # Restart the Windows Time service
    Restart-Service w32time
    # Force synchronization
    w32tm /resync

    $logMessage = "System time synchronized."
    Write-LogMessage -Message $logMessage

    # After syncing the time, disable the scheduled task to prevent further runs
    Get-ScheduledTask -TaskName 'RTC Check' | Disable-ScheduledTask
} else {
    $logMessage = "Failed to establish internet connection after $tries attempts. Exiting."
    Write-LogMessage -Message $logMessage
}
