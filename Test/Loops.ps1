$i = 1
Do {
    Write-Output "PowerShell is great! $i"
    $i++
} While ($i -le 5)

$i = 1
Do {
    Write-Output "PowerShell is great! $i"
    $i++
} Until ($i -gt 5)

$Services = Get-Service -Name Win*
foreach ($S in $Services) {
    $S.Name
}

for ($i = 0; $i -lt 5; $i++) {
    Write-Output "The number is $i"
}

1..5 | ForEach-Object -Process {
    Get-Service -Name WinRM
}