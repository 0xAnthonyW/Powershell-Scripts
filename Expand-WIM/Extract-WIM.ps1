if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
function Expand-WIM {
    param (
        [string]$ISOPath,
        [string]$DestinationPath
    )

    $WimPath = Join-Path -Path $DestinationPath -ChildPath "install.wim"

    # Mount the Windows ISO
    $MountedISO = Mount-DiskImage -ImagePath $ISOPath -PassThru

    # Get the ISO drive letter
    $DriveLetter = ($MountedISO | Get-Volume).DriveLetter

    # Copy the install.wim file from the ISO to the desired location
    Copy-Item -Path "$($DriveLetter):\sources\install.wim" -Destination $WimPath

    # Unmount the Windows ISO
    Dismount-DiskImage -ImagePath $ISOPath

    # Optional: Get WIM info
    dism /Get-WimInfo /WimFile:$WimPath /index:1
}

$ISOPath = Read-Host -Prompt "Please enter the path to the Windows ISO file"
$DestinationPath = Read-Host -Prompt "Please enter the destination folder for the install.wim file"

switch ($ISOPath) {
    {Test-Path $_ -PathType Leaf} {Expand-WIM -ISOPath $ISOPath -DestinationPath $DestinationPath}
    default {"Invalid file path. Please ensure you have entered a valid path to a Windows ISO file."}
}

Read-Host -Prompt "All done! Press any key to exit."