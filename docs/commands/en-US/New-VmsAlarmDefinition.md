---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsAlarmDefinition/
schema: 2.0.0
---

# New-VmsAlarmDefinition

## SYNOPSIS

Creates a new alarm definition.

## SYNTAX

```
New-VmsAlarmDefinition [-Name] <String> [-EventTypeGroup] <String> [-EventType] <String> [-Source] <String[]>
 [[-RelatedCameras] <Camera[]>] [[-TimeProfile] <String>] [[-EnabledBy] <String[]>] [[-DisabledBy] <String[]>]
 [[-Instructions] <String>] [[-Priority] <String>] [[-Category] <String>] [-AssignableToAdmins]
 [[-Timeout] <TimeSpan>] [[-TimeoutAction] <String[]>] [-SmartMap] [[-RelatedMap] <String>] [[-Owner] <String>]
 [[-EventsToTrigger] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsAlarmDefinition` cmdlet creates a new alarm definition. Alarm definitions are used by the event server to
identify specific events of interest and then create alarms based on those events.

When defining a new alarm, the required parameters are `Name`, `EventTypeGroup`, `EventType`, and `Source`. The
`EventTypeGroup` narrows down the options for `EventType` and you must be careful to specify an `EventTypeGroup`,
`EventType`, and `Source` that are compatible.

When in doubt, manually create the alarm definition you want to automate first, and use
`Get-VmsAlarmDefinition | Format-List` to reveal all the properties and their values. You can then use the exact
`[GUID]` values for `EventTypeGroup` and `EventType` when creating alarm definitions in bulk.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### On Device Event
```powershell
New-VmsAlarmDefinition -Name 'High Room Temperature using DisplayName' -EventTypeGroup 'Device Events' -EventType 'Temperature Above Range' -Source AllCameras

New-VmsAlarmDefinition -Name 'High Room Temperature using Id' -EventTypeGroup '1eacbcad-d566-4375-834b-cfbe3d937caa' -EventType 7ab98eae-949b-41ad-8a48-d01d374fb0f5 -Source AllCameras
```

Both of the commands above create a new alarm definition based on the device event "Temperature Above Range",
triggerable by any camera with that event enabled and configured on the camera.

If the `EventTypeGroup` and `EventType` values are not `[Guid]` values, then the strings provided will be checked against
the `EventTypeGroupValues` dictionary, and the `EventTypes` returned by `(Get-VmsManagementServer).EventTypeGroupFolder.EventTypeGroups.EventTypeFolder.EventTypes | Select-Object DisplayName, Id`.

### On User-defined Event

```powershell
$ude = Get-UserDefinedEvent | Where-Object Subtype -eq 'UserDefined' | Out-GridView -OutputMode Multiple
New-VmsAlarmDefinition -Name 'On UserDefinedEvent' -EventTypeGroup 'External Events' -EventType 'External Event' -Source $ude.Path
```

In this example, you are asked to select one or more user-defined events, and a new alarm definition is created with the
selected event(s) as a source.

### On Camera Not Responding

```powershell
New-VmsAlarmDefinition -Name 'On Camera Not Responding' -EventTypeGroup 'System Events' -EventType 'Not Responding' -Source AllCameras
```

Create a new alarm definition triggered by any "Not Responding" event with any camera as the source.

### On Generic Event

```powershell
$genericEvent = Get-GenericEvent | Out-GridView -OutputMode Single
$defParams = @{
    Name           = 'On Generic Event'
    EventTypeGroup = 'External Events'
    EventType      = 'External Event'
    Source         = "UserDefinedEvent[$($genericEvent.ShadowId)]"
}
New-VmsAlarmDefinition @defParams
```

Create a new alarm definition triggered by the selected generic event.

Note that generic events have two parts. There's the generic event definition which is the event you create yourself.
Each generic events has a "shadow user defined event" that is hidden from the user interface. When a generic event
matches incoming data, the underlying shadow event is triggered.

When creating an alarm based on a generic event, this is why the value expected in the `Source` parameter is a
UserDefinedEvent configuration item path.

## PARAMETERS

### -AssignableToAdmins
Specifies whether the alarm is assignable to XProtect system administrators.

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

### -Category
Specifies the name of a pre-defined alarm category.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisabledBy
Specifies which event(s) can disable the alarm definition, disabling alarms from being created from the alarm
definition after the source event(s) are triggered. Only device inputs (InputEvent) and user-defined events are allowed
for enabling/disabling an alarm definition. You may supply an object returned by `Get-VmsInput`, or
`Get-UserDefinedEvent`, or you can provide the configuration api path for an input or user-defined event which use
the format "InputEvent[1aefd587-1d66-4213-b424-161d3992de45]", or "UserDefinedEvent[602242bc-2a01-4f4f-a965-118467166792]".

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnabledBy
Specifies which event(s) can enable the alarm definition, allowing alarms to be created from the alarm definition
only after the source event(s) are triggered. Only device inputs (InputEvent) and user-defined events are allowed
for enabling/disabling an alarm definition. You may supply an object returned by `Get-VmsInput`, or
`Get-UserDefinedEvent`, or you can provide the configuration api path for an input or user-defined event which use
the format "InputEvent[1aefd587-1d66-4213-b424-161d3992de45]", or "UserDefinedEvent[602242bc-2a01-4f4f-a965-118467166792]".

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventsToTrigger
Specifies which User-defined Events or Outputs should be triggered when an alarm is created.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventType
Specifies the event by `[Guid]`, or name. If in doubt about the correct value, create the alarm manually in Management
Client first, then inspect the `EventTypeGroup` and `EventType` values using `Get-VmsAlarmDefinition | Format-List`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventTypeGroup
Specifies the event type by `[Guid]`, or name. If in doubt about the correct value, create the alarm manually in Management
Client first, then inspect the `EventTypeGroup` and `EventType` values using `Get-VmsAlarmDefinition | Format-List`.

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

### -Instructions
Specifies the text to include for the surveillance system operators when an alarm is created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a name for the alarm definition. Note that the Management Server allows two alarm definitions to have the same name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Owner
Specifies the default owner for alarms created from this alarm definition. Note that this field in the configuration api
is not well documented and understood. Future versions of the module may improve the usability of this parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
Specifies a pre-defined alarm priority.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedCameras
Specifies one or more cameras related to an alarm triggered by the source event.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedMap
Specifies the name of a map to relate to alarms created from this alarm definition. Note that this field works with "Maps"
and not "Smart Maps". You can get a list of map names the event server will accept by running `(Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().RelatedMapValues.Keys`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmartMap
Specifies that alarms created from this alarm definition should show a "Smart Map" which displays objects using their GPS coordinates.

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

### -Source
Specifies one or more sources to watch for the specified event. Sources are provided using their Configuration API `Path`
value. For cameras, that looks like `Camera[ebc44715-5830-432e-b0c3-84e44f15c735]`.

If you pipe one or more devices to this cmdlet, the `Path` values will be collected automatically.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Path

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Timeout
Specifies a timespan after which the `TimeoutAction` events will be triggered if the alarm is not acknowledged. The
default timeout value is 1 minute.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutAction
Specifies one or more events to trigger if an alarm is not acknowledged before the specified timeout.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeProfile
Specifies a time profile during which this alarm definition is active. By default, alarm definitions are always active.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.AlarmDefinition

## NOTES

## RELATED LINKS
