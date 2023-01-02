$url = Read-Host "Enter the domain name e.g. wikipedia.org, duckduckgo.com"

$TimeTaken = Measure-Command -Expression {
    Invoke-WebRequest -Uri $url
}

$seconds = [Math]::Round($TimeTaken.TotalSeconds, 4)

Write-Output "$url took $seconds seconds to load"