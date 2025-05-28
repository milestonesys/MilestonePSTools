---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDevice/
schema: 2.0.0
---

# Get-VmsDevice

## SYNOPSIS
Gets the matching device records from the Milestone XProtect Management Server.

## SYNTAX

### QueryItems (Default)
```
Get-VmsDevice [-Type <String[]>] [[-Name] <String>] [[-Description] <String>] [[-Channel] <Int32[]>]
 [[-EnableFilter] <EnableFilter>] [[-Comparison] <Operator>] [[-MaxResults] <Int32>] [<CommonParameters>]
```

### Hardware
```
Get-VmsDevice [-Type <String[]>] [-Hardware] <Hardware[]> [[-Name] <String>] [[-Description] <String>]
 [[-Channel] <Int32[]>] [[-EnableFilter] <EnableFilter>] [[-Comparison] <Operator>] [<CommonParameters>]
```

### Id
```
Get-VmsDevice [-Id] <Guid[]> [<CommonParameters>]
```

### Path
```
Get-VmsDevice [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsDevice` cmdlet gets devices from the currently connected XProtect VMS site. The included Devices are logical child
devices attached to "hardware" which are most often an IP camera.

The corresponding `Set-VmsDevice` command can be used in conjunction with this cmdlet to modify the device settings
common to all device types.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsDevice
```

Get all enabled devices.

### Example 1
```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorder | Get-VmsHardware | Get-VmsDevice
```

Get all enabled devices from the selected recording server(s).

### Example 3
```powershell
Get-VmsDevice -Name 'garage'
```

Get all enabled devices with the case-insensitive word "garage" in the name.

### Example 4
```powershell
Get-VmsDevice -EnableFilter Disabled
```

Get all **disabled** devices.

### Example 5
```powershell
Get-VmsDevice -EnableFilter All -Channel 0 | Set-VmsDevice -Enabled $true -PassThru
Get-VmsDevice -EnableFilter All -Channel (1..64) | Set-VmsDevice -Enabled $false -PassThru
```

Get all devices with a channel value of "0" (port number 1), and enable them if they aren't enabled already. Then get all
devices with a higher channel number from 1 to 64, and disable them. In most cases this should leave you with only the
first device of any given type enabled.

## PARAMETERS

### -Channel
When providing one or more channel numbers, only devices with a matching channel number are returned. Channel numbering
starts at zero, which means the first device of any given type will be assigned channel number "0", the second device
will be assigned channel number "1", and so on.

```yaml
Type: Int32[]
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comparison
When providing a value for the `Name`, or `Description` parameters, the `Comparison` operator determines how thes values
are compared with the corresponding device properties. The default value is **Contains**.

```yaml
Type: Operator
Parameter Sets: QueryItems, Hardware
Aliases:
Accepted values: Equals, NotEquals, LessThan, GreaterThan, Contains, BeginsWith

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies all, or part of a device description which is used with the `Comparison` parameter to filter the results of
the request.

```yaml
Type: String
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableFilter
Specifies whether to return enabled, disabled, or all matching devices. By default, only enabled devices are returned.

```yaml
Type: EnableFilter
Parameter Sets: QueryItems, Hardware
Aliases:
Accepted values: All, Enabled, Disabled

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hardware
Specifies the hardware object(s) from which to return matching devices.

```yaml
Type: Hardware[]
Parameter Sets: Hardware
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Id
Specifies the Id of an existing device.

```yaml
Type: Guid[]
Parameter Sets: Id
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MaxResults
Specifies the maximum number of matching devices to return. On a very large XProtect VMS, setting a reasonable number
may result in better performance. The default value is `[int]::MaxValue` or 2147483647.

```yaml
Type: Int32
Parameter Sets: QueryItems
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies all, or part of a device name which is used with the `Comparison` parameter to filter the results of the
request.

```yaml
Type: String
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The Milestone Configuration API string representing the device in the format `DeviceType[DeviceId]`.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of device(s) to return from the parent `Hardware` device.

```yaml
Type: String[]
Parameter Sets: QueryItems, Hardware
Aliases:
Accepted values: Camera, Microphone, Speaker, Metadata, Input, Output

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

### System.Guid[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## NOTES

## RELATED LINKS
