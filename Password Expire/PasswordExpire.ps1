#1.1
#not done need to figure out a way to get the stu SID and store it? and use that to possibly run as a check instead of rely on their username incase they rename the account
# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
# {
#     Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
# }
$UsernamePrefix = "STU"
$user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
$LoggedInUsers = qwinsta /server:localhost | Select-String -Pattern "$UsernamePrefix"
if ($LoggedInUsers) 
{
    $User = ($LoggedInUsers -split '\s+')[1]
    Read-Host "User $User is currently logged on."
    Set-LocalUser -Name $user -PasswordNeverExpires $True
}
else 
{
    Read-Host "No local user accounts starting with '$UsernamePrefix' were found."
}