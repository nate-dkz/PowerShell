Function Test-MemoryUsage {
    [cmdletbinding()]
    Param()
    
    $OS = Get-Ciminstance Win32_OperatingSystem
    $PercentFree = [math]::Round(($OS.FreePhysicalMemory/$OS.TotalVisibleMemorySize)*100,2)

        if ($PercentFree -ge 45) {
            $Status = "OK"
        }
        elseif ($PercentFree -ge 15 ) {
            $Status = "Warning"
        }
        else {
            $Status = "Critical"
        }
        
        $OS | Select-Object @{Name = "Status";Expression = {$Status}},
        @{Name = "PercentageFree"; Expression = {$PercentFree}},
        @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}},
        @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}}
}