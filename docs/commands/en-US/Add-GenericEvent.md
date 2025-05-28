---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-GenericEvent/
schema: 2.0.0
---

# Add-GenericEvent

## SYNOPSIS

Adds a new Generic Event to the system configuration

## SYNTAX

```
Add-GenericEvent [-Name] <String> [-Expression] <String> [[-ExpressionType] <String>] [[-Priority] <Int32>]
 [[-DataSourceId] <String>] [<CommonParameters>]
```

## DESCRIPTION

Adds a new Generic Event to the system configuration. Generic events can be used to receive generic TCP/UDP messages. If a matching message is detected, then a rule or an alarm can be triggered.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Add-GenericEvent -Name 'Hello world' -Expression '^[hH]ello [wW]orld$' -ExpressionType Regex
```

Creates a new Generic Event associated with the first enabled "Generic Event data source". The generic event be triggered if a message is received matching the prrovided regular expression. In this case, "Hello World", "Hello world", "hello World" and "hello world" would all match the given regular expression.

## PARAMETERS

### -DataSourceId

Specifies the Configuration API path of the generic event data source to associate the generic event with. The path is a string like "GenericEventDataSource[8607bccc-2bb5-4b47-a7de-8225d14c4213]" despite the parameter name implying it accepts a simple GUID. If the data source is not enabled in Management Client under Tools > Options > Generic Events, then an error will be thrown.

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

### -Expression

Specifies the expression to attempt to match TCP or UDP messages against. This can be a simple string, or a regular expression.

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

### -ExpressionType

Specifies how the expression should be used. Search implies that the expression should occur anywhere in the received message. Match means the message must match the expression exactly. Regex means the expression will be used in a regular expression pattern and the messages must match the regular expression.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Search, Match, Regex

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of the Generic Event. This is the display name used in Management Client and the rules engine.

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

### -Priority

Specifies the priority of the generic event. Use this when you may have multiple matching generic events and they should be prioritized differently.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.GenericEvent

## NOTES

## RELATED LINKS
