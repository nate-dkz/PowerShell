function Get-FileExtensionCount {
    <#
    .SYNOPSIS
    Counts the number of files with each extension in a specified directory.

    .DESCRIPTION
    The Get-FileExtensionCount function searches the specified path for files and counts the number of files with each extension. The results are returned sorted by count, with the most common extensions listed first.

    .PARAMETER Path
    The path to search for files. This parameter is required.
    #>
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
        $CountFiles = Get-ChildItem -Path $Path -File -Recurse |
        Group-Object -Property Extension -NoElement |
        Sort-Object -Property Count -Descending
        Write-Output $CountFiles

    }

    END {
        $TotalFiles = $CountFiles | Measure-Object -Property Count -Sum
        Write-Verbose "There are $($TotalFiles.Sum) files in this directory"
    }

}