---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-AlarmCondition/
schema: 2.0.0
---

# New-AlarmCondition

## SYNOPSIS

Creates a new filter condition to specify which alarms should be returned in a query using Get-AlarmLines.

## SYNTAX

```
New-AlarmCondition -Target <String> -Operator <String> -Value <Object> [<CommonParameters>]
```

## DESCRIPTION

The IAlarmCommand.GetAlarmLines can be provided with an AlarmFilter containing conditions and sorting orders.

The cmdlet allows you to reduce the scope of the search for alarm lines.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$condition = New-AlarmCondition -Operator NotEquals -Target StateName -Value Closed
$condition
```

Creates a condition which will ensure only alarms which are not closed will be returned.

## PARAMETERS

### -Operator

Specifies the condition comparison operator such as 'BeginsWith' or 'Equals'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: BeginsWith, Contains, Equals, GreaterThan, LessThan, NotEquals

Required: True
Position: Named
Default value: Equals
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target

Specifies the AlarmLine property to be used for this condition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AssignedTo, CameraId, Category, CategoryName, CustomTag, Description, Id, LocalId, Location, Message, Modified, Name, ObjectId, ObjectValue, Priority, PriorityName, RuleType, SourceName, State, StateName, Timestamp, Type, VendorName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value

Specifies the AlarmLine property value to compare against.

```yaml
Type: Object
Parameter Sets: (All)
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

## OUTPUTS

### VideoOS.Platform.Proxy.Alarm.Condition

## NOTES

## RELATED LINKS
