[CmdletBinding()]
param (
[Parameter(Mandatory,HelpMessage="Enter a computer name to query")]
[Alias('Hostname')]  
[string]$computername,

[ValidateSet(2,3)]
[int]$drivetype = 3
)
Write-Verbose "Connecting to $computername"
Write-Verbose "Looking for drive type $drivetype"
Get-CimInstance -ClassName Win32_LogicalDisk `
  -ComputerName $computername `
  -Filter "DriveType=$drivetype" |
Sort-Object -Property DeviceID |
Select-Object -Property DeviceID,
  @{name='FreeSpace(MB)' ; expression={$_.FreeSpace / 1MB -as [Int]}},
  @{name='Size(GB)' ; expression={$_.Size / 1gb -as [Int]}},
  @{name='%Free' ; expression={$_.FreeSpace / $_.Size * 100 -as [Int]}}
Write-Verbose "Finished running command"