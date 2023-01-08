# Introduction
This file contains a collection of PowerShell commands that I have found to be useful. I have gathered these commands in one place as a reference point to refer back to whenever I need them.

<details>
<summary><b><font size="+1">Network</font></b></summary>
</br>

Displays the IPv4 addresses.
```PowerShell
Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4
```
Sets a new IP address.
```PowerShell
$IPAddress = '192.168.0.20'
$DefaultGateway = '192.168.0.1'
New-NetIPAddress -InterfaceIndex 13 -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway
```
</details>

<details>
<summary><b><font size="+1">Date & Time</font></b></summary>
</br>

Displays time interval between the start and end date.
```PowerShell
[DateTime]$FromDate = '06/12/2022 08:00'
[DateTime]$ToDate = '06/20/2022 14:00'

New-TimeSpan -Start $FromDate -End $ToDate
```

Displays the difference between dates.
```PowerShell
[datetime]$FromDate = '12/25/2022'
[datetime]$ToDate = '12/28/2022'
($ToDate - $FromDate).TotalDays
```

Displays the difference between times.
```PowerShell
[datetime]$FromDate = '06/12/2022 08:00'
[datetime]$ToDate = '06/20/2022 14:00'
($ToDate - $FromDate).TotalHours
```
</details>