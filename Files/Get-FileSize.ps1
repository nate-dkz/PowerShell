$Path = 'C:\Users\ND\Files'

Get-ChildItem -Path $Path -Recurse -File |
Select-Object -Property Name, @{n='Size' ; e={("{0:N2}" -f ($_.Length / 1KB))}}