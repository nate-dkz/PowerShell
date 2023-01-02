
Get-ChildItem -Recurse -File |
Select-Object -Property Directory, Name, LastWriteTime |
Export-Csv -Path \DataAnalysis.csv


# For versions older than 5.1

Get-ChildItem -Recurse |
Where-Object {-not $_.PSIsContainer} |
Select-Object -Property Directory, Name, LastWriteTime |
Export-Csv -Path \DataAnalysis.csv