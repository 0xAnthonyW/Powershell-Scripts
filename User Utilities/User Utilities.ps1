<# Created By Anthony
User Utilities v1.1.1#>
#This script is used to reset the password, time zone and network adapter for a user. It assumes the user has been granted the required permissions to execute the functions.
#Run PowerShell as Admin.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
Try
{
    #This function resets the password of the user to 'Student' and sets it to require a change at next login.
    function Reset-UserPassword
    {
        Param([string]$user)
        # Sets the Password Never Expires to false to ensure logonpasswordchg can be set
        Set-LocalUser -Name $user -PasswordNeverExpires $False
        # Resets the password of the user to 'Student'
        net user $user "Student" /logonpasswordchg:yes
        Write-Host "Password for user $user has been reset to 'Student' and set to user must change password at next login" -ForegroundColor Green
    }
    #This function sets the Real Time Clock to 'Central Standard Time'
    function Reset-Timezone
    {
        # Sets the Real Time Clock to 'Central Standard Time'
        Set-TimeZone -Name 'Central Standard Time' -PassThru
        Write-Host "Timezone has been set to CST" -ForegroundColor Green
    }
    #This function resets the network adapter, clears the DNS cache and releases/renews IP configuration
    function Reset-NetworkAdapter
    {
        Restart-NetAdapter -Name "Wi*"
        Write-Host "Network adapter restarted" -ForegroundColor Green
        # Clears Dns Cache
        Clear-DnsClientCache
        Start-Sleep -Seconds 5
        ipconfig /flushdns
        Write-Host "Flushed DNS" -ForegroundColor Green
        # Release and Renew the ip configuration
        Start-Sleep -Seconds 5
        ipconfig /Release
        Start-Sleep -Seconds 5
        ipconfig /Renew
        Write-Host "IP configuration renew & released!" -ForegroundColor Green
    }
    #Gets the student account
    $user = (Get-LocalUser | Where-Object { $_.Name -like "STU*" }).Name
    #The options menu provides the user with a choice of functions. Depending on the option chosen, the appropriate function is run.
    Try
    {
        while ($true)
        {
            $userinput = Read-Host "Choose an option:
1) Password Reset
2) Password Never Expires
3) Real Time Clock Fix
4) Wifi Reset
"
            switch ($userinput)
            {
                '1'
                {
                    Reset-UserPassword $user
                    PAUSE #Exit
                }
                '2'
                {
                    Set-LocalUser -Name $user -PasswordNeverExpires $True
                    Write-Host "Password has been set to not expire" -ForegroundColor Green
                    PAUSE
                }
                '3'
                {
                    Reset-Timezone
                    PAUSE
                }
                '4'
                {
                    Reset-NetworkAdapter
                    PAUSE
                }
                default
                {
                    Write-Host "Invalid input. Please enter a valid option." -ForegroundColor Red
                }
            }
            $exit = Read-Host "Do you want to exit? (Y/N)"
            if ($exit -eq 'Y')
            {
                exit
            }
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Something went wrong. Error message: $ErrorMessage" -ForegroundColor Red
    }
}
Catch
{
    Write-Host 'Error Detected!'
    Write-Host $Error[0].Exception
}
PAUSE

