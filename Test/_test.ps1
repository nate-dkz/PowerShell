function Get-LocalNetIP {
    [cmdletbinding()]
    param (
        [regex]$Local = '192\.\d+',
        [regex]$Remote = '\d{2,3}'
    )
    Get-NetTCPConnection |
    Where-Object { $_.LocalAddress -like $Local -and $_.RemoteAddress -match $Remote }
}
