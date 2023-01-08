function Get-DiskInventory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage="Enter a computer name to query")]
        [Alias('Hostname')]  
        [string]$ComputerName,

        [ValidateSet(2,3)]
        [int]$DriveType = 3
    )

    Write-Verbose "Connecting to $ComputerName"
    Write-Verbose "Looking for drive type $DriveType"

    Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputernName -Filter "DriveType=$DriveType" |
    Sort-Object -Property DeviceID |
    Select-Object -Property DeviceID,
      @{name='FreeSpace(MB)' ; expression={$_.FreeSpace / 1MB -as [Int]}},
      @{name='Size(GB)' ; expression={$_.Size / 1gb -as [Int]}},
      @{name='%Free' ; expression={$_.FreeSpace / $_.Size * 100 -as [Int]}}
    
    Write-Verbose "Finished running command"
}