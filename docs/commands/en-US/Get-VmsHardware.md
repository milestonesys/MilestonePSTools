---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsHardware/
schema: 2.0.0
---

# Get-VmsHardware

## SYNOPSIS
Gets existing Hardware devices added to recording servers on the currently
connected management server.

## SYNTAX

### All (Default)
```
Get-VmsHardware [-All] [-EnableFilter <EnableFilter>] [-CaseSensitive] [<CommonParameters>]
```

### Filtered
```
Get-VmsHardware [-RecordingServer <RecordingServer>] [-RecorderId <Guid>] [[-Name] <String>]
 [-EnableFilter <EnableFilter>] [-CaseSensitive] [<CommonParameters>]
```

### ById
```
Get-VmsHardware [-Id <Guid>] [-CaseSensitive] [<CommonParameters>]
```

## DESCRIPTION
The `GetVmsHardware` cmdlet returns all hardware on all recording servers on
the currently connected management server, or all hardware on a specific
recording server.

By default, this cmdlet only returns enabled hardware. To return hardware that
is disabled, or to return all hardware, use the EnableFilter parameter to set
your preference.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Get enabled hardware
```powershell
Get-VmsHardware
```

Returns all enabled hardware on all recording servers.

### Get all hardware on a recording server
```powershell
$recorder = Get-VmsRecordingServer | Select-Object -First 1
$recorder | Get-VmsHardware
```

Returns all enabled hardware on one recording server.

### Get all hardware, including disabled
```powershell
Get-VmsHardware -EnableFilter All
```

Returns all hardware on all recording servers, including disabled devices.

### Get all hardware with Address and MAC

```powershell
$macProperty = @{
    Name       = 'MACAddress'
    Expression = { ($_ | Get-HardwareSetting).MACAddress }
}
Get-VmsHardware | Select-Object Name, Address, $macProperty
```

This example uses `Select-Object` with a [calculated property](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_calculated_properties?view=powershell-5.1)
to return a list of hardware names and addresses, along with the MAC. Calculated properties are a powerful feature of
the PowerShell language and allow you to combine and format information in whatever way you need.

## PARAMETERS

### -All
Obsolete. Specifies that all hardware from all recorders should be returned.
This is the default behavior when no parameters are specified.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaseSensitive
Specifies that the Name parameter should be used to perform a case-sensitive
filter. The default behavior is to filter based on case-insensitive matching.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 50
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableFilter
Specifies whether to include enabled devices, disabled devices, or both. The default behavior is to only include enabled
devices.

```yaml
Type: EnableFilter
Parameter Sets: All, Filtered
Aliases:
Accepted values: All, Enabled, Disabled

Required: False
Position: Named
Default value: Enabled
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Specifies the hardware ID of an existing hardware device.

```yaml
Type: Guid
Parameter Sets: ById
Aliases: HardwareId

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a name with support for wildcards.

```yaml
Type: String
Parameter Sets: Filtered
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -RecorderId
Specifies the ID of a recording server from which to retrieve hardware.

```yaml
Type: Guid
Parameter Sets: Filtered
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServer
Specifies a recording server object from which to retrieve hardware. Use
`Get-VmsRecordingServer` to retrieve a recording server object.

```yaml
Type: RecordingServer
Parameter Sets: Filtered
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.RecordingServer

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## NOTES

## RELATED LINKS
