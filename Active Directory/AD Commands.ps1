# Returns domain information
Get-ADDomain

# Returns the hostname and operating systems of all domain controllers
Get-ADDomainController -Filter * | Select-Object Hostname, OperatingSystem

# Returns the fine grained password policy
Get-ADFineGrainedPasswordPolicy -Filter *

# Returns the default password policy for the domain
Get-ADDefaultDomainPasswordPolicy

# Returns a user account and lists all properties
Get-ADUser 'n.darker' -Properties *

# Returns a user account and lists specific properties
Get-ADUser 'n.darker' -Properties * | Select-Object -Property GivenName, Surname, EmailAddress, LastLogonDate

# Returns all user accounts within a specific OU
Get-ADUser -SearchBase 'OU=IT,OU=Arkham,DC=arkham,DC=co,DC=uk' -Filter *

# Returns all user accounts which are disabled
Search-ADAccount -AccountDisabled

# Disables a user account
Disable-ADAccount -Identity 'Carl.Young' -PassThru

# Enables a user account
Enable-ADAccount -Identity 'Carl.Young' -PassThru

# Returns all user accounts which are locked
Search-ADAccount -LockedOut

# Unlocks a user account
Unlock-ADAccount -Identity 'Carl.Young'

Set-ADUser -Identity 'Carl.Young' -ChangePasswordAtLogon $true

# Returns all user accounts where passwords are set to never expire
Get-ADUser -Filter * -Properties Name, PasswordNeverExpires |                                                                                                                                      Where-Object {$_.PasswordNeverExpires -eq $true} |
Select-Object -Property DistinguishedName, Name, Enabled

# Returns all user accounts within a specific OU and for each object, sets the email address
Get-ADUser -Filter * -SearchBase 'OU=IT,OU=Business Units,DC=arkham,DC=co,DC=uk' | 
ForEach-Object { Set-ADUser -Identity $_ -EmailAddress "$($_.GivenName).$($_.Surname)@arkham.live" }

# Moves a user account to a new OU
Move-ADObject -Identity 'CN=Carl Young,OU=Service Desk,OU=IT,OU=Arkham,DC=arkham,DC=co,DC=uk' -TargetPath 'OU=Security,OU=IT,OU=Arkham,DC=arkham,DC=co,DC=uk'

# Returns global security groups
Get-ADGroup -Filter * | Where-Object {$_.GroupScope -eq 'Global' -and $_.GroupCategory -eq 'Security'}

# Returns user accounts belonging to a specific group
Get-ADGroupMember -Identity 'Security' | Select-Object -Property Name, SamAccountName

# Adds user accounts to a group
Add-ADGroupMember -Identity 'Security' -Members 'N.Darker', 'Carl.Young'

# Returns all computers connected to a domain
Get-AdComputer -Filter *

# Returns all computers connected to a domain and only shows the computer name
Get-AdComputer -Filter * | Select-Object -Property Name

# Returns all Windows 10 computers connected to a domain
Get-ADComputer -Filter {OperatingSystem -Like '*Windows 10*'} -Property * | Select-Object Name, Operatingsystem
