$drivers = @{}
$recorders = Get-VmsRecordingServer | Out-GridView -Title "Select Recording Server(s)" -OutputMode Multiple
if ($null -eq $recorders) {
    Write-Warning "No recording server selected. No changes will be made."
    return
}

$hardware = $recorders | ForEach-Object {
    $rec = $_
    # Clear cached info about the hardware and drivers on the current recorder
    $rec.HardwareDriverFolder.ClearChildrenCache()
    $rec.HardwareFolder.ClearChildrenCache()
    
    # Cache all the available drivers on the current recording server
    
    $rec | Get-VmsHardwareDriver | ForEach-Object {
        $drivers[$_.Path] = $_
    }
    
    # Ask the user to select one or more hardware with an unrecognized driver
    # For example, you might choose all hardware with "Axis" in the model name
    Get-VmsHardware | Where-Object {
        !$drivers.ContainsKey($_.HardwareDriverPath)
    }
} | Out-GridView -OutputMode Multiple

if ($null -eq $hardware) {
    Write-Warning "No hardware found, or selected, with an unrecognized hardware driver. No changes will be made."
    return
}

$newDriver = $recorders[0] | Get-VmsHardwareDriver | Out-GridView -Title "Select new driver" -OutputMode Single
if ($null -eq $newDriver) {
    Write-Warning "No new driver selected. No changes will be made."
    return
}

$hardware | Set-VmsHardwareDriver -Driver $newDriver

# Note: If the number of devices will decrease after changing the driver,
# you must include the "-AllowDeletingDisabledDevices" parameter, and you
# must ensure that the device channels to be removed are disabled first.
# For example, if the current driver has 4 camera channels and the new
# driver has 2, you would need to disable at least two camera channels
# and then run the command like this:
# $hardware | Set-VmsHardwareDriver -Driver $newDriver -AllowDeletingDisabledDevices
