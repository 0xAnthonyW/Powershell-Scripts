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

$LogFilePath = Join-Path $Home 'loggedin-users.log'
$UsernamePrefix = "STU"

# Get the currently logged-in user using the explorer process
$LoggedInUser = (Get-WmiObject -Class Win32_Process -Filter "Name = 'explorer.exe'").GetOwner().User

if ($LoggedInUser -like "${UsernamePrefix}*") {
    Write-LogMessage -Message "Logged in user: $LoggedInUser" -Path $LogFilePath

    $userObj = Get-LocalUser | Where-Object { $_.Name -eq $LoggedInUser }

    if ($userObj) {
        Set-LocalUser -Name $userObj.Name -PasswordNeverExpires $True
        Write-LogMessage -Message "Password never expires set for user $($userObj.Name)." -Path $LogFilePath
    } else {
        Write-LogMessage -Message "Could not find local user account for user $($LoggedInUser)." -Path $LogFilePath
    }
} else {
    Write-LogMessage -Message "No student user logged in." -Path $LogFilePath
}
