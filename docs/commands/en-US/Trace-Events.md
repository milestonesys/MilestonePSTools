---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Trace-Events/
schema: 2.0.0
---

# Trace-Events

## SYNOPSIS

Subscribes to Milestone events from the Event Server

## SYNTAX

```
Trace-Events [-Message <String[]>] [-EventHeaderType <String>] [-EventHeaderMessage <String>]
 [-IncludeConfigurationChanged] [-IncludeFailover] [-ExcludeNewEventsIndication] [-TraceAllSites] [-Raw]
 [-MaxEvents <Int32>] [-Timeout <TimeSpan>] [-MaxInterEventDelay <TimeSpan>] [<CommonParameters>]
```

## DESCRIPTION

Subscribes to events from the Event Server.
By default only MessageId.Server.NewEventsIndication events are subscribed to, but you can either manually supply your own MessageId's in the Message parameter or you can use the built-in switches to include configuration changes and failover event messages.

Events are transposed to a more PowerShell-friendly shape by default but with the -Raw switch you can get the original event objects which will have far more detail.
For example, you can dig in to analytic events to retrieve information like plate # and confidence value.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Trace-Events -MaxEvents 10 -Timeout (New-Timespan -Seconds 60)
```

Captures up to 10 events and times out after 60 seconds if less than 10 events are received.

## PARAMETERS

### -EventHeaderMessage

Filter the NewEventIndication messages to include only those with the a message value matching a specific value.
Only valid if EventHeaderType is null.

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

### -EventHeaderType

Filter the NewEventIndication messages to include only those with the designated Event Header Type.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Access Control System Event, LPR Event, LPR Server Event, LPR Video Source Event, System Alarm, System Event, MAD

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeNewEventsIndication

Specifies that you wish not to see NewEventsIndication messages.
Use this if you're looking for more specific events and you know the MessageId for those events

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

### -IncludeConfigurationChanged

Specifies that you wish to receive events sent about configuration changes

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

### -IncludeFailover

Specifies that you wish to receive events sent about Recording Server failovers

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

### -MaxEvents

Specifies that you want to stop listening for events after a given number of events have been received.
If the value is less than 1, there will be no limit imposed and you may need to interrupt the trace manually to stop it with CTRL+C

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxInterEventDelay

Specifies a TimeSpan to wait between events before stopping the trace.
There is no limit by default.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -00:00:00.0010000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message

Optional user-defined MessageId values to register a listener for

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

### -Raw

Specifies that you want to receive an unaltered copy of the event indications from the Event Server.
The event will be wrapped in a MessageQueueMessage object which contains the Message and a datetime value named TimeReceived which represents the time the message was received in this PowerShell session.
The TimeReceived may be a few seconds older than the time the event is written to the pipeline since there may be some event queuing in the local session depending on how long your event post-processing takes.

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

### -Timeout

Specifies that you want to listen for events for a limited time.
There is no Timeout by default.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -00:00:00.0010000
Accept pipeline input: False
Accept wildcard characters: False
```

### -TraceAllSites

Specifies that you want to listen for events from all sites in a Milestone Federated Hierarchy.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### MilestonePSTools.EventCommands.TraceEventsMessage

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html)

