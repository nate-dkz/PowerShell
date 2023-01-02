# Returns the difference between dates
[datetime]$FromDate = '12/25/2022'
[datetime]$ToDate = '12/28/2022'
($ToDate - $FromDate).TotalDays

# Returns the difference between times
[datetime]$FromDate = '06/12/2022 08:00'
[datetime]$ToDate = '06/20/2022 14:00'
($ToDate - $FromDate).TotalHours

New-TimeSpan -Start $FromDate -End $ToDate
