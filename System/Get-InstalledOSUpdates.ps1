function Get-InstalledOSUpdates {
    [CmdletBinding()]
    param(
        [string]$ComputerName = 'localhost'
    )

    Get-CimInstance -ClassName win32_quickfixengineering -ComputerName $ComputerName | 
    Select-Object -Property @{n='HostName' ; e={$_.CSName}}, HotFixID, Description, Caption, InstalledOn |
    Sort-Object -Property InstalledOn -Descending
}
