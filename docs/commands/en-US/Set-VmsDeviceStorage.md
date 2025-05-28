---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsDeviceStorage/
schema: 2.0.0
---

# Set-VmsDeviceStorage

## SYNOPSIS
Set the target storage configuration for a device in XProtect.

## SYNTAX

```
Set-VmsDeviceStorage [-Device] <IConfigurationItem[]> [-Destination] <String> [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsDeviceStorage` cmdlet sets the target storage configuration for a device in XProtect.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```
Get-VmsHardware | Get-VmsCamera | Set-VmsDeviceStorage -Destination 'Longterm Storage' -PassThru
```

Get all enabled cameras on all recording servers and update them to record to the storage configuration with the
name 'Longterm Storage'.
If the storage does not exist, an error will be thrown.
If the storage exists and the
device is already assigned to it, no error will be thrown.
Each camera will be returned to the pipeline after the
operation completes thanks to the "-PassThru" switch.

### EXAMPLE 2

```
$storageName = 'Longterm storage'
Get-VmsHardware | ForEach-Object {
    $_ | Get-VmsCamera     -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsMicrophone -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsSpeaker    -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsMetadata   -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
}
```

Gets all cameras, microphones, speakers, and metadata devices from all hardware on all recording servers and assigns
them all to a storage configuration named "Longterm storage" if it exists.

### EXAMPLE 3

```
$storageName = 'Longterm storage'
$recorders = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorders | Get-VmsHardware | ForEach-Object {
    $_ | Get-VmsCamera     -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsMicrophone -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsSpeaker    -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
    $_ | Get-VmsMetadata   -EnableFilter All | Set-VmsDeviceStorage -Destination $storageName
}
```

Prompts for a selection of one or more recording servers, then proceeds assign all cameras, microphones, speakers,
and metadata to a storage configuration named "Longterm storage" if it exists.

## PARAMETERS

### -Destination
The display name, or the Configuration API Path for the target storage configuration. If the device is already recording
to the destination, the operation should complete without errors.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device
One or more devices returned by the `Get-VmsCamera`, `Get-VmsMicrophone`, `Get-VmsSpeaker`, or `Get-VmsMetadata` cmdlets.

```yaml
Type: IConfigurationItem[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru
Pass the Device(s) back to the pipeline after a move operation is completed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

## OUTPUTS

## NOTES

Previous versions of XProtect supported a `moveData` boolean (true/false) option, but this was deprecated in MIP SDK and
no longer has any effect. Previous recordings will not be moved to the new storage configuration. They will remain in
the old storage configuration and will be deleted over time as recordings reach the maximum retention time of that
original storage configuration.

## RELATED LINKS
