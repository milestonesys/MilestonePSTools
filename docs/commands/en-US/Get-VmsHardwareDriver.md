---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsHardwareDriver/
schema: 2.0.0
---

# Get-VmsHardwareDriver

## SYNOPSIS
Gets the HardwareDriver associated with an existing Hardware object, or all
HardwareDrivers available on a recording server.

## SYNTAX

### Hardware (Default)
```
Get-VmsHardwareDriver -Hardware <Hardware[]> [<CommonParameters>]
```

### RecordingServer
```
Get-VmsHardwareDriver -RecordingServer <RecordingServer[]> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsHardwareDriver` cmdlet returns the HardwareDriver object associated
with an existing Hardware device, or if provided with a recording server, it
returns all HardwareDrivers available on the recording server.

The HardwareDriver object provides information about a hardware driver
including: GroupName (Axis, Bosch, Milestone, Sony), Number, DriverVersion,
DriverRevision, DriverType, Name, and others.

The DriverVersion and DriverRevision properties can be used to compare drivers
between two recording servers to determine if the same device pack driver
version is being used.

A HardwareDriver object can be used with the `Set-VmsHardwareDriver` cmdlet
instead of relying on the Driver argument transformation to look up a driver
number or name when changing the driver to use for a given hardware device.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRecordingServer | Select-Object -First 1 | Get-VmsHardwareDriver
```

Returns all HardwareDrivers associated with the first recording server returned
by `Get-VmsRecordingServer`.

### Example 1
```powershell
Get-VmsHardware | Select-Object -First 1 | Get-VmsHardwareDriver
```

Returns the HardwareDriver associated with the first hardware device returned
by `Get-VmsHardware`.

## PARAMETERS

### -Hardware
Specifies a Hardware object which can be retrieved using `Get-VmsHardware`.

```yaml
Type: Hardware[]
Parameter Sets: Hardware
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RecordingServer
Specifies a RecordingServer object which can be retrieved using
`Get-VmsRecordingServer`. The recording server name can also be provided, and
the matching RecordingServer(s) will be retrieved automatically.

```yaml
Type: RecordingServer[]
Parameter Sets: RecordingServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.RecordingServer[]

This cmdlet accepts one or more RecordingServer objects from the pipeline.

### VideoOS.Platform.ConfigurationItems.Hardware[]

This cmdlet accepts one or more Hardware objects from the pipeline.

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.HardwareDriver

## NOTES

## RELATED LINKS
