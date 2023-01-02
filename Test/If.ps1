$FilePath1 = 'C:\Users\Nathan\Files\Test\_names.txt'
$Content = Get-Content -Path $FilePath1

if ( Test-Path -Path $FilePath1  ) {
    Write-Output "The file exists at $FilePath1"
    if ( $Content.Count -gt 10 ) {
        Write-Output "The file contains more than 10 names"
    }
    elseif ( $Content.Count -ge 5) {
        Write-Output "The file contains between 5 - 10 names"
            
    }
    elseif ( $Content.Count -ge 1) {
        Write-Output "The file contains between 1- 5 names "
    }
    else { Write-Output "The file is empty" }
}
else {
    Write-Output "The file does not exist at $FilePath1"
}