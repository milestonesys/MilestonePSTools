#Requires -Module MilestonePSTools, ImportExcel

. .\Add-ExcelImage.ps1
. .\Export-ExcelCustom.ps1

Connect-Vms -ShowDialog -AcceptEula
$report = Get-VmsCameraReport -IncludeSnapshots -SnapshotHeight 200 -Verbose
$path = '.\Camera-Report_{0}.xlsx' -f (Get-Date -Format yyyy-MM-dd_HH-mm-ss)
Export-ExcelCustom -InputObject $report -Path $path -Title "Get-VmsCameraReport" -Show
