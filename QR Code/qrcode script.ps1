# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Import the QRCodeGenerator module
Import-Module QRCodeGenerator

# Define input and output paths
$inputFilePath = 'C:\Users\rootusr\Downloads\work\input.txt'
$outputDirectory = 'C:\Users\rootusr\Downloads\work\output'

# Ensure output directory exists
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

# Read each line from the input file
$textLines = Get-Content $inputFilePath

# Loop through each line and generate QR code
foreach ($line in $textLines) {
    # Split on colon to separate STU portion and the code portion
    $parts = $line -split ':'
    
    # $parts[0] should look like "STU0001" - extract numeric portion
    # Assuming it always starts with "STU"
    $stu = $parts[0]
    $serialNumber = $stu.Substring(3)  # e.g. "STU0001" -> "0001"

    # $parts[1] is the code, e.g. "2TK0854HJF"
    $code = $parts[1]

    # Construct the filename => qr_0001_2TK0854HJF.png
    $fileName = "qr_{0}_{1}.png" -f $serialNumber, $code
    $outputFilePath = Join-Path $outputDirectory $fileName

    # Generate the QR code
    New-PSOneQRCodeText -Text $line -Width 50 -OutPath $outputFilePath
}

# Pause the script to view any output or errors
Pause
