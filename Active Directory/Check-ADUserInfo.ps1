function Get-ADUserInfo {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $EmailAddress
    )

    # Define the regex pattern for email addresses
    $Pattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    # Check if the email address matches the pattern
    if ($EmailAddress -match $Pattern) {
        Get-ADUser -Filter "EmailAddress -eq '$EmailAddress'" -Properties * |
        Select-Object -Property DisplayName,
                                DistinguishedName,
                                EmailAddress,
                                Enabled,
                                LockedOut,
                                LastLogonDate,
                                PasswordLastSet
    }
    else {
        Write-Output "Invalid email address, please check the email address and try again"
    }
}
