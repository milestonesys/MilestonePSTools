#Requires -Module MilestonePSTools, ImportExcel

. .\Add-ExcelImage.ps1
. .\Export-ExcelCustom.ps1
. .\Get-VmsAlarmReport.ps1

Connect-Vms -ShowDialog -AcceptEula

$reportParameters = @{
    State = 'Closed'
    Priority = 'High'
    StartTime = (Get-Date).AddDays(-1)
    EndTime = Get-Date

    # Convert the UTC timestamps to local time
    UseLocalTime = $true

    # Get all alarms where last modified time was between StartTime and "Now"
    # instead of where the alarm was CREATED between StartTime and "Now"
    UseLastModified = $true

    IncludeSnapshots = $true
}

$report = Get-VmsAlarmReport @reportParameters
if ($report.Count -gt 0) {
    $path = '.\Alarm-Report_{0}.xlsx' -f (Get-Date -Format yyyy-MM-dd_HH-mm-ss)
    Export-ExcelCustom -InputObject $report -Path $path -Title 'Get-VmsAlarmReport' -Show
} else {
    Write-Warning ("No alarms found between {0} and {1}" -f $reportParameters.StartTime, $reportParameters.EndTime)
}
