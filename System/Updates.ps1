
Get-CimInstance -ClassName win32_quickfixengineering | 
Select-Object -Property CSName, HotFixID, Description, Caption, InstalledOn, InstalledBy |
Sort-Object -Property InstalledOn -Descending