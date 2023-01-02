Get-ChildItem -Path . -Recurse |
Group-Object -Property Extension -NoElement |
Sort-Object -Property Count -Descending

Get-ChildItem -Recurse -Filter '*.ps1' |
Measure-Object -Property Length -Sum | Select-Object -Property Count, @{n='Size(GB)'; e={("{0:N2}") -f ($_.sum / 1MB)}}

$Team | ConvertTo-Csv | ForEach-Object {$_ -replace '"',"" } | >> Out-File -Path team.csv -Encoding ascii

$Source = 'D:\VoyagerEnterprise'

Get-ChildItem -Path $Source -Recurse |
Where-Object {$_.PSIsContainer -eq $false} |
Group-Object -Property Extension -NoElement | 
Sort-Object -Property Count -Descending


Get-ChildItem -Path $Source -Recurse |
Where-Object {$_.PSIsContainer -eq $false} |
Measure-Object -Property Length -Sum | 
Select-Object -Property Count, @{n='Size(GB)'; e={("{0:N2}") -f ($_.sum / 1GB)}} 

[System.IO.Path]::GetFileNameWithoutExtension('mytextfile.txt')

$CSV1.Name | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }

$D.FullName | ForEach-Object { [System.IO.Path]::GetExtension($_) }

$D.FullName | Foreach-Object { [System.IO.Path]::GetFileName($_) }