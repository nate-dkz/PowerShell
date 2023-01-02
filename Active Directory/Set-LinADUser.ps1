# Global variables
$WorkdayUserFile = 'C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Inbound\Linnaeus_AD_Maint_20220811_141451.TXT'

# Leaver - This is the main part of the script which calls upon the other functions to processes leavers
function Set-LinADUser {
    
    [CmdletBinding()]
    param ()
    begin {
        $Date = Get-Date -Format 'yyyMMddHHmmss'
        if (-not(Test-Path -Path $WorkdayUserFile)) {
                Write-LogError 'Script terminated - The workday leaver file does not exist, no users to offboard'
                Write-Error 'The workday leaver file does not exist, no users to offboard' -ErrorAction Stop
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
            $ADModule = Import-PSSession -Session $DCSession -Module ActiveDirectory, ADSync -CommandName Get-ADUser, Set-ADUser, Remove-ADGroupMember, Move-ADObject, Start-ADSyncSyncCycle -AllowClobber
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
    process {
        
        foreach ($User in $userList) {
            $ADUser = Get-ADUser -Filter "employeeNumber -eq '$($User.WorkDayID)'" -Properties employeeNumber
            Set-ADUser -Identity $ADUser.DistinguishedName  -Enabled $false
            $ADUserGroup = (Get-ADUser -Filter "employeeNumber -eq '$($User.WorkDayID)'" -Properties MemberOf).MemberOf

            foreach ( $Group in $ADUserGroup ) { 
                Remove-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -Confirm:$false
            }
        
            Move-ADObject -Identity $($ADUser.DistinguishedName) -TargetPath 'OU=Test Offboard,OU=ExchangeTenants,DC=linnaeusgroup,DC=co,DC=uk'
            $ADUser = Get-ADUser -Filter "employeeNumber -eq '$($User.WorkDayID)'" -Properties MemberOF
            $NewWorkdayID =  Set-ADUser -Identity $ADUser.DistinguishedName -Replace @{employeeNumber = "$($User.WorkDayID)-L$Date"}
            $ADUserUpdate = (Get-ADUser -Identity $ADUser.DistinguishedName -Properties employeeNumber).employeeNumber

            $Props = [Ordered]@{
                'OriginalWorkDayID'         = $User.WorkDayID
                'AmendedkDayID'             = $ADUserUpdate               
                'Name'                      = $User.FullName
                'EmailAddress'              = $ADUser.UserPrincipalName  
                'AccountActive'             = $ADUser.Enabled
                'MemberGroups'              = $ADUser.MemberOF
            } 
            $Obj = New-Object -TypeName PSCustomObject -Property $Props
            Write-Output $Obj 

            $UserAuditParams = @{
                'OriginalWorkDayID'      = $User.WorkDayID
                'AmendedWorkDayID'       = $ADUserUpdate                   
                'Name'                   = $User.FullName
                'EmailAddress'           = $ADUser.UserPrincipalName
                'AccountActive'          = $ADUser.Enabled
     
            }
            Write-UserRemovalAudit @UserAuditParams

            $Content = @{
                    'LeaverFullName'          = $Props.Name
                    "LineManager"             = 'nathan.darker@linnaeusgroup.co.uk'
                    "LineManagerFirstName"    = 'Nathan'
                    "FirstName"               = $User.FirstName
                    "EmailTo"                 = 'nathan.darker@linnaeusgroup.co.uk'
                    "Subject"                 = "$($Props.OriginalWorkDayID) - $($Props.Name) - IT Leaver"
            }

            Send-LeaverEmail -Body $Content
        
        }
    }
    end {
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

# Leaver - This writes output to the error log in OneDrive - linnaeusgroup.co.uk\Workday\Logs
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

# Leaver - This writes output to the user removal audit log in OneDrive - linnaeusgroup.co.uk\Workday\Audit
function Write-UserRemovalAudit {
    [CmdletBinding()]
    param (
        [string]$OriginalWorkDayID,
        [string]$AmendedWorkdayID,      
        [string]$Name,
        [string]$EmailAddress,
        [string]$SamAccountName,
        [string]$AccountActive
        
    )
    
    $Line = [pscustomobject]@{
        'DateTime'               = (Get-Date)
        'OriginalWorkDayID'      = $User.WorkDayID
        'AmendedWorkDayID'       = $ADUserUpdate   
        'Name'                   = $Name
        'EmailAddress'           = $EmailAddress
        'SamAccountName'         = $SamAccountName
        'AccountActive'          = $AccountActive
    }
    
    $Line | Export-Csv -Path "C:\Users\Nathan.Darker\OneDrive - linnaeusgroup.co.uk\Workday\Audit\Leaver\UserRemovalAudit_$Date.log"  -NoTypeInformation -Append
}

# Leaver - This generates an email confirming a leaver
function Send-LeaverEmail {
[CmdletBinding()]
    param (
        $url = 'https://prod-31.ukwest.logic.azure.com:443/workflows/d1379f279a434f08967b6c030dd934ba/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=rKRLpbL3opqVxLPKNyNDCrOxFR5Rrc-yItLzvJhYiNc',
        [HashTable]$Body
    )
    Invoke-RestMethod -Method 'Post' -Uri $url -Body ($body|ConvertTo-Json) -ContentType "application/json"
}
