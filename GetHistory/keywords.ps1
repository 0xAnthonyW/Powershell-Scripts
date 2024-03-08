if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

$inputDir = "C:\Users\admin\compare\keywords"
$outputDir = "C:\Users\admin\compare\output"
$outputFilePath = Join-Path -Path $outputDir -ChildPath "word_frequencies.csv"

# Ensure the output directory exists
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

# Initialize a hashtable to count occurrences of each search query
$searchQueryCounts = @{}

# Process each CSV file
Get-ChildItem -Path $inputDir -Filter "*.csv" | ForEach-Object {
    $csvData = Import-Csv -Path $_.FullName -Header "SearchQuery"
    $csvData | ForEach-Object {
        $searchQuery = $_.SearchQuery.Trim()
        if (-not [string]::IsNullOrWhiteSpace($searchQuery)) {
            if ($searchQueryCounts.ContainsKey($searchQuery)) {
                $searchQueryCounts[$searchQuery]++
            } else {
                $searchQueryCounts[$searchQuery] = 1
            }
        }
    }
}

# Convert the search query counts to a list of objects for export
$searchQueryFrequencies = $searchQueryCounts.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        SearchQuery = $_.Key
        Frequency = $_.Value
    }
} | Sort-Object -Property Frequency -Descending

# Export the search query frequencies to a CSV file
$searchQueryFrequencies | Export-Csv -Path $outputFilePath -NoTypeInformation

Write-Host "Search query frequency analysis complete. Results saved to $outputFilePath"


Pause
