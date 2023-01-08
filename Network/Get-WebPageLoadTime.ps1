function Get-WebPageLoadTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Url
    )

    $pattern = '^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&''\(\)\*\+,;=.]+$'

    if ($Url -match $pattern) {
        $TimeTaken = Measure-Command -Expression {
            Invoke-WebRequest -Uri $Url
        }

        $seconds = [Math]::Round($TimeTaken.TotalSeconds, 4)

        Write-Output "$Url took $seconds seconds to load"
    }
    else {
        Write-Output "Invalid URL"
    }
}
