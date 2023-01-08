function Get-FileSize {
     <#
    .SYNOPSIS
    Retrieves file sizes from a specified path.

    .DESCRIPTION
    The Get-FileSize function searches the specified path for files and retrieves their names and sizes. The sizes are returned in kilobytes.

    .PARAMETER Path
    The path to search for files. If no path is specified, the user will be prompted to enter a path.
    #>
    [CmdletBinding()]
    param (
        [String]$Path = (Read-Host 'Enter the path you want to use')
    )

    Get-ChildItem -Path $Path -Recurse -File |
    Select-Object -Property Name, @{n='Size' ; e={("{0:N2}" -f ($_.Length / 1KB))}}
}
