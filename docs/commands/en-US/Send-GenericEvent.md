---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Send-GenericEvent/
schema: 2.0.0
---

# Send-GenericEvent

## SYNOPSIS

Sends a TCP or UDP message to the Event Server to trigger a Generic Event

## SYNTAX

```
Send-GenericEvent [-DataSource <GenericEventDataSource>] [-EventString] <String> [[-DataSourceName] <String>]
 [[-ReadTimeout] <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Generic Events are a way to receive predefined strings or patterns as strings over TCP/UDP in order to trigger events, which can then be used as a trigger for a rule to perform some action.

This command simplifies testing of generic events by automatically retrieving the correct host/ip and port, appending the 'separator bytes' if defined in the Data Source configuration in Management Client under Tools \> Options \> Generic Events, and parsing the response in the event the Data Source is configured to echo 'Statistics'.

For debugging, try adding -Verbose and reviewing some of the details provided.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Send-GenericEvent "Hello World"
```

Sends the string "Hello World" to the first enabled Generic Event Data Source, which is usually named "Compatible" and listens on TCP port 1234.

### EXAMPLE 2

```powershell
Send-GenericEvent "Hello World" CustomDataSource
```

Sends the string "Hello World" a Data Source named CustomDataSource.
The port and protocol would be defined in that data source but you can see those values in the output when you provide the -Verbose switch.

## PARAMETERS

### -DataSource

Specifies the GenericEventDataSource to send the EventString to

If omitted, the first enabled data source will be used.

```yaml
Type: GenericEventDataSource
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataSourceName

Specifies the name of the GenericEventDataSource to send the EventString to

If omitted, the first enabled data source will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventString

Specifies the string to send to the Event Server

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

### -ReadTimeout

Specifies the timeout in milliseconds to wait for a response when Echo is not "None" and the protocol is not UDP.

Default is 2000ms

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 2000
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html)

