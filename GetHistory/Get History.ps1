# Created By Anthony
# Get History v0.1
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Setup paths and variables
$username = "Admin"
$sqliteExePath = "C:\Users\admin\AppData\Local\Temp\chocolatey\ChocolateyScratch\sqlite.shell\3.43.2\tools\sqlite3.exe"
$sourceHistoryPath = "C:\Users\$username\AppData\Local\Google\Chrome\User Data\Default\History"
$tempDirectory = "C:\Temp\ChromeHistoryExport"
$databaseFilePath = Join-Path -Path $tempDirectory -ChildPath "History"
$outputFilePath = "C:\Users\$username\Desktop\${username}_output.csv"
$outputFileKeywordsPath = "C:\Users\$username\Desktop\${username}_keyword_search_terms.csv"

# Ensure the temp directory exists
if (-not (Test-Path -Path $tempDirectory)) 
{
    New-Item -ItemType Directory -Force -Path $tempDirectory
}

# Copy the Chrome History file
if (Test-Path -Path $sourceHistoryPath) 
{
    Copy-Item -Path $sourceHistoryPath -Destination $databaseFilePath -Force
} else 
{
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
Pause
