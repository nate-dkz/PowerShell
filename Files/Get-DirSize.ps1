# Requires -version 5.1
function Get-DirSize {
    <#
    .SYNOPSIS
        Retrieves folder and file information for one or more specified locations.
    .DESCRIPTION
        The Get-DirSize function retrieves folder and file information for one or more specified locations.
        You can use the Recurse parameter to get items in all child containers.
        
        Get-DirSize does not return information from hidden folders. 
    .NOTES
        
    .EXAMPLE 
        Get-DirSize -Path C:\Users\Files

        Folder                TotalSubFolders TotalFiles TotalSize(MB)
        ------                --------------- ---------- -------------
        C:\Users\Files              5             1            4
    .EXAMPLE
        'C:\Users\Files','C:\Users\OneDrive Dev\Documents\WindowsPowerShell' | Get-DirSize

        Folder                                                            TotalSubFolders TotalFiles TotalSize(MB)
        ------                                                            --------------- ---------- -------------
        C:\Users\Files                                                          5           1             4
        C:\Users\OneDrive - Dev\Documents\WindowsPowerShell                     11         30            255
    .EXAMPLE
        'C:\Users\Files','C:\Users\OneDrive Dev\Documents\WindowsPowerShell' | Get-DirSize -Recurse

        Folder                                                            TotalSubFolders TotalFiles TotalSize(MB)
        ------                                                            --------------- ---------- -------------
        C:\Users\Files                                                          30            74           161
        C:\Users\OneDrive - Dev\Documents\WindowsPowerShell                     82            385          755
    .INPUTS
        System.String
            You can pipe a string that contains a path to Get-DirSize.

    .OUTPUTS
        System.PSCustomObject
            Get-DirSize returns PSCustomObjects.

    #>
    [cmdletbinding()]
    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipeline)]
        [string[]]$Path,

        [switch]$Recurse
    )

    BEGIN{

        $R = $Recurse.IsPresent
    }

    PROCESS{
        
        foreach ( $P in $Path) {
            $Files = Get-ChildItem -Path $P -Recurse:$R | Measure-Object -Property Length -Sum
            $FileCount = $Files.Count
            $FileSizeMB = "{0:N0}" -f ($Files.Sum / 1MB)

            $FolderCount = (Get-ChildItem -Path $P -Directory -Recurse:$R | Measure-Object).Count

            [PSCustomObject]@{
                'Folder' = $P
                'TotalSubFolders' = $FolderCount 
                'TotalFiles' = $FileCount
                'TotalSize(MB)' = $FileSizeMB -as [Int]
            }
        }
    }
    
    END{}

}
