if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}

# Import the QRCodeGenerator module
Import-Module QRCodeGenerator

# Define input and output paths
$inputFilePath = 'C:\Users\admin\Downloads\qrcode\input.txt'
$outputDirectory = 'C:\Users\admin\Downloads\qrcode\output'

# Ensure output directory exists
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory
}

# Read each line from the input file
$textLines = Get-Content $inputFilePath

# Counter for naming files
$counter = 1

# Loop through each line and generate QR code
foreach ($line in $textLines) {
    $outputFilePath = Join-Path $outputDirectory ("qr_" + $counter + ".png")
    New-PSOneQRCodeText -Text $line -Width 200 -OutPath $outputFilePath
    $counter++
}

# Pause the script to view any output or errors
Pause
