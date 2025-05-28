---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Update-AlarmLine/
schema: 2.0.0
---

# Update-AlarmLine

## SYNOPSIS

Updates the provided properties on the alarm matching the given id.

## SYNTAX

### UpdateAlarmValues
```
Update-AlarmLine -Id <Guid[]> -Updates <Hashtable> [-PassThru] [<CommonParameters>]
```

### UpdateAlarm
```
Update-AlarmLine -Id <Guid[]> -Text <String> [-State <Int32>] [-Priority <Int32>] [-AssignedTo <String>]
 [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

Useful for automatically updating the state or other properties of alarms.

Following are the valid keys for the Updates hashtable: - "AssignedTo" - "Comment" - "Priority" - "PriorityInt" - "PriorityName" - "ReasonCode" - "State" - "StateInt" - "StateName"

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$c1 = New-AlarmCondition -Target State -Operator NotEquals -Value 11
Get-AlarmLine -Conditions $c1 | Update-AlarmLine -Updates @{ StateName = 'Closed'; StateInt = '11' }
```

Get all alarms which are not marked as closed, and close them by updating their state

### EXAMPLE 2

```powershell
$c1 = New-AlarmCondition -Target Message -Operator Contains -Value "Tailgating"
Get-AlarmLine -Conditions $c1 | Update-AlarmLine -Text "Investigation completed" -State 11
```

Get's alarms with a message containing the word 'Tailgating' and closes them with the comment 'Investigation completed'.

## PARAMETERS

### -AssignedTo

Specifies the user to which the alarm should now be assigned.

```yaml
Type: String
Parameter Sets: UpdateAlarm
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the Guid of a single AlarmLine entry to be updated.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PassThru

Pass the alarm object back into the pipeline.

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

### -Priority

Specifies the new priority of the alarm.

```yaml
Type: Int32
Parameter Sets: UpdateAlarm
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -State

Specifies the new state of the alarm.

```yaml
Type: Int32
Parameter Sets: UpdateAlarm
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text

The text associated with this update which will be shown as a comment in the Alarm history.

```yaml
Type: String
Parameter Sets: UpdateAlarm
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Updates

Specifies the Guid of a single AlarmLine entry to be updated.

Valid property names are listed in the cmdlet description but no validation is performed before sending the request to the Event Server.

```yaml
Type: Hashtable
Parameter Sets: UpdateAlarmValues
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid[]

Specifies the Guid of a single AlarmLine entry to be updated.

## OUTPUTS

## NOTES

## RELATED LINKS
