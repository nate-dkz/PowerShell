
# Prompts you to enter the users email address
$EmailAddress = (Read-Host -Prompt "Enter the users email address")

$ADUser = Get-ADUser -Filter "EmailAddress -eq '$EmailAddress'" -Properties * |
Select-Object -Property DisplayName,
                        DistinguishedName,
                        EmailAddress,
                        Enabled,
                        LockedOut,
                        LastLogonDate,
                        PasswordLastSet
if ($ADUser -ne $null){
    $ADUser
}
else {"User not found, please check the email address and try again"}
