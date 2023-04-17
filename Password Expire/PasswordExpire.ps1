# Created By Anthony
# PasswordExpire V1.2.3
# This script gets the current logged in user and if it matches STU it sets it to -PasswordNeverExpires
# Sets the STU Variable
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
