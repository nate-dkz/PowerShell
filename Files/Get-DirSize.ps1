function Get-DirSize {
     <#
    .SYNOPSIS
    Retrieves the size of a specified directory and its subdirectories.

    .DESCRIPTION
    The Get-DirSize function searches the specified path for directories and retrieves the total number of subfolders, total number of files, and total size of the specified directory and its subdirectories. The size is returned in megabytes.

    .PARAMETER Path
    The path to search for directories. This parameter is required.

    .PARAMETER Recurse
    Specifies whether to search subdirectories recursively. By default, subdirectories are not searched recursively.
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
