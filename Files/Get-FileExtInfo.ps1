$FileType = 'ps1'

Get-ChildItem -Filter "*.$FileType" -Recurse |
    Where-Object {$_.LastAccessTime.ToShortDateString() -gt (Get-Date -Date 2022-12-01)} |
    ForEach-Object -Begin {Get-Date} -Process {
    Out-File -FilePath .\files.txt -Append -InputObject $_.FullName}