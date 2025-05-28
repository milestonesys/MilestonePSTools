---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-EventLine/
schema: 2.0.0
---

# Get-EventLine

## SYNOPSIS

Gets Events from the Event Server

## SYNTAX

### GetEventLines (Default)
```
Get-EventLine [-Conditions <Condition[]>] [-SortOrders <OrderBy[]>] [-StartAt <Int32>] [-PageSize <Int32>]
 [-SinglePage] [<CommonParameters>]
```

### Get
```
Get-EventLine -Id <Guid> [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Events from the Event Server using the AlarmCommandClient / IAlarmCommand interface.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$c = New-AlarmCondition -Target Timestamp -Operator GreaterThan -Value (Get-Date).Date.ToUniversalTime()
$order = New-AlarmOrder -Order Descending -Target Timestamp
Get-EventLine -Conditions $c -SortOrders $order
```

Create Conditions to filter the EventLines to only those events with a timestamp occurring on or after midnight of the current day, and order the results in descending order by time.

Note that the New-AlarmCondition and New-AlarmOrder cmdlets work for both Alarms and Events.

## PARAMETERS

### -Conditions

Specifies the AlarmFilter used to filter alarms to those having only the desired attributes.
This is also used to specify how the output should be sorted.

By default the results will be unfiltered with no guaranteed order.

```yaml
Type: Condition[]
Parameter Sets: GetEventLines
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the Guid of a single AlarmLine entry to be retrieved.

```yaml
Type: Guid
Parameter Sets: Get
Aliases:

Required: True
Position: Named
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PageSize

Each call to IAlarmCommand.GetAlarmLines returns a maximum number of results.

By default this module implements a page size of 100, but you may increase or decrease the page size to optimize for speed or memory consumption.

```yaml
Type: Int32
Parameter Sets: GetEventLines
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -SinglePage

By default all alarms matching the given conditions will be returned.

Use this switch and the StartAt and PageSize parameters if you need control over pagination.

```yaml
Type: SwitchParameter
Parameter Sets: GetEventLines
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortOrders

Specifies the AlarmFilter used to filter alarms to those having only the desired attributes.
This is also used to specify how the output should be sorted.

By default the results will be unfiltered with no guaranteed order.

```yaml
Type: OrderBy[]
Parameter Sets: GetEventLines
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartAt

Results are requested and returned in pages defined by a starting number and a PageSize

```yaml
Type: Int32
Parameter Sets: GetEventLines
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid

Specifies the Guid of a single AlarmLine entry to be retrieved.

## OUTPUTS

### VideoOS.Platform.Proxy.Alarm.EventLine

## NOTES

## RELATED LINKS
