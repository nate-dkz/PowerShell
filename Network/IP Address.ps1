# Returns the IPv4 addresses
Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4

# Sets a new IP address
New-NetIPAddress -InterfaceIndex 13 -IPAddress 192.168.0.201 -PrefixLength 24 -DefaultGateway 192.168.0.1