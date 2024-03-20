if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define the directory containing the CSV files
$inputDir = "C:\Users\admin\compare\input"
# Prompt the user to enter the search term
$searchTerm = Read-Host "Enter the search term"
# List to store filenames that contain the search term
$filesWithTerm = @()

# Get all CSV files from the input directory
$csvFiles = Get-ChildItem -Path $inputDir -Filter "*.csv"

foreach ($file in $csvFiles) {
    # Import the CSV file, assuming the first column contains the data of interest
    $data = Import-Csv -Path $file.FullName
    
    # Search each row for the search term
    foreach ($row in $data) {
        # Assuming we're searching the entire row. Adjust if searching a specific column, e.g., $row.ColumnName
        if ($row -match $searchTerm) {
            # If a match is found, add the filename to the list (if not already added)
            if ($filesWithTerm -notcontains $file.Name) {
                $filesWithTerm += $file.Name
            }
        }
    }
}

# Output the filenames that contain the search term to the console
if ($filesWithTerm.Count -gt 0) {
    Write-Host "The search term '$searchTerm' was found in the following file(s):"
    $filesWithTerm | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "The search term '$searchTerm' was not found in any files."
}

Pause