# Created By Anthony
# Get History v0.3
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


# Setup paths and variables
$usernamePrefix = "STU"  # Prefix to search for in usernames
$userAccount = Get-LocalUser | Where-Object { $_.Name -like "$usernamePrefix*" } | Select-Object -First 1
if ($null -eq $userAccount)
{
    Write-Host "No user account found with prefix $usernamePrefix."
    exit
}
$username = $userAccount.Name  # Extracting the Name property
$sqliteExePath = "D:\sqlite\sqlite3.exe"

# Browser-specific adjustments
$browsers = @(
    @{Name = "Chrome"; HistoryPath = "C:\Users\$username\AppData\Local\Google\Chrome\User Data\Default\History" },
    @{Name = "Edge"; HistoryPath = "C:\Users\$username\AppData\Local\Microsoft\Edge\User Data\Default\History" }
)

foreach ($browser in $browsers) 
{
    $tempDirectory = "D:\BrowserHistory\" + $browser.Name
    $tempDirectoryRaw = $tempDirectory + "\raw"
    $databaseFilePath = $tempDirectoryRaw + "\${username}_History"
    $outputFilePath = $tempDirectory + "\input\${username}_${browser.Name}_URL.csv"
    $outputFileKeywordsPath = $tempDirectory + "\keywords\${username}_${browser.Name}_keyword_search_terms.csv"

    # Ensure the necessary directories exist
    if (-not (Test-Path -Path $tempDirectory))
    {
        New-Item -ItemType Directory -Force -Path $tempDirectory
    }
    if (-not (Test-Path -Path "$tempDirectory\input"))
    {
        New-Item -ItemType Directory -Force -Path "$tempDirectory\input"
    }
    if (-not (Test-Path -Path "$tempDirectory\keywords"))
    {
        New-Item -ItemType Directory -Force -Path "$tempDirectory\keywords"
    }
    if (-not (Test-Path -Path $tempDirectoryRaw))
    {
        New-Item -ItemType Directory -Force -Path $tempDirectoryRaw
    }
    if (-not (Test-Path -Path $browser.HistoryPath))
    {
        Write-Host "The $($browser.Name) History file does not exist for $username."
        continue
    }

    # Copy the browser History file
    Copy-Item -Path $browser.HistoryPath -Destination $databaseFilePath -Force

    # Define and execute SQLite command strings
    $commands = @"
.mode csv
.output '$outputFilePath'
SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC;
.output '$outputFileKeywordsPath'
SELECT term, url_id FROM keyword_search_terms ORDER BY term DESC;
.exit
"@

    echo $commands | & $sqliteExePath $databaseFilePath

    Write-Host "$($browser.Name) History exported to $outputFilePath"
}

Pause
