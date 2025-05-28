---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-AlarmOrder/
schema: 2.0.0
---

# New-AlarmOrder

## SYNOPSIS

Creates a new OrderBy object which is used when working with and filtering alarms.

## SYNTAX

```
New-AlarmOrder [-Order <String>] [-Target <String>] [<CommonParameters>]
```

## DESCRIPTION

One or more OrderBy objects can be used in an AlarmFilter to specify the order of alarms to be returned.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$order = New-AlarmOrder -Order Descending -Target SourceName
$order
```

Create a new OrderBy object to specify that alarms should be sorted by SourceName in descending order.

## PARAMETERS

### -Order

Specifies the order as either Ascending or Descending.
Default is Ascending.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Ascending, Descending

Required: False
Position: Named
Default value: Ascending
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target

Specifies the target AlarmLine property to be sorted.
Default is Timestamp.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AssignedTo, CameraId, Category, CategoryName, CustomTag, Description, Id, LocalId, Location, Message, Modified, Name, ObjectId, ObjectValue, Priority, PriorityName, RuleType, SourceName, State, StateName, Timestamp, Type, VendorName

Required: False
Position: Named
Default value: Timestamp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Proxy.Alarm.OrderBy

## NOTES

## RELATED LINKS
