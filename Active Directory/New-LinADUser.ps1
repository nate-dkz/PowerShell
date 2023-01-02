# Global variables
$BrandInfoCSVPath = 'C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Practice Brand Info.csv' 
$WorkdayUserFile = 'C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Inbound\Linnaeus_AD_Maint_20220811_141451.TXT'

# New Starter - This is the main part of the script which calls upon the other functions to process new users
function New-LinADUser {

    [CmdletBinding()]
    param(
        [object]$BrandInfo = (Import-Csv -Path $BrandInfoCSVPath),
        [Object]$UserList = (Import-Csv -Path $WorkdayUserFile)
    )  
    BEGIN {
        $Date = Get-Date -Format 'yyyMMddHHmmss'
        if (-not(Test-Path -Path $WorkdayUserFile)) {
                Write-LogError 'Script terminated - The workday new user file does not exist, user objects cannot be created'
                Write-Error 'The workday new user file does not exist, user objects cannot be created' -ErrorAction Stop
        }
        else {
             $Props = @{
                Property = @{n='Action' ; e={$_.action}},
                           @{n='WorkdayID' ; e={$_.workday_id}},
                           @{n='FullName' ; e={$_.first_name + ' ' + $_.last_name}},
                           @{n='FirstName' ; e={$_.first_name}},
                           @{n='MiddleName' ; e={$_.middle_name}},
                           @{n='LastName' ; e={$_.last_name}},
                           @{n='PreferredFirstName' ; e={$_.preferred_first_name}},
                           @{n='PreferredLastName' ; e={$_.preferred_last_name}},
                           @{n='EmployeeType' ; e={$_.employee_type}},
                           'Certification',
                           @{n='JobTitle' ; e={$_.job_title}},
                           @{n='IsPeopleManager' ; e={$_.isPeopleManager}},
                           @{n='LineManagerID' ; e={$_.line_manager_id}},
                           @{n='Status' ; e={$_.status}},
                           @{n='StartDate' ; e={$_.recent_hire_date}},
                           @{n='BrandCode' ; e={$_.brand_code}},
                           @{n='Company' ; e={$_.brand_name}},
                           @{n='SiteCode' ; e={$_.site_code}},
                           @{n='SiteName' ; e={$_.site_name}},
                           @{n='WorkAddressLine1' ; e={$_.address_line1}},
                           @{n='WorkAddressLine2' ; e={$_.address_line2}},
                           @{n='WorkAddressLine3' ; e={$_.address_line3}},
                           'City',
                           @{n='WorkAddressCounty' ; e={$_.state_province}},
                           @{n='WorkAddressPostCode' ; e={$_.location_postal_code}},
                           @{n='Country' ; e={$_.country_code}},
                           @{n='OfficePhone' ; e={$_.location_phone_number}}
             }
             $UserList = Import-Csv -Path $WorkdayUserFile -Delimiter '|' | Select-Object @Props
        }        
        try {
            $CredXML = Import-Clixml -Path 'C:\Workday\NDPS.xml'
            $DCSession = New-PSSession -Credential $CredXML -ComputerName linnaeus-dc -Authentication Kerberos -Name linnaeus-dc
            $ADModule = Import-PSSession -Session $DCSession -Module ActiveDirectory, ADSync -CommandName Get-ADUser, New-ADUser, Set-ADUser, Add-ADGroupMember, Start-ADSyncSyncCycle -AllowClobber
            $ExchgSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://linnaeus-exch-1.linnaeusgroup.co.uk/PowerShell/' -Credential $CredXML -Authentication Kerberos -Name Exchange
            $ExchgModule = Import-PSSession -Session $ExchgSession -DisableNameChecking -AllowClobber
        }
        
        catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
            Write-Error "Unable to connect to the remote Server, check that the server is accessible"
            throw (Get-PSSession | Remove-PSSession)
        }
        catch {
            Write-Error 'An error has occured, please check the error log for more information'
            throw (Get-PSSession | Remove-PSSession)
        }
    }
    
    PROCESS {

        foreach ($User in $UserList) {
                Write-Verbose "Attempting to create account for Workday ID: $($User.WorkdayID) - $($user.Fullname)"
                Start-Sleep -Seconds 5

                # Attempts to remove any illegal characters from the name field 
                $FullName = $User.FullName | Find-LinPattern 
            
                # Attempts to match the company name on the user spreadsheet to the practice name on the brand info spreadsheet
                $PracticeInfo = $BrandInfo | Where-Object { $_.PracticeName -eq $User.Company }
            
                if (-not $PracticeInfo) {
                    Write-LogError "Unable to match $($User.Company) on the brand info spreadsheet"
                    throw (Write-Error "Unable to match $($User.Company) on the brand info spreadsheet")
                    
                }
            
                # Checks that the Workday ID in the current iteration is not in use within AD
                $WorkDayIDCheck = Get-ADUser -Filter "employeeNumber -eq $($User.WorkDayID)"

                if ( $WorkDayIDCheck ) {
                    Write-LogError "Unable to create account for $($FullName). The workday ID $($User.WorkDayID) is in use and is assigned to: $($WorkDayIDCheck.DistinguishedName)"
                    Write-Error "Unable to create account for $($FullName). The workday ID $($User.WorkDayID) is in use and is assigned to: $($WorkDayIDCheck.DistinguishedName)"
                    continue
                }
            
                 # Checks if the user in the current iteration exists within AD
                 $SAM = $User.FirstName + '.' + $user.LastName
                 $SamMatch = $((Get-ADUser -Filter "SamAccountName -like '$SAM*'").SamAccountName)
         
                 if ( $SamMatch.Count -eq 0 ) {
                     $UPN = "$($User.FirstName).$($User.LastName)@linnaeusgroup.co.uk"
                     $SAM = $User.FirstName + '.' + $User.LastName
                     $EmailAddress = "$($User.FirstName).$($User.LastName)@$($PracticeInfo.EmailDomain)"
                     $TargetAddress = "$($User.FirstName).$($User.LastName)@linnaeusgroupcouk.mail.onmicrosoft.com"
                     $ProxyAddress = "$($User.FirstName).$($User.LastName)@$($PracticeInfo.EmailDomain)"
                 } 
                 elseif ( $SamMatch.Count -eq 1) {
                     $UPN = "$($User.FirstName).$($User.LastName)1@linnaeusgroup.co.uk"
                     $SAM = $User.FirstName + '.' + $User.LastName + '1'
                     $EmailAddress = "$($User.FirstName).$($User.LastName)@$($PracticeInfo.EmailDomain)"
                     $TargetAddress = "$($User.FirstName).$($User.LastName)1@linnaeusgroupcouk.mail.onmicrosoft.com"
                     $ProxyAddress = "$($User.FirstName).$($User.LastName)1@$($PracticeInfo.EmailDomain)"
                     $FullName = $User.FirstName + ' ' + $User.LastName + '1'
                     Write-LogError -Message "The SamAccountName is already in use. This user will be given the following SamAccountName: $SAM"
                     Write-Error -Message "The SamAccountName is already in use. This user will be given the following SamAccountName: $SAM"
                     Write-LogError -Message "The UPN is already in use. This user will be given the following UPN: $UPN"
                     Write-Error -Message "The UPN is already in use. This user will be given the following UPN: $UPN"
                 }
                 else {
                     $SamMatchNum = ($SamMatch | Select-String -Pattern '\d').Matches.Value | Sort-Object -Descending | Select-Object -First 1
                     $SamNextnum = [int]$SamMatchNum + 1
                     $UPN = "$($User.FirstName).$($User.LastName)$SamNextnum@linnaeusgroup.co.uk"
                     $SAM = $User.FirstName + '.' + $User.LastName + $SamNextnum
                     $EmailAddress = "$($User.FirstName).$($User.LastName)@$($PracticeInfo.EmailDomain)"
                     $TargetAddress = "$($User.FirstName).$($User.LastName) + $SamNextnum + @linnaeusgroupcouk.mail.onmicrosoft.com"
                     $ProxyAddress = "$($User.FirstName).$($User.LastName) + $SamNextnum + @$($PracticeInfo.EmailDomain)"
                     $FullName = $User.FirstName + ' ' + $User.LastName + $SamNextnum
                     Write-LogError -Message "The SamAccountName is already in use. This user will be given the following SamAccountName: $SAM"
                     Write-Error -Message "The SamAccountName is already in use. This user will be given the following SamAccountName: $SAM"
                     Write-LogError -Message "The UPN is already in use. This user will be given the following UPN: $UPN"
                     Write-Error -Message "The UPN is already in use. This user will be given the following UPN: $UPN"
                 }
 
                 # Uses the Workday ID to perform a lookup against AD for the line manager.
                 if ($User.LineManagerID) {
                     $Manager = (Get-ADUser -Filter "employeeNumber -eq '$($User.LineManagerID)'").DistinguishedName
                 }
                 else {
                 
                     $Manager 
                 }
 
           
                # Sets the password using the New-Password function
                $Password = New-Password
                $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force

                $OtherAttributes = @{}
                    #if ($User.WorkDayID) { $OtherAttributes.Add('employeeNumber', $User.WorkDayID) }
                    #if ($User.StartDate) { $OtherAttributes.Add('startDate', $User.StartDate) }
                    #if ($User.PreferredFirstName) { $OtherAttributes.Add('preferredFirstName', $User.PreferredFirstName) }
                    #if ($User.PreferredLastName ) { $OtherAttributes.Add('preferredLastName', $User.PreferredLastName) }
                    #if ($user.BusinessUnit) { $OtherAttributes.Add('businessUnit', $user.BusinessUnit) }
                    #if ($User.EmployeeType) { $OtherAttributes.Add('employeeType', $User.EmployeeType) }
                    #if ($User.Qualifications) { $OtherAttributes.Add('qualifications', $User.Qualifications) }
                    if ($PracticeInfo.PracticeWebpage) { $OtherAttributes.Add('wWWHomePage ', $PracticeInfo.PracticeWebpage) }
                    #if ($User.Extensionattribute11) { $OtherAttributes.Add('extensionAttribute11', $PracticeInfo.CustomAttribute11) }
                    #if ($User.Extensionattribute12) { $OtherAttributes.Add('extensionAttribute12', $PracticeInfo.CustomAttribute12) }
                    #if ($User.IsPeopleManager) { $OtherAttributes.Add('isPeopleMgr', $User.IsPeopleManager) }
            

                $NewUserParameters = @{

                    DisplayName           = $FullName + ' ' + $PracticeInfo.Brand
                    Name                  = $FullName
                    GivenName             = $User.FirstName
                    Surname               = $User.LastName
                    Company               = $PracticeInfo.AddrCompany
                    Department            = $User.Department
                    Title                 = $User.JobTitle
                    StreetAddress         = $PracticeInfo.AddrStreet
                    City                  = $PracticeInfo.AddrCity
                    PostalCode            = $PracticeInfo.AddrPostcode
                    State                 = $PracticeInfo.AddrStateProvince
                    Country               = $User.Country
                    OfficePhone           = $PracticeInfo.AddrPhone
                    Manager               = $Manager
                    EmployeeNumber        = $User.WorkdayID
                    OtherAttributes       = $OtherAttributes
            

                    EmailAddress          = $EmailAddress
                    UserPrincipalName     = $UPN
                    SamAccountName        = $SAM

                    Enabled               = $true
                    ChangePasswordAtLogon = $true
                    PasswordNeverExpires  = $false
                    AccountPassword       = $SecurePassword
                    Path                  = $PracticeInfo.OU

                }

                $ProxyAddress = $ProxyAddress
                $EmailAddress = $NewUserParameters.EmailAddress
                $TargetAddress = $TargetAddress

                try {      
                    $ADUser = New-AdUser @NewUserParameters -PassThru -ErrorAction Stop -ErrorVariable ADUsrErr
                 }
                catch{
                    Write-Error $ADUsrErr
                    Write-LogError -Message "Unable to create the AD Account for Workday ID: $($User.WorkdayID) - $($user.Fullname), please check that the data is in the correct format"
                    break
                }

                try {            
                    $TargetAdd = Set-ADUser -Identity $NewUserParameters.SamAccountName -Add @{TargetAddress = "SMTP:$TargetAddress"} -ErrorAction Stop -ErrorVariable ADUsrErr
                    $ProxyAdd1 = Set-ADUser -Identity $NewUserParameters.SamAccountName -Add @{ProxyAddresses = "SMTP:$ProxyAddress"} -ErrorAction Stop -ErrorVariable ADUsrErr
                    $ProxyAdd2 = Set-ADUser -Identity $NewUserParameters.SamAccountName -Add @{ProxyAddresses = "smtp:$TargetAddress"}-ErrorAction Stop -ErrorVariable ADUsrErr
                }
                catch{
                    Write-Error $ADUsrErr
                    Write-LogError -Message "Unable to set AD Attributes for Workday ID: $($User.WorkdayID) - $($user.Fullname), please check that the data is in the correct format"
                    break
                }
                
                try {
                    $ADGroup1 = Add-ADGroupMember -Identity $PracticeInfo.MFAGroup -Members $NewUserParameters.SamAccountName -ErrorAction Stop -ErrorVariable ADGrpErr
                    $ADGroup2 = Add-ADGroupMember -Identity 'WD - M365 Licence TEST' -Members $NewUserParameters.SamAccountName -ErrorAction Stop -ErrorVariable ADGrpErr
                }
                catch {
                    Write-Error $ADGrpErr
                    Write-LogError -Message "Unable to set AD Groups for Workday ID: $($User.WorkdayID) - $($user.Fullname), please check that the data is in the correct format"
                    break
                }

                try {
                    # Creates the exchange mailbox
                    $ExchangeMailbox = New-LinExchgMailbox -Identity $NewUserParameters.SamAccountName -PrimarySMTPAddress $ProxyAddress -RemoteRoutingAddress $TargetAddress -ErrorAction Stop -ErrorVariable ExchgErr
                }
                catch {
                    Write-Error $ExchgErr
                    Write-LogError -Message "There has been a problem creating the Exchange Mailbox for Workday ID: $($User.WorkdayID) - $($user.Fullname), please check that the data is in the correct format"
                    break
                }
                
                # Outputs a custom PSCustomObject using the provided properties
                $AccCreationProps = [Ordered]@{
                    'WorkDayID'       = $User.WorkDayID                  
                    'Name'            = $NewUserParameters.Name
                    'DisplayName'     = $NewUserParameters.DisplayName
                    'EmailAddress'    = $NewUserParameters.EmailAddress
                    'UPN'             = $NewUserParameters.UserPrincipalName
                    'SamAccountName'  = $NewUserParameters.SamAccountName
                    'OUPath'          = $NewUserParameters.Path
                    'Password'        = $Password
                    'ExchangeEnabled' = $ExchangeMailbox.IsValid
                } 
                $AccCreationObj = New-Object -TypeName PSCustomObject -Property $AccCreationProps
                Write-Output $AccCreationObj

                $UserAuditParams = @{
                    'WorkDayID'              = $User.WorkDayID                  
                    'Name'                   = $NewUserParameters.Name
                    'DisplayName'            = $NewUserParameters.DisplayName
                    'EmailAddress'           = $NewUserParameters.EmailAddress
                    'UPN'                    = $NewUserParameters.UserPrincipalName
                    'SamAccountName'         = $NewUserParameters.SamAccountName
                    'OUPath'                 = $NewUserParameters.Path
                    'ExchangeMailboxEnabled' = $ExchangeMailbox.IsValid
                }
                Write-UserCreationAudit @UserAuditParams
            
                Export-WorkdayUser -WorkDayID $User.WorkDayID -EmailAddress $EmailAddress
                
               
                $Content = @{
                    'NewStarterFullName'     = $NewUserParameters.Name
                    "LineManager"            = 'nathan.darker@linnaeusgroup.co.uk'
                    "LineManagerFirstName"   = 'Nathan'
                    "FirstName"              = $NewUserParameters.GivenName
                    "EmailTo"                = 'nathan.darker@linnaeusgroup.co.uk'
                    "Subject"                = "$($User.WorkDayID) - $($NewUserParameters.Name) - Account Credentials"
                    "ADPassword"             = $Password
                    "EmailAddress"           = 'nathan.darker@linnaeusgroup.co.uk'
                    "JobTitle"               = $NewUserParameters.Title
                }    
                Send-StarterEmail -Body $Content
        }
    }
    
    END {
        # Syncronises Azure AD
        Write-Verbose -Message "Syncronising to Azure AD"
        $DCSync = Invoke-Command -ComputerName 'hybrid-2.linnaeusgroup.co.uk' -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
        $i = 0    
        if ( $DCSync.result -ne 'Success') {
                While ($DCSync.result -ne 'Success'){
                    Write-Verbose "The AD Sync was unsuccessful, trying again..."
                    Start-Sleep -Seconds 60
                    $DCSync = Invoke-Command -ComputerName 'hybrid-2.linnaeusgroup.co.uk' -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
            
                $i++;
                
                if ($i -gt 2){
                    Write-Error "The AD Sync has failed $i times, please check the AD Sync Error log"
                    break
                }
            }
        } 
        if ( $DCSync.result -eq 'Success') { 
            Write-Verbose "The AD Sync was successful" 
        }
        Write-Verbose -Message "Closing down remote sessions"
        Get-PSSession | Remove-PSSession
    }
}

# New Starter - This creates a password meeting the Linnaeus password complexity requirements
Function New-Password {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false
        )]
        [ValidateRange(5, 79)]
        [int]    $Length = 16,

        [switch] $ExcludeSpecialCharacters

    )


    BEGIN {
        $SpecialCharacters = @((33, 35) + (36, 38) + (42, 43) + (63, 64))
    }

    PROCESS {
        try {
            if (-not $ExcludeSpecialCharacters) {
                $Password = -join ((48..57) + (65..72) + (74..90) + (97..104) + (106..107) + (109..122) + $SpecialCharacters | Get-Random -Count $Length | ForEach-Object { [char]$_ })
            }
            else {
                $Password = -join ((48..57) + (65..72) + (74..90) + (97..104) + (106..107) + (109..122) | Get-Random -Count $Length | ForEach-Object { [char]$_ })
            }

        }
        catch {
            Write-Error $_.Exception.Message
        }

    }

    END {
        Write-Output $Password
    }

}

# New Starter - This provision a new on premise exchange mailbox
Function New-LinExchgMailbox {
    [CmdletBinding()]
    param (
        [string]$Identity,
        [string]$PrimarySMTPAddress,
        [string]$RemoteRoutingAddress
    )
    begin {
        
    }
    process {    
        Enable-RemoteMailbox -Identity $Identity -PrimarySMTPAddress $PrimarySMTPAddress -RemoteRoutingAddress $RemoteRoutingAddress
    }
    end {}
        
}

# New Starter - This writes output to the error log in OneDrive - linnaeusgroup.co.uk\Workday\Logs
function Write-LogError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message

    )
    
    $Line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Message'  = $Message
    }
    
    $Line | Export-Csv -Path "C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Logs\Exception_$Date.log" -Append -NoTypeInformation
}

# New Starter - This writes output to the user creation audit log in OneDrive - linnaeusgroup.co.uk\Workday\Audit
function Write-UserCreationAudit {
    [CmdletBinding()]
    param (
        [string]$WorkDayID,        
        [string]$Name,
        [string]$DisplayName,
        [string]$EmailAddress,
        [string]$SamAccountName,
        [String]$UPN,
        [string]$OUPath,
        [string]$ExchangeMailboxEnabled
        
    )
    
    $Line = [pscustomobject]@{
        'DateTime'               = (Get-Date)
        'WorkDayID'              = $WorkDayID
        'Name'                   = $Name
        'DisplayName'            = $DisplayName
        'EmailAddress'           = $EmailAddress
        'UPN'                    = $UPN
        'SamAccountName'         = $SamAccountName
        'OUPath'                 = $OUPath
        'ExchangeMailboxEnabled' = $ExchangeMailboxEnabled
    }
    
    $Line | Export-Csv -Path "C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Audit\New Starter\UserCreationAudit_$Date.log"  -NoTypeInformation -Append
}

# New Starter - This exports the Workday ID and Email Address of the user to the outbound file which MVH expect to recieve in OneDrive - linnaeusgroup.co.uk\Workday\Outbound
function Export-WorkdayUser {
    [CmdletBinding()]
    param (
        [string]$WorkDayID,        
        [string]$EmailAddress
    )
    
    $Line = [pscustomobject]@{
        'WorkDayID'    = $WorkDayID
        'EmailAddress' = $EmailAddress
    }
    $Line | Export-Csv -Path "C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Outbound\Linnaeus_EMAIL_$Date.txt" -Delimiter '|' -NoTypeInformation -Append
}

# New Starter - This uses regex to check that characters contain the expected values A-Z(Upper) a-z(Lower) '(Apostrophe) -(Hyphen)
function Find-LinPattern {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string[]]$String,
        [string]$Pattern = "[A-Za-z'-]+"
    )
    begin{}
    
    process{
        $MatchStr = ($String| Select-String -Pattern $Pattern -AllMatches).Matches.Value -join ' '
        Write-Output $MatchStr
    }
    
    end{}
}

# New Starter - This generates a welcome email
function Send-WelcomeEmail{
    [CmdletBinding()]
    param (
        $url = 'https://prod-29.ukwest.logic.azure.com:443/workflows/ae1e30bb105646da871e9061abe6e0d9/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=9PeUl5UC00KZ2TpLQXJQUEMT0i3eTml3Dn0-sXAQexE',
        [hashtable]$Body
    )

    Invoke-RestMethod -Method 'Post' -Uri $Url -Body ($Body | ConvertTo-Json) -ContentType 'application/json'
}

# New Starter -  This generates an email containing credentials
function Send-StarterEmail {
    [CmdletBinding()]
    param (
        $Url = 'https://prod-06.ukwest.logic.azure.com:443/workflows/c4439c0fcee64fe4bcf1043e5c6fbba1/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=TInyWgF0OvYyX5SG8Pd_kws_SmsN8206BjHcZCnTMNE',
        [hashtable]$Body
    )
 
    Invoke-RestMethod -Method 'Post' -Uri $Url -Body ($Body | ConvertTo-Json) -ContentType 'application/json'
}







