#V1.2
$UsernamePrefix = "STU"
$GroupName = "Students"

# Get the logged-in user with the prefix "STU"
$LoggedInUsers = Get-WmiObject -Class Win32_ComputerSystem | Where-Object { $_.UserName -like "*${UsernamePrefix}*" } | Select-Object -ExpandProperty UserName

# Get the group information
try {
    $Group = Get-LocalGroup -Name $GroupName -ErrorAction Stop
    $GroupMembers = $Group | Get-LocalGroupMember | Select-Object -ExpandProperty Name
} catch {
    Read-Host "The group '$GroupName' does not exist."
    exit
}

# Check if the student is a member of the group
foreach ($loggedInUserName in $LoggedInUsers) {
    $userNameWithoutDomain = ($loggedInUserName -split '\\')[-1]
    $user = Get-LocalUser | Where-Object { $_.Name -eq $userNameWithoutDomain }

    if ($user) {
        $isMember = $false
        foreach ($groupMember in $GroupMembers) {
            $groupMemberName = ($groupMember -split '\\')[-1]
            if ($user.Name -eq $groupMemberName) {
                $isMember = $true
                break
            }
        }
        if ($isMember) {
            Set-LocalUser -Name $user.Name -PasswordNeverExpires $True
            Read-Host "User $($user.Name) is currently logged on and a member of the '$GroupName' group. Password set to never expire."
        } else {
            Read-Host "User $($user.Name) is currently logged on but not a member of the '$GroupName' group."
        }
    } else {
        Read-Host "No local user accounts starting with '$UsernamePrefix' were found."
    }
}
