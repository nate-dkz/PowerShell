$DCSession = New-PSSession -ComputerName 'ArkhamDC' -Credential 'arkham\n.darker' -Authentication Kerberos
$ADModule = Import-PSSession -Session $DCSession -Module ActiveDirectory