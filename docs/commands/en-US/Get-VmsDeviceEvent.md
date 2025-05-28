---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceEvent/
schema: 2.0.0
---

# Get-VmsDeviceEvent

## SYNOPSIS
Get device events associated with Hardware, Camera, Microphone, Speaker, Metadata, Input, and Output devices.

## SYNTAX

```
Get-VmsDeviceEvent [-Device] <IConfigurationItem> [[-Name] <String>] [[-Used] <Boolean>] [[-Enabled] <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsDeviceEvent` cmdlet gets device events associated with Hardware, Camera, Microphone, Speaker, Metadata,
Input, and Output devices. These events are made available by the Hardware and the available events will depend on the
make, model, and firmware, the configuration of the device prior to adding it to Milestone, as well as the device pack
version installed on the recording server.

Note that some devices do not have events, and not all devices will have the same events. The available events might
change after installing new plugins or firmware on the hardware. If you do not find the events you expect, you may need
to run an "update hardware" or "replace hardware" task. The `Set-VmsHardwareDriver` command can be used to trigger a
"replace hardware" task which may result in an updated set of hardware/camera/device events.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Get-VmsCamera | Select-Object -First 1 | Get-VmsDeviceEvent
```

Selects the first camera returned from `Get-VmsCamera` and returns all available hardware events.

### Example 2
```powershell
Get-VmsHardware | Get-VmsMicrophone -EnableFilter All | Select-Object -First 1 | Get-VmsDeviceEvent -Used $true
```

Selects the first microphone returned from `Get-VmsMicrophone -EnableFilter All` and returns only the events where the "EventUsed" property is
`$true`. These are the available events that have been "added", but only the ones where both "EventUsed" and "Enabled"
are `$true` will be active and possible to use as a rule or alarm trigger in the VMS.

### Example 3
```powershell
Get-VmsHardware | Get-VmsInput -EnableFilter All | Select-Object -First 1 | Get-VmsDeviceEvent -Used $true -Enabled $true
```

Selects the first input returned from `Get-VmsInput` and returns only the events that are both added (EventUsed is `$true`)
and enabled.

## PARAMETERS

### -Device
Specifies one of the following device types: Hardware, Camera, Microphone, Speaker, Metadata, Input, or Output.

REQUIREMENTS  

- Allowed item types: Hardware, Camera, Microphone, Speaker, Metadata, InputEvent, Output

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Enabled
When specified, only events where the Enabled property matches will be returned. All events are returned by default.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the event to return, with support for wildcard characters. All events are returned by default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Used
When specified, only events where the EventUsed property matches will be returned. All events are returned by default.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.HardwareDeviceEventChildItem

## NOTES

Two `NoteProperty` property members named `Device` and `HardwareDeviceEvent` are added to the `HardwareDeviceEventChildItem`
object(s) returned by this command and these are required by `Set-VmsDeviceEvent`.

## RELATED LINKS
