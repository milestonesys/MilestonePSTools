---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsAlarmDefinition/
schema: 2.0.0
---

# Set-VmsAlarmDefinition

## SYNOPSIS
Sets one or more properties of an existing alarm definition.

## SYNTAX

### SmartMap
```
Set-VmsAlarmDefinition [-AlarmDefinition] <AlarmDefinition[]> [-Name <String>] [-Source <String[]>]
 [-RelatedCameras <String[]>] [-TimeProfile <String>] [-EnabledBy <String[]>] [-DisabledBy <String[]>]
 [-Instructions <String>] [-Priority <String>] [-Category <String>] [-AssignableToAdmins] [-Timeout <TimeSpan>]
 [-TimeoutAction <String[]>] [-SmartMap] [-Owner <String>] [-EventsToTrigger <String[]>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### RelatedMap
```
Set-VmsAlarmDefinition [-AlarmDefinition] <AlarmDefinition[]> [-Name <String>] [-Source <String[]>]
 [-RelatedCameras <String[]>] [-TimeProfile <String>] [-EnabledBy <String[]>] [-DisabledBy <String[]>]
 [-Instructions <String>] [-Priority <String>] [-Category <String>] [-AssignableToAdmins] [-Timeout <TimeSpan>]
 [-TimeoutAction <String[]>] [-RelatedMap <String>] [-Owner <String>] [-EventsToTrigger <String[]>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsAlarmDefinition` cmdlet can be used to change one or more properties of an existing alarm definition.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$cameras = Get-VmsCamera -Name 'Bio Lab'
Get-VmsAlarmDefinition -Name 'Temperature Rising' | Set-VmsAlarmDefinition -Source $cameras.Path
```

This example retrieves all cameras with "Bio Lab" in the name, then updates the source list on the alarm named
"Temperature Rising" with the matching cameras. Note that the `Source` parameter accepts a string like `Camera[ebc44715-5830-432e-b0c3-84e44f15c735]`,
or `InputEvent[8ae209c4-0df1-4d7e-8c04-bbe1916ecc27]` representing the configuration item path of an device XProtect
device.

## PARAMETERS

### -AlarmDefinition
Specifies one or more alarm definitions as returned by `Get-VmsAlarmDefinition`.

```yaml
Type: AlarmDefinition[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisabledBy
Specifies which event(s) can disable the alarm definition, preventing alarms from being created when the source event is
triggered.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnabledBy
Specifies which event(s) can enable the alarm definition, allowing alarms to be created when the source event is triggered.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
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
Position: Named
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

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the modified alarm definition should be returned to the pipeline.

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

### -Priority
Specifies a pre-defined alarm priority.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedCameras
Specifies one or more cameras related to an alarm triggered by the source event.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedMap
Specifies the name of a map to relate to alarms created from this alarm definition. Note that this field works with "Maps"
and not "Smart Maps". You can get a list of map names the event server will accept by running `(Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().RelatedMapValues.Keys`.

```yaml
Type: String
Parameter Sets: RelatedMap
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmartMap
Specifies that alarms created from this alarm definition should show a "Smart Map" which displays objects using their GPS coordinates.

```yaml
Type: SwitchParameter
Parameter Sets: SmartMap
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

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Position: Named
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
Position: Named
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

### VideoOS.Platform.ConfigurationItems.AlarmDefinition[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
