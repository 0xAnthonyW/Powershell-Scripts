<<<<<<< HEAD
#V1.2.3
#removed debug logging no longer needed
#Gets the current logged in user and if it matches STU it sets it to -PasswordNeverExpires
=======
#V1.2.2
#debugging path added next release removes logs for production use
#Gets current logged in user and if it doesnt match STU it wont set it to passneverexpire Works as it should.

#creates logging
function Write-LogMessage {
    param (
        [string]$Message,
        [string]$Path
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp $Message"
    Add-Content -Path $Path -Value $logEntry
}

#Path of logs if using SYSTEM UID  C:\Windows\System32\config\systemprofile\loggedin-users.log 
$LogFilePath = Join-Path $Home 'loggedin-users.log'
>>>>>>> ff186cc5263226d93749a5c1ed502e1cf310aed7
$UsernamePrefix = "STU"

# Get the currently logged-in user using the explorer process
$LoggedInUser = (Get-WmiObject -Class Win32_Process -Filter "Name = 'explorer.exe'").GetOwner().User

# Check if the user is a student and is logged in currently
if ($LoggedInUser -like "${UsernamePrefix}*")
{
    $userObj = Get-LocalUser | Where-Object { $_.Name -eq $LoggedInUser }

    if ($userObj)
    {
        Set-LocalUser -Name $userObj.Name -PasswordNeverExpires $True
    }
}
