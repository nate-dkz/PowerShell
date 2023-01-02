
$ExampleDriveTypePreference = 'Local'
$ExampleErrorLogFile = 'C:\Users\Nathan\Files\Errors.txt'

function Get-DiskSpaceInfo {
    <#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'Computer name to query',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [String[]]$ComputerName,
        
        [Parameter(Position = 2,
            ValueFromPipelineByPropertyName)]
        [ValidateSet('Floppy', 'Local', 'Optical')]
        [String]$DriveType = $ExampleDriveTypePreference,

        [String]$ErrorLogFile = $ExampleErrorLogFile
    )
    BEGIN {
        Remove-Item -Path $ErrorLogFile -ErrorAction SilentlyContinue # If the Error Log exists remove the file, if the error log does not exist silently continue
    }
    PROCESS {
        foreach ($Computer in $ComputerName) {
            $Params = @{'ComputerName' = $Computer;
                'Class'                = 'Win32_LogicalDisk'
            }
            switch ($DriveType) {
                'Local' { $Params.Add('Filter', 'DriveType=3'); break }
                'Floppy' { $Params.Add('Filter', 'DriveType=2'); break }
                'Optical' { $Params.Add('Filter', 'DriveType=3'); break }           
            }
            try {
                Get-WmiObject @Params -ErrorAction Stop -ErrorVariable myerr
                Select-Object @{n = 'Drive' ; e = { $_.DeviceID } },
                @{n = 'Size' ; e = { "{0:N2}" -f ($_.Size / 1GB) } },
                @{n = 'FreeSpace' ; e = { "{0:N2}" -f ($_.FreeSpace / 1GB) } },
                @{n = 'FreePercent' ; e = { "{0:N2}" -f ($_.FreeSpace / $_.Size * 100) } }
            }
            catch {
                $Computer | Out-File $ErrorLogFile -Append
                Write-Verbose "Failed to connect to $Computer; error is $myerr"
            }
        }
    }
    END {}
}