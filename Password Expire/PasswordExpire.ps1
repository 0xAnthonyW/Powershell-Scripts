#V1.2.1
$UsernamePrefix = "STU"
$GroupName = "Students"
$LogFilePath = Join-Path $Home 'passexpire-debug.log'

# Function to add timestamp to log entries
function Log-Message {
    param (
        [string]$Message,
        [string]$Path
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp $Message"
    Add-Content -Path $Path -Value $logEntry
}

# Get the logged-in user with the prefix "STU"
$LoggedInUsers = Get-WmiObject -Class Win32_ComputerSystem | Where-Object { $_.UserName -like "*${UsernamePrefix}*" } | Select-Object -ExpandProperty UserName

# Get the group information
try {
    $Group = Get-LocalGroup -Name $GroupName -ErrorAction Stop
    $GroupMembers = $Group | Get-LocalGroupMember | Select-Object -ExpandProperty Name
} catch {
    Log-Message -Message "The group '$GroupName' does not exist." -Path $LogFilePath
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
            Log-Message -Message "User $($user.Name) is currently logged on and a member of the '$GroupName' group. Password set to never expire." -Path $LogFilePath
        } else {
            Log-Message -Message "User $($user.Name) is currently logged on but not a member of the '$GroupName' group." -Path $LogFilePath
        }
    } else {
        Log-Message -Message "No local user accounts starting with '$UsernamePrefix' were found." -Path $LogFilePath
    }
}
