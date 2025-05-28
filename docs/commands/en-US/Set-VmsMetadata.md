---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsMetadata/
schema: 2.0.0
---

# Set-VmsMetadata

## SYNOPSIS
Sets one or more configuration properties for the specified device(s).

## SYNTAX

```
Set-VmsMetadata [[-RecordingEnabled] <Boolean>] [[-ManualRecordingTimeoutEnabled] <Boolean>]
 [[-ManualRecordingTimeoutMinutes] <Int32>] [[-PrebufferEnabled] <Boolean>] [[-PrebufferSeconds] <Int32>]
 [[-PrebufferInMemory] <Boolean>] [[-EdgeStorageEnabled] <Boolean>] [[-EdgeStoragePlaybackEnabled] <Boolean>]
 [-InputObject] <IConfigurationItem[]> [[-Name] <String>] [[-ShortName] <String>] [[-Description] <String>]
 [[-Enabled] <Boolean>] [[-GisPoint] <String>] [[-Coordinates] <String>] [[-CoverageDirection] <Double>]
 [[-Direction] <Double>] [[-CoverageFieldOfView] <Double>] [[-FieldOfView] <Double>]
 [[-CoverageDepth] <Double>] [[-Depth] <Double>] [[-Units] <MeasurementSystem>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Uses Milestone's Configuration API to modify properties of devices and saves the
changes to the Management Server. Most parameters represent the Milestone MIP SDK
property names of the underlying devices. However, there are a few custom parameter
names including "Coordinates", "Direction", "FieldOfView" and "Depth" which accept
values that are easier to understand than the values expected by the MIP SDK.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsHardware | Get-VmsMetadata -Channel (1..63) -Verbose | Set-VmsMetadata -Enabled $false
```

In this example, we first ensure we are logged in to the Management Server. Then
we gets all enabled metadatas with a channel number between 1 and 63 (metadata 2 to
metadata 64), and disable them. You might do this if you only use the first channel
on every metadata, and all other channels should be disabled. In this case, channels
higher than 63 would be unchanged. If you had devices with more unused channels
than this, you could use "(1..511)" to select all metadatas from the 2nd to the
512th channel.

### Example 2
```powershell
$splat = @{
    InputObject       = Get-VmsMetadata
    PrebufferEnabled  = $true
    PrebufferSeconds  = 10
    PrebufferInMemory = $true
}
Set-VmsMetadata @splat
```

Configure an in-memory prebuffer on all enabled metadatas with a duration of 10 seconds.

### Example 3
```powershell
$splat = @{
    InputObject = Get-VmsMetadata -Name 'Office Entrance'
    Coordinates = '45.4171601197572, -122.732137977298'
    Direction   = 90
    FieldOfView = 180
    Depth       = 15
    Verbose     = $true
}

Set-VmsMetadata @splat
```

A hashtable named $splat is defined with all the parameters needed to
change the GPS location, direction, field of view, and depth of field for the
matching device(s) named "Office Entrance". The hashtable is then "splatted" into the
cmdlet and because we included the Verbose switch, all changes made to the devices
are logged to the console.

Note that if the settings already matched these values, there would be nothing
logged to the console because no changes had to be made.

## PARAMETERS

### -Coordinates
Specifies GPS coordinates in a "latitude, longitude" format where latitude and
longitude are positive or negative numberic values with no alphabetic characters.
For example, "45.4171601197572, -122.732137977298".

To remove the coordinates from a device, you may set the value to $null or ''.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CoverageDepth
Specifies the depth of the device's field of view in meters.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CoverageDirection
Specifies the orientation of the device as a 360-degree compass bearing
expressed as a value between 0 and 1. For example, a value of 0 represents North
while a value of 0.5 represents South, and 0.75 represents West. You can produce
the right value by dividing the compass heading value, such as 90 degrees
(East), by 360, for a value of 0.25.

Alternatively, you may choose to use the
Direction parameter which allows for specifying a value in degrees between 0
and 360. If the Direction parameter is provided, it takes priority over
CoverageDirection.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CoverageFieldOfView
Specifies the angle of the field of view of the device in degrees, expressed as
a value between 0 and 1. For example, a value of 0.25 represents 90 degrees and
a value of 0.5 represents 180 degrees. You can produce the right value by
dividing the field of view in degrees, by 360.

Alternatively, you may choose to use the FieldOfView parameter which allows for
specifying a value in degrees between 0 and 360. If the FieldOfView parameter is
provided, it takes precedence over CoverageFieldOfView.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth
Specifies the depth of the field of view, either in meters, or in feet,
depending on the region settings of the environment in which PowerShell is
running. If PowerShell is running on a PC in the United States, the value will
usually be treated as a measurement in feet. In most other cases the value will
be interpreted as meters. To override the regional default or explicitly
include the units in your script, you may use the Units parameter.

This parameter overrides the CoverageDepth parameter if that parameter is
also provided.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies the desired device description. This is visible in the Management
Client and may be searchable in some clients or utilities.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Direction
Specifies the compass orientation of the device in degrees between 0 and 360.
This parameter overrides the CoverageDirection parameter if that parameter is
also provided.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EdgeStorageEnabled
Specifies whether or not edge storage should be enabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EdgeStoragePlaybackEnabled
Specifies that playback may or may not be done directly from edge storage.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Specifies whether or not the device should be enabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FieldOfView
Specifies the field of view of the device in degrees between 0 and 360. This
parameter overrides the CoverageFieldOfView parameter if that parameter is also
provided.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GisPoint
Specifies the GPS coordinates of the device in a custom format. The value is
accepted as a string in the format "POINT EMPTY" to "un-set" the coordinates,
or "POINT (X Y [Z])" where the elevation field "Z" is optional and not usually
provided, X represents the longitude, and Y represents the latitude. It's
important to note that this format reverses the standard "latitude, longitude"
order because it is expressed internally in Milestone as a "point" with X/Y
coordinates.

You may use the Coordinates parameter for a more user-friendly format for
setting coordinates.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Specifies one or more `Metadata` objects as returned by `Get-VmsMetadata`.

```yaml
Type: IConfigurationItem[]
Parameter Sets: (All)
Aliases: Camera, Microphone, Speaker, Metadata, InputEvent, Output

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ManualRecordingTimeoutEnabled
Specifies that the timeout used to stop a manual recording session should be
enabled or disabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManualRecordingTimeoutMinutes
Specifies the maximum time the device can be recording due to a manual recording
trigger.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new name for the device.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the modified device object should be returned to the pipeline or
caller.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrebufferEnabled
Specifies that the pre-buffer feature should be enabled or disabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrebufferInMemory
Specifies that the pre-buffer feature should pre-buffer to memory, or to disk.
When PrebufferInMemory is set to $false, then the pre-buffer will reside on disk.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrebufferSeconds
Specifies the size of the pre-buffer in seconds. The maximum size for the
pre-buffer is 15 seconds when pre-buffering to memory. When pre-buffering to
disk, the maximum value is 10000.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingEnabled
Specifies whether or not recording is enabled for this device. When enabled,
recording can be triggered manually from a client application or automatically
based on the configured set of rules. When disabled, the device cannot be
recorded, and any existing recordings cannot be played back.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShortName
Specifies the new short-name for the device.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Units
Specifies whether the unit of measurement provided in the Depth parameter is in
feet or meters. By default, the value will be interpreted based on your
PowerShell environment's region settings. Set Units to Metric to explicitly
specify that the Depth value represents meters. Set it to Imperial to specify
that the Depth value represents feet.

This parameter does not affect the behavior of the CoverageDepth parameter. That
value is always interpreted as meters.

```yaml
Type: MeasurementSystem
Parameter Sets: (All)
Aliases:
Accepted values: Metric, Imperial

Required: False
Position: 13
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
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### VideoOS.Platform.ConfigurationItems.Metadata[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Metadata

## NOTES

## RELATED LINKS
