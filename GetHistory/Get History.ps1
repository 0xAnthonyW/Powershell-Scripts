# Created By Anthony
# Get History v0.4
# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
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

# First, check if the standard profile path exists
$userProfilePath = "C:\Users\$username"
if (Test-Path $userProfilePath) {
    Write-Host "Using standard profile path: $userProfilePath"
} else {
    # If not, search for a directory that matches "$username.*"
    $userProfilePath = Get-ChildItem "C:\Users" -Directory | Where-Object { $_.Name -like "$username.*" } | Select-Object -ExpandProperty FullName -First 1
    if ($null -eq $userProfilePath) {
        Write-Host "User profile directory for $username not found."
        exit
    } else {
        Write-Host "Using alternate profile path: $userProfilePath"
    }
}

# Browser-specific adjustments
$browsers = @(
    @{Name = "Chrome"; BasePath = "$userProfilePath\AppData\Local\Google\Chrome\User Data" },
    @{Name = "Edge"; BasePath = "$userProfilePath\AppData\Local\Microsoft\Edge\User Data" }
)

# Profiles to check: "Default" and "Profile 1" to "Profile 10"
$profiles = @("Default")
for ($i = 1; $i -le 10; $i++) {
    $profiles += "Profile $i"
}

foreach ($browser in $browsers) 
{
    foreach ($profile in $profiles)
    {
        $historyPath = "$($browser.BasePath)\$profile\History"
        if (-not (Test-Path -Path $historyPath))
        {
            # History file does not exist for this profile
            continue
        }

        # Set up directories and file paths
        $tempDirectory = "D:\BrowserHistory\" + $browser.Name
        $tempDirectoryRaw = "$tempDirectory\raw"
        $databaseFilePath = "$tempDirectoryRaw\${username}_${browser.Name}_${profile}_History"
        $outputFilePath = "$tempDirectory\input\${username}_${browser.Name}_${profile}_URL.csv"
        $outputFileKeywordsPath = "$tempDirectory\keywords\${username}_${browser.Name}_${profile}_keyword_search_terms.csv"

        # Ensure the necessary directories exist
        New-Item -ItemType Directory -Force -Path $tempDirectory,$tempDirectoryRaw,"$tempDirectory\input","$tempDirectory\keywords" | Out-Null

        # Copy the browser History file
        Copy-Item -Path $historyPath -Destination $databaseFilePath -Force

        # Define and execute SQLite command strings
        $commands = @"
.mode csv
.output '$outputFilePath'
SELECT url, title, datetime(last_visit_time/1000000-11644473600,'unixepoch') as last_visit_time FROM urls ORDER BY last_visit_time DESC;
.output '$outputFileKeywordsPath'
SELECT term, url_id FROM keyword_search_terms ORDER BY term DESC;
.exit
"@

        echo $commands | & $sqliteExePath $databaseFilePath

        Write-Host "$($browser.Name) History for profile '$profile' exported to $outputFilePath"
    }
}
