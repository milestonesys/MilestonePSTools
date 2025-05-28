---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsHardwareDriver/
schema: 2.0.0
---

# Set-VmsHardwareDriver

## SYNOPSIS
Sets the hardware driver to use for an existing hardware device.

## SYNTAX

```
Set-VmsHardwareDriver [-Hardware] <Hardware[]> [[-Address] <Uri>] [[-Credential] <PSCredential>]
 [[-Driver] <HardwareDriver>] [[-CustomDriverData] <String>] [-AllowDeletingDisabledDevices] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsHardwareDriver` cmdlet is used to invoke the "ReplaceHardware"
configuration api method ID on a `Hardware` object. This method ID was
introduced in XProtect VMS version 2023 R1, and this cmdlet is compatible only
with version 2023 R1 and later.

This cmdlet may be used to perform a "hardware replacement" which has
traditionally only been possible to do through the "Replace Hardware Wizard" in
the management client. In some cases you might perform this action to "refresh"
an existing camera without changing the driver - for example, many cameras have
a dynamic set of events available depending on settings or plugins on the camera
itself. A hardware replacement procedure would force the recording server to
re-discover the available features on the camera.

You may also use this cmdlet to change the driver used for a camera. For
example, you may wish to switch from an ONVIF driver to a dedicated driver. To
do so, you can supply a hardware driver object, driver number, or a driver name
for the `Driver` parameter.

If a hardware replacement fails, the TargetObject property of the `ErrorRecord`
will contain an object of type `ReplaceHardwareTaskInfo`. This error record
can be used to help determine which hardware replacements failed when performing
many operations in bulk. See the examples for reference.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.1

## EXAMPLES

### Example 1
```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Single -Title "Select a hardware device"
$hardware | Set-VmsHardwareDriver -PassThru -Confirm:$false -Verbose
```

Prompts for a hardware device selection, and then performs a hardware
replacement without modifying the driver. If the resulting hardware change would
result in a different number of camera channels connected to the hardware, the
replace will fail since "AllowDeletingDisabledDevices" was not specified.

Since `-Confirm:$false` is present, no confirmation will be required before
continuing.

### Example 2
```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Single -Title "Select a hardware device"
$hardware | Set-VmsHardwareDriver -PassThru -Driver AXIS
```

Prompts for a hardware device selection, and then performs a hardware
replacement with the "AXIS" driver, driver number 806. You could also specify
the integer 806 instead of "AXIS", as a custom argument transformation will
take care of converting either the name or driver number to the corresponding
hardware driver object as is returned by `Get-VmsHardwareDriver`.

### Example 3
```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Single -Title "Select a hardware device"
$hardware | Set-VmsHardwareDriver -Driver 421 -Credential (Get-Credential) -AllowDeletingDisabledDevices -WhatIf
```

Prompts for a hardware device selection, and then informs what would happen
if you attempted to set the hardware driver to driver number 421, "Universal 1
channel driver". Remove the `-WhatIf` switch to execute the hardware driver
change.

### Example 4
```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Single -Title "Select a hardware device"
$hardware | Set-VmsHardwareDriver -Driver 605 -ErrorVariable replaceHardwareErrors
foreach ($e in $replaceHardwareErrors.TargetObject) {
    $e
}
```

Prompts for a hardware device selection, and then attempts to replace the driver
with the "Axis One-click" driver. Assuming this fails, the `$replaceHardwareErrors`
`ArrayList` will be populated with an `ErrorRecord`, and the `TargetObject`
property of that record will be an object with the HardwareName, HardwarePath,
RecorderPath, and Task properties. This information can be used to produce
a report of hardware replacements that have failed and might need to be retried
or performed manually.

## PARAMETERS

### -Address
Specifies the new hardware address in URI format. For example: http://192.168.1.101

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowDeletingDisabledDevices
Specifies that if the resulting hardware configuration has fewer camera,
microphone, speaker, input, output, or metadata channels than the number of
enabled channels prior to hardware replacement, the disabled device channels
may be deleted in order to complete the hardware replacement. If there are more
enabled device channels than available in the resulting hardware configuration,
the hardware replacement will not proceed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Specifies new credentials to use for the specified hardware device. If the
credentials have not changed, the current username and password will be used
automatically.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomDriverData
Reserved for future use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Driver
Specifies the new HardwareDriver object to use with the hardware device, or
the driver number, or the full driver name. When supplying a driver name or
number, it will be automatically translated to a HardwareDriver object for ease
of use.

```yaml
Type: HardwareDriver
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hardware
Specifies one or more hardware objects returned by `Get-VmsHardware` on which
to perform the hardware replacement.

```yaml
Type: Hardware[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru
Pass the updated hardware object back to the pipeline on a successful hardware
replacement.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware[]

This cmdlet accepts one or more Hardware objects from the pipeline, or by
named parameter.

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

When invoked with the `-PassThru` switch parameter, this cmdlet returns the
updated hardware object(s).

## NOTES

## RELATED LINKS
