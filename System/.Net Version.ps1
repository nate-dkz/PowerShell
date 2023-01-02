Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\' -Recurse |
    Get-ItemProperty -Name Version -ea 0 |
    Where-Object {$_.PSChildName -match '^(?!S)\p{L}'} |
    Select-Object -Property PSChildName, Version


Install-Module -Name DotNetVersionLister -Scope CurrentUser #-Force
Get-STDotNetVersion