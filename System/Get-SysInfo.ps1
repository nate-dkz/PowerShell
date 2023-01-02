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
        $sys = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Comp
        $Proc = Get-CimInstance -ClassName Win32_Processor -ComputerName $Comp
        $Page = Get-CimInstance -ClassName Win32_PageFileUsage -ComputerName $Comp

        $Properties = [Ordered]@{
                        'Date' = Get-Date;
                        'Computer' = $Comp;
                        'Domain' = $sys.Domain;
                        'IsVirtual' = ($sys.model).contains('Virtual');
                        'Vendor' = $os.Manufacturer;
                        'OS' = $os.Caption;
                        'Version' = $os.Version;
                        'OSArchitecture' = $os.OSArchitecture;
                        'SerialNumber' = $os.SerialNumber;
                        'BuildNumber' = $os.BuildNumber;
                        'SystemDrive' = $os.SystemDrive;
                        'SystemDevice' = $os.SystemDevice;
                        'BootDevice' = $os.BootDevice;
                        'WindowsDirectory' = $os.WindowsDirectory
                        'InstallDate' = $os.InstallDate;
                        'HostName' = $os.CSName;
                        'RegisteredUser' = $os.RegisteredUser;
                        'NumberOfUsers' = $os.NumberOfUsers;
                        'LastBootUpTime' = $os.LastBootUpTime;
                        'CPU' = $proc.Name;
                        'NumberOfCores' = $proc.NumberOfCores;
                        'NumberOfEnabledCores' = $Proc.NumberOfEnabledCore;
                        'NumberOfLogicalProcessors' = $Proc.NumberOfLogicalProcessors;
                        'ThreadCount' = $proc.ThreadCount;
                        'TotalMemory(GB)' = "{0:N2}" -f ($os.TotalVisibleMemorySize / 1MB);
                        'FreeMemory(GB)' = "{0:N2}" -f ($os.FreePhysicalMemory / 1MB) ;
                        'TotalVirtualMemory(GB)' = "{0:N2}" -f ($os.TotalVirtualMemorySize / 1MB);
                        'FreeVirtualMemory(GB)' = "{0:N2}" -f ($os.FreeVirtualMemory / 1MB);
                        'PageFileLocation' = $page.Name;
                        'PageFileSize(GB)' = "{0:N2}" -f $page.AllocatedBaseSize / 1KB
        } 
        $Obj = New-Object -TypeName psobject -Property $Properties 
        Write-Output $Obj
    }
}