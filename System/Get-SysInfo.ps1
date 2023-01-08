function Get-SysInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,
                  ParameterSetName = 'ComputerNames',
                  HelpMessage = 'List of computer names separated by commas.')]
        [alias('Host')]
        [string[]]$ComputerName = 'localhost'
    )
    
    foreach ($Comp in $ComputerName) {
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Comp
        $Sys = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Comp
        $Proc = Get-CimInstance -ClassName Win32_Processor -ComputerName $Comp
        $Page = Get-CimInstance -ClassName Win32_PageFileUsage -ComputerName $Comp

        $Properties = [Ordered]@{
                        'Date' = Get-Date;
                        'Computer' = $Comp;
                        'Domain' = $Sys.Domain;
                        'IsVirtual' = ($Sys.Model).contains('Virtual');
                        'Vendor' = $OS.Manufacturer;
                        'OS' = $OS.Caption;
                        'Version' = $OS.Version;
                        'OSArchitecture' = $OS.OSArchitecture;
                        'SerialNumber' = $OS.SerialNumber;
                        'BuildNumber' = $OS.BuildNumber;
                        'SystemDrive' = $OS.SystemDrive;
                        'SystemDevice' = $OS.SystemDevice;
                        'BootDevice' = $OS.BootDevice;
                        'WindowsDirectory' = $OS.WindowsDirectory
                        'InstallDate' = $OS.InstallDate;
                        'HostName' = $OS.CSName;
                        'RegisteredUser' = $OS.RegisteredUser;
                        'NumberOfUsers' = $OS.NumberOfUsers;
                        'LastBootUpTime' = $OS.LastBootUpTime;
                        'CPU' = $Proc.Name;
                        'NumberOfCores' = $Proc.NumberOfCores;
                        'NumberOfEnabledCores' = $Proc.NumberOfEnabledCore;
                        'NumberOfLogicalProcessors' = $Proc.NumberOfLogicalProcessors;
                        'ThreadCount' = $Proc.ThreadCount;
                        'TotalMemory(GB)' = "{0:N2}" -f ($OS.TotalVisibleMemorySize / 1MB);
                        'FreeMemory(GB)' = "{0:N2}" -f ($OS.FreePhysicalMemory / 1MB) ;
                        'TotalVirtualMemory(GB)' = "{0:N2}" -f ($OS.TotalVirtualMemorySize / 1MB);
                        'FreeVirtualMemory(GB)' = "{0:N2}" -f ($OS.FreeVirtualMemory / 1MB);
                        'PageFileLocation' = $Page.Name;
                        'PageFileSize(GB)' = "{0:N2}" -f $Page.AllocatedBaseSize / 1KB
        } 
        $Obj = New-Object -TypeName psobject -Property $Properties 
        Write-Output $Obj
    }
}