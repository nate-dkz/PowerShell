function New-NDADUser {
    
    [CmdletBinding()]
    param (
        [object]$UserList = (Import-Csv -Path 'C:\Users\ND\Files\Data\ADUsers.csv')
    )  
    
    BEGIN {

        try {
            $CredXML = Import-Clixml -Path 'C:\Users\ND\Files\Data\NDPS.xml'
            $DCSession = New-PSSession -Credential $CredXML -ComputerName ArkhamDC -Name DC -Authentication Kerberos
            $ADModule = Import-PSSession -Session $DCSession -Module ActiveDirectory, ADSync -CommandName Get-ADUser, New-ADUser, Set-ADUser, Add-ADGroupMember, Start-ADSyncSyncCycle -AllowClobber
        }
        
        catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
            Write-Error "Unable to connect to the remote Server, check that the server is accessible"
            Write-LogError -Message $_.Exception.Message -Severity 1
            throw (Get-PSSession | Remove-PSSession)
        }
    }
    
    PROCESS {

        foreach ($User in $UserList) {
            $SAM = $User.FirstName + '.' + $User.LastName
            $FullName = $User.FirstName + ' ' + $User.LastName
            
            # Checks if the user in the current iteration exists within AD.
            $SamMatch = $((Get-ADUser -Filter "SamAccountName -like '$SAM*'").SamAccountName)
        
            if ( $SamMatch.Count -eq 0 ) {
                $UPN = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())@arkham.live"
                $SAM = $User.FirstName + '.' + $User.LastName
                $EmailAddress = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())@arkham.live"
                $FullName = $FullName
            } 
            elseif ( $SamMatch.Count -eq 1) {
                $UPN = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())1@arkham.live"
                $SAM = $User.FirstName + '.' + $User.LastName + '1'
                $EmailAddress = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())1@arkham.live"
                $FullName = $FullName + '1'
                Write-Verbose "The username already exists. This user will be given the following SamAccountName: $SAM"
            }
            else {
                $SamMatchNum = ($SamMatch | Select-String -Pattern '\d').Matches.Value | Sort-Object -Descending | Select-Object -First 1
                $SamNextnum = [int]$SamMatchNum + 1
                $UPN = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())$SamNextnum@arkham.live"
                $SAM = $User.FirstName + '.' + $User.LastName + $SamNextnum
                $EmailAddress = "$($User.FirstName.ToLower()).$($User.LastName.ToLower())$SamNextnum@arkham.live"
                $FullName = $FullName + $SamNextnum
                Write-Verbose "The username already exists. This user will be given the following SamAccountName: $SAM"
            }

            # Uses the manager name to perform a lookup against AD for the line managers distinguished name.
            if ($User.Manager) {
                $Manager = (Get-ADUser -Filter "name -eq '$($User.Manager)'").DistinguishedName
            }
            else {
                
                $Manager 
            }

            # Sets user password using the New-Password function
            $Password = New-Password
            $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        
            $OtherAttributes = @{}
                            
            if ($User.EmployeeType) { $OtherAttributes.Add('employeeType', $User.EmployeeType) }
            # if ($User.Qualifications) { $OtherAttributes.Add('qualifications', $User.Qualifications) }
            if ($user.Website) { $OtherAttributes.Add('wWWHomePage ', $user.Website) }
            # if ($User.IsPeopleManager) { $OtherAttributes.Add('isPeopleMgr', $User.IsPeopleManager) }
            

            $NewUserParameters = @{

                EmployeeID = $User.EmployeeID
                DisplayName = $FullName
                Name = $FullName
                GivenName = $User.FirstName
                Surname = $User.LastName
                Company = $User.Company
                Department = $User.Department
                Title = $User.JobTitle
                StreetAddress = $User.Address
                City = $User.City
                PostalCode = $User.Postcode
                State = $User.State
                Country = $user.Country
                OfficePhone = $User.PhoneNo
                Manager = $Manager
                OtherAttributes = $OtherAttributes
            

                EmailAddress = $EmailAddress
                UserPrincipalName = $UPN
                SamAccountName = $SAM

                Enabled = $true
                ChangePasswordAtLogon = $true
                PasswordNeverExpires = $false
                AccountPassword = $SecurePassword
                Path = "OU=$($User.Department),OU=IT,OU=Arkham,DC=arkham,DC=co,DC=uk"

            }

            $RemoteRoutingAddress = $NewUserParameters.SamAccountName + '@qc27.onmicrosoft.com'
            $ProxyEmailAddress = $NewUserParameters.SamAccountName + '@arkham.onmicrosoft.com'
            $EmailAddress = $NewUserParameters.EmailAddress

            try {      
                $ADUser = New-AdUser @NewUserParameters -PassThru  -ErrorAction Stop -ErrorVariable ADUsrErr
                $Proxy1 = Set-ADUser -identity $NewUserParameters.SamAccountName -Add @{ProxyAddresses = "SMTP:$EmailAddress" }
                $Proxy2 = Set-ADUser -identity $NewUserParameters.SamAccountName -Add @{ProxyAddresses = "smtp:$ProxyEmailAddress" }
            }
            catch {
                Write-Output $ADUsrErr
                throw
            }
            
            $ADGroup1 = Add-ADGroupMember -Identity $User.Department -Members $NewUserParameters.SamAccountName
        
            
            # Outputs a custom PSCustomObject using the provided properties
            $AccCreationProps = [Ordered]@{
                'EmployeeID' = $User.EmployeeID                 
                'Name' = $FullName
                'EmailAddress' = $EmailAddress
                'SamAccountName' = $NewUserParameters.SamAccountName
                'OU' = $NewUserParameters.Path
                'Password' = $Password
            } 

            $AccCreationObj = New-Object -TypeName PSCustomObject -Property $AccCreationProps
            Write-Output $AccCreationObj

            $UserAuditParams = @{
                'EmployeeID' = $User.EmployeeID                  
                'Name' = $User.FullName
                'EmailAddress' = $EmailAddress
                'SamAccountName' = $NewUserParameters.SamAccountName
            }
            
            Write-UserAudit @UserAuditParams
        }
    }
    
    END {
        # Syncronises Azure AD and closes down the remote sessions to the domain controller
        Write-Verbose -Message "Syncronising to Azure AD"
        $DCSync = Start-DCSync
        Write-Verbose -Message "Closing down remote sessions"
        Get-PSSession | Remove-PSSession
    } 
}
    
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
                $Password = -join ((48..57) + (65..90) + (97..122) + $SpecialCharacters | 
                Get-Random -Count $Length | 
                ForEach-Object { [char]$_ })
            }
            else {
                $Password = -join ((48..57) + (65..90) + (97..122) | 
                Get-Random -Count $Length | 
                ForEach-Object { [char]$_ })
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

Function Start-DCSync {
    Start-ADSyncSyncCycle
    Start-Sleep -Seconds 60
}


function Write-LogError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('1', '2', '3')]
        [int]$Severity = 1 ## Default to a low severity. Otherwise, override
    )
    
    $Line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Message'  = $Message
        'Severity' = $Severity
    }
    
    $Line | Export-Csv -Path "C:\Users\ND\Files\Logs\Exception_($Date).log" -Append -NoTypeInformation
}

function Write-UserAudit {
    [CmdletBinding()]
    param (
        [string]$EmployeeID,        
        [string]$Name,
        [string]$EmailAddress,
        [string]$SamAccountName,
        [string]$Path           
    )
    
    $Line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'EmployeeID' = $EmployeeID
        'Name' = $Name
        'EmailAddress' = $EmailAddress
        'SamAccountName' = $SamAccountName
        'Path' = $Path
    }
    
    $Line | Export-Csv -Path "C:\Users\ND\Files\Logs\UserCreationAudit_($Date).log" -Append -NoTypeInformation
}