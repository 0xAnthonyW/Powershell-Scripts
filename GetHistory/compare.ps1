if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$inputDir = "C:\Users\admin\compare\input"
$outputDir = "C:\Users\admin\compare\output"
$combinedFilePath = Join-Path -Path $outputDir -ChildPath "combined_domains.csv"
$outputFilePath = Join-Path -Path $outputDir -ChildPath "domain_frequencies.csv"

# Ensure the output directory exists
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

function Extract-Domain {
    param (
        [string]$url
    )

    try {
        $uri = [System.Uri]$url
        $domain = $uri.Host
        # Remove subdomains if any, focus on the main domain
        $splitDomain = $domain -split "\."
        if ($splitDomain.Count -gt 2) {
            # Join the TLD and the domain name, exclude subdomains
            $domain = $splitDomain[-2..-1] -join "."
        }
        return $domain
    }
    catch {
        return $null
    }
}

# Collect and combine all values from the first column of all CSV files, extracting domains
$allDomains = Get-ChildItem -Path $inputDir -Filter "*.csv" | ForEach-Object {
    Import-Csv -Path $_.FullName -Header "URL" | ForEach-Object {
        $domain = Extract-Domain -url $_.URL
        if ($null -ne $domain) { $domain }
    }
}

# Export combined domains to a new CSV for record-keeping
$allDomains | ForEach-Object { [PSCustomObject]@{Domain = $_} } | Export-Csv -Path $combinedFilePath -NoTypeInformation

# Count duplicates (frequencies) of each domain
$domainFrequencies = $allDomains | Where-Object { $_ -ne $null } | Group-Object | ForEach-Object {
    [PSCustomObject]@{
        Domain = $_.Name
        Frequency = $_.Count
    }
} | Sort-Object -Property Frequency -Descending

# Export domain frequencies to CSV
$domainFrequencies | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Host "Domain aggregation and frequency analysis complete. Results saved to $outputFilePath"

Pause