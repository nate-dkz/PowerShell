$os = (Get-CimInstance win32_operatingsystem)
$os.LastBootUpTime

Get-Uptime -Since

SystemInfo | Select-String "System Boot Time"

param (
    $ComputerName = 'localhost'
)
Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"