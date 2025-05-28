---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-AlarmStatistics/
schema: 2.0.0
---

# Get-AlarmStatistics

## SYNOPSIS

Gets alarm statistics from the Event Server which provides the number of alarms in each state.

## SYNTAX

```
Get-AlarmStatistics [<CommonParameters>]
```

## DESCRIPTION

The `Get-AlarmStatistics` cmdlet gets the number of alarms in each state.
The values are estimates as the statistics are not updated on demand.

The built-in alarm state values are New=1, In progress=4, On hold=9 and Closed=11.
Administrators may add additional states in Management Client.

In the resulting Statistic\[\] object, the Statistic.Number property represents the State and the Statistic.Value property represents the number of alarms in that state.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-AlarmStatistics
```

Outputs the number of alarms that are in each state. If there are zero alarms in a particular state, nothing will be outputted for that state.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Proxy.Alarm.Statistic[]

## NOTES

## RELATED LINKS
