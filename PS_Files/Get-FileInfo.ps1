function Get-FileInfo {
    
    [Cmdletbinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$Path

    )

    BEGIN {}

    PROCESS {
        
        Get-ChildItem -Path $Path -File |
        Sort-Object -Property Directory, LastWriteTime |
        Select-Object -Property LastWriteTime, Name, Directory
        
    }

    END {}
}
    
