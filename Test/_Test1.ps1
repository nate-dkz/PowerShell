$CredXML = Import-Clixml -Path 'C:\Users\Nathan\OneDrive - Nathan Darker IT\Documents\PS\ND.xml'
$DCSession = New-PSSession -Credential $CredXML -ComputerName DCArkham -Authentication Kerberos -Name DC
$ADModule = Import-PSSession -Session $DCSession -Module ActiveDirectory, ADSync -CommandName Get-ADUser, New-ADUser, Set-ADUser, Add-ADGroupMember, Start-ADSyncSyncCycle -AllowClobber
$ExchgSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://server2016.arkham.co.uk/PowerShell/" -Credential $CredXML -Authentication Kerberos -Name Exchange
$ExchgModule = Import-PSSession -Session $ExchgSession -DisableNameChecking -AllowClobber

$global:LogFilePath = 'C:\Users\Nathan\Files\Workday\Logs\OnboardingLogFile.log'

try { 
    $ExchgSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://server2016.arkham.co.uk/PowerShell/" -Credential $CredXML -Authentication Kerberos -Name Exchange -ErrorAction Stop -ErrorVariable ExchgSession
}
catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
    Write-Error "Unable to connect to the Exchange Server, check that the server is accessible"
    Write-Log -Message $_.Exception.Message -Severity 3
}
catch {
    Write-Error $ExchgSession.Message
    Write-Log -Message $_.Exception.Message
}
