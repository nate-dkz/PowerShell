function Get-FileInfo {
    <#
    .SYNOPSIS
    Retrieves file information from a specified search path and exports it to a CSV file.

    .DESCRIPTION
    The Get-FileInfo function searches the specified search path for files and retrieves their directory, name, and last write time. The retrieved information is then exported to a CSV file at the specified destination path.

    .PARAMETER SearchPath
    The path to search for files.

    .PARAMETER DestinationPath
    The path to save the CSV file.
    #>
    [CmdletBinding()]
    param (
        $SearchPath = (Read-Host "Enter the search path"),
        $DestinationPath = (Read-Host "Enter the destination path")
    )

    Get-ChildItem -Path $SearchPath -Recurse -File |
    Select-Object -Property Directory, Name, LastWriteTime |
    Export-Csv -Path "$DestinationPath\Result.csv"
}
