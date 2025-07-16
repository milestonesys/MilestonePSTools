$newDriver = $null
$recorders = Get-VmsRecordingServer | Out-GridView -Title "Select Recording Server(s)" -OutputMode Multiple
$recorders | ForEach-Object {
    $rec = $_
    # Clear cached info about the hardware and drivers on the current recorder
    $rec.HardwareDriverFolder.ClearChildrenCache()
    $rec.HardwareFolder.ClearChildrenCache()
    
    # Cache all the available drivers on the current recording server
    $drivers = @{}
    $rec | Get-VmsHardwareDriver | ForEach-Object {
        $drivers[$_.Path] = $null
    }
    
    # Ask the user to select one or more hardware with an unrecognized driver
    # For example, you might choose all hardware with "Axis" in the model name
    $hardware = Get-VmsHardware | Where-Object {
        !$drivers.ContainsKey($_.HardwareDriverPath)
    } | Out-GridView -OutputMode Multiple
    
    if ($null -eq $hardware -or $hardware.Count -eq 0) {
        Write-Host "No hardware found, or selected, with an unrecognized hardware driver on recording server '$($rec.Name)'!" -ForegroundColor Green
        return
    }
    
    # Ask the user to select the new driver to use for the selected hardware
    if ($null -eq $newDriver) {
        $newDriver = $rec | Get-VmsHardwareDriver | Out-GridView -Title "Select new driver" -OutputMode Single
        if ($null -eq $newDriver) {
            Write-Warning "No driver selected. No changes will be made to hardware on recording server '$($rec.Name)'."
            return
        }
    }

    # Change the driver for selected hardware to the new driver
    $hardware | Set-VmsHardwareDriver -Driver $newDriver

    # Note: If the number of devices will decrease after changing the driver,
    # you must include the "-AllowDeletingDisabledDevices" parameter, and you
    # must ensure that the device channels to be removed are disabled first.
    # For example, if the current driver has 4 camera channels and the new
    # driver has 2, you would need to disable at least two camera channels
    # and then run the command like this:
    # $hardware | Set-VmsHardwareDriver -Driver $newDriver -AllowDeletingDisabledDevices
}