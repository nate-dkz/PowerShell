function Get-DotNetFrameworkVersion {
    [CmdletBinding()]
    param (
        [parameter()]
        [string] $RegistryKey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'
    )

    # Get the version of the .NET Framework installed on the system
    $DotNetVersions = Get-ChildItem $RegistryKey -Recurse |
        Get-ItemProperty -Name Version -ea 0 |
        Where-Object {$_.PSChildName -match '^(?!S)\p{L}'} |
        Select-Object -Property PSChildName, Version

    # Return the version information
    if ($DotNetVersions) {
        return $DotNetVersions
    }
    else {
        return "No .NET Framework versions were found"
    }
}
