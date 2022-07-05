function Get-FileExtension {
    
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]$Path
    )

    BEGIN {
        Write-Verbose "Grouping files in $Path"
        
    }

    PROCESS {
        $CountFiles = Get-ChildItem -Path $Path  -File |
        Group-Object -Property Extension -NoElement |
        Sort-Object -Property Count -Descending
        Write-Output $CountFiles

    }

    END {
        $TotalFiles = $CountFiles | Measure-Object -Property Count -Sum
        Write-Verbose "There are $($TotalFiles.Sum) files in this directory"
    }

}