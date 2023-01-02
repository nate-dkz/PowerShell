function Get-Sysinfo {

    Get-WmiObject -Class Win32_OperatingSystem |
        Select-Object -Property Status,
                                Manufacturer,
                                @{n='OSBuild' ; e={$_.Caption}},
                                OSArchitecture,
                                Version,
                                SerialNumber,
                                @{n='HostName' ; e={$_.CSName}},
                                BootDevice,
                                SystemDevice,
                                WindowsDirectory,
                                SystemDirectory,
                                RegisteredUser,
                                NumberOfUsers,
                                @{n='LocalDateTime' ; e={$_.ConverttoDateTime($_.lastbootuptime)}},
                                @{n='InstallDate' ; e={$_.ConverttoDateTime($_.InstallDate)}},
                                @{n='LastBootUpTime' ; e={$_.ConverttoDateTime($_.LastBootUpTime)}},
                                NumberOfProcesses,
                                @{n='TotalVisibleMemorySize(GB)' ; e={$_.TotalVisibleMemorySize / 1MB -as [int]}},
                                @{n='FreePhysicalMemory(GB)' ; e={$_.FreePhysicalMemory / 1MB -as [int]}}
}

function Get-DiskInfo {

    Get-WmiObject -Class Win32_LogicalDisk |
        Where-Object {$_.DriveType -eq 3} |
        Select-Object -Property DeviceID,
                                DriveType,
                                @{n='Size(GB)' ; e={$_.size / 1GB -as [int]}},
                                @{n='Free(GB)' ; e={$_.FreeSpace / 1GB -as [int]}}
}

function Get-ProcessorInfo {
 
    Get-WmiObject -Class Win32_Processor |
        Select-Object -Property Manufacturer,
                                Description,
                                Name,
                                NumberOfCores,
                                NumberOfEnabledCore,
                                NumberOfLogicalProcessors
}
