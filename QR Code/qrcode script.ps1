# Check for Administrator privileges (remove if unnecessary)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Import the QRCodeGenerator module
Import-Module QRCodeGenerator

# Define paths
$inputFilePath = 'C:\Users\admin\Downloads\qrcode\qrcode\Input.txt'
$outputDirectory = 'C:\Users\admin\Downloads\qrcode\qrcode\output'

# Create output directory if needed
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

# Process each line
Get-Content $inputFilePath | ForEach-Object {
    $serialPart, $stuCode = $_ -split ':'
    
    # Extract numeric portion after "2TK" prefix
    $serialNumber = $serialPart.Substring(3)  # Removes first 3 characters ("2TK")
    
    # Build filename
    $fileName = "qr_{0}_{1}.png" -f $serialNumber, $stuCode
    $outputPath = Join-Path $outputDirectory $fileName
    
    # Generate QR code with ONLY the serial part (before colon)
    New-PSOneQRCodeText -Text $serialPart -Width 200 -OutPath $outputPath
}

Pause
