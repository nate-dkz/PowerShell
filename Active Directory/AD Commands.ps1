# Returns domain information
Get-ADDomain

# Displays the hostname and operating systems of all domain controllers
Get-ADDomainController -Filter * | Select-Object Hostname, OperatingSystem

# Displays the fine grained password policy
Get-ADFineGrainedPasswordPolicy -Filter *

# Displays the default password policy for the domain
Get-ADDefaultDomainPasswordPolicy

# Displays a user account and all properties
$User = 'john.appleseed'
Get-ADUser $User -Properties *

# Displays a user account with specific properties
$User = 'john.appleseed'
Get-ADUser $User -Properties * | Select-Object -Property GivenName, Surname, EmailAddress, LastLogonDate

# Displays all user accounts within a specific OU
$OU = 'OU=Test,OU=Arkham,DC=arkham,DC=co,DC=uk'
Get-ADUser -SearchBase $OU -Filter *

# Displays all user accounts which are disabled
Search-ADAccount -AccountDisabled

# Disables a user account
$User = 'john.appleseed'
Disable-ADAccount -Identity $User -PassThru

# Enables a user account
$User = 'john.appleseed'
Enable-ADAccount -Identity $User -PassThru

# Displays all user accounts which are locked
Search-ADAccount -LockedOut

# Unlocks a user account
$User = 'john.appleseed'
Unlock-ADAccount -Identity $User

# Requests the user to change password at the next logon
$User = 'john.appleseed'
Set-ADUser -Identity $User -ChangePasswordAtLogon $true

# Displays all user accounts where passwords are set to never expire
Get-ADUser -Filter * -Properties Name, PasswordNeverExpires |
Where-Object { $_.PasswordNeverExpires -eq $true } |
Select-Object -Property DistinguishedName, Name, Enabled

# Sets the email address for each user in a specific OU
$OU = 'OU=Test,OU=Arkham,DC=arkham,DC=co,DC=uk'
Get-ADUser -Filter * -SearchBase $OU | 
ForEach-Object { Set-ADUser -Identity $_ -EmailAddress "$($_.GivenName).$($_.Surname)@arkham.live" }

# Moves a user account to a different OU
$User = 'John Appleseed'
$OU1= "CN=$User,OU=Test,OU=Arkham,DC=arkham,DC=co,DC=uk"
$OU2 = 'OU=Test 2,OU=Arkham,DC=arkham,DC=co,DC=uk'
Move-ADObject -Identity $OU1 -TargetPath $OU2 -PassThru

# Displays global security groups
Get-ADGroup -Filter * | Where-Object {$_.GroupScope -eq 'Global' -and $_.GroupCategory -eq 'Security'}

# Displays user accounts belonging to a specific group
$Group = 'Security'
Get-ADGroupMember -Identity $Group | Select-Object -Property Name, SamAccountName

# Adds user account to a group
$User = 'John.Appleseed'
$Group = 'Security'
Add-ADGroupMember -Identity $Group -Members $User -PassThru

# Displays all computers connected to a domain
Get-AdComputer -Filter * | Select-Object -Property Name

# Displays all Windows 10 computers connected to a domain
Get-ADComputer -Filter { OperatingSystem -Like '*Windows 10*' } -Property * | Select-Object Name, Operatingsystem
