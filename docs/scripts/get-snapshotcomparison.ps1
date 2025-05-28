function Get-SnapshotComparison {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(50, [int]::MaxValue)]
        [int]
        $Height = 200,

        [Parameter()]
        [switch]
        $LiftPrivacyMask
    )

    process {
        $cameras = (Get-IServerCommandService).GetConfiguration((Get-VmsToken)).Recorders.Cameras
        foreach ($camera in $cameras) {
            Remove-Variable newSnapshot, oldSnapshot, newImage, oldImage -ErrorAction Ignore
            $newSnapshot = Get-Snapshot -CameraId $camera.DeviceId -Live -LiftPrivacyMask:$LiftPrivacyMask
            $oldSnapshot = Get-Snapshot -CameraId $camera.DeviceId -Behavior GetBegin -LiftPrivacyMask:$LiftPrivacyMask
            $difference = 'Not available'
            if ($null -ne $newSnapshot -and $null -ne $oldSnapshot) {
                $difference = '{0} days' -f ([int]($newSnapshot.BeginTime - $oldSnapshot.DateTime).TotalDays)
            }
            [pscustomobject]@{
                Name       = $camera.Name
                Retention  = $difference
                Oldest     = if ($null -ne $oldSnapshot) { ConvertFrom-Snapshot -Content $oldSnapshot.Bytes| Resize-Image -Height $Height -Quality 100 } else { 'Not available' }
                Newest     = if ($null -ne $newSnapshot) { ConvertFrom-Snapshot -Content $newSnapshot.Content | Resize-Image -Height $Height -Quality 100 } else { 'Not available' }
            }
        }
    }
}
