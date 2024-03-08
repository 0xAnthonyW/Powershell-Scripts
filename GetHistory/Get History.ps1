# Created By Anthony
# Get History v0.2
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
$sourceHistoryPath = "C:\Users\$username\AppData\Local\Google\Chrome\User Data\Default\History"
$tempDirectory = "D:\ChromeHistory"
$tempDirectoryRaw = "D:\ChromeHistory\raw"
$databaseFilePath = Join-Path -Path $tempDirectoryRaw -ChildPath "${username}_History"
$outputFilePath = "D:\ChromeHistory\input\${username}_URL.csv"
$outputFileKeywordsPath = "D:\ChromeHistory\keywords\${username}_keyword_search_terms.csv"

# Ensure the ChromeHistory directory exists on the USB drive
if (-not (Test-Path -Path $tempDirectory)) {
    New-Item -ItemType Directory -Force -Path $tempDirectory
}

# Copy the Chrome History file
if (Test-Path -Path $sourceHistoryPath) {
    Copy-Item -Path $sourceHistoryPath -Destination $databaseFilePath -Force
} else {
    Write-Host "The Chrome History file does not exist."
    exit
}

# Define SQLite command strings
$commands = @"
.mode csv
.output '$outputFilePath'
SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC;
.output '$outputFileKeywordsPath'
SELECT term, url_id FROM keyword_search_terms ORDER BY term DESC;
.exit
"@


echo $commands | & $sqliteExePath $databaseFilePath

Write-Host "Chrome History exported to $outputFilePath"
Pause
