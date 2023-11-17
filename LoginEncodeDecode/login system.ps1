$encodetxt = Read-Host "Enter password"
$inputstr = [System.Text.Encoding]::Unicode.GetBytes($encodetxt)
$EncodedText = [System.Convert]::ToBase64String($inputstr)
Write-Host $EncodedText
Pause
$pass = $EncodedText
$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($pass))
$str = Read-Host "Enter password"
if ($str -eq $DecodedText) {
    Write-Host "Password is correct"
    Write-Host $pass
} 
else {
    Write-Host "Password is incorrect"
}
Pause


