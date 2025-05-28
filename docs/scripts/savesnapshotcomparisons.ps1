#Requires -Module MilestonePSTools, ImportExcel

. .\Add-ExcelImage.ps1
. .\Export-ExcelCustom.ps1
. .\Get-SnapshotComparison.ps1

Connect-Vms -ShowDialog -AcceptEula
$report = Get-SnapshotComparison
$path = '.\Camera-Comparison_{0}.xlsx' -f (Get-Date -Format yyyy-MM-dd_HH-mm-ss)
Export-ExcelCustom -InputObject $report -Path $path -Title "Get-SnapshotComparison" -Show
