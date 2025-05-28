---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Send-MipMessage/
schema: 2.0.0
---

# Send-MipMessage

## SYNOPSIS

Sends a custom MIP message and optionally awaits the response.

## SYNTAX

```
Send-MipMessage [-MessageId] <String> [[-RelatedFqid] <FQID>] [[-Data] <Object>] [[-Reason] <String>]
 [[-DestinationEndpoint] <FQID>] [[-DestinationObject] <FQID>] [[-Source] <FQID>]
 [[-ResponseMessageId] <String>] [[-Timeout] <Double>] [-UseEnvironmentManager] [<CommonParameters>]
```

## DESCRIPTION

Messaging is a core feature and component of the MIP SDK.
Almost all actions and queries are handled through messaging.
This cmdlet provides a mechanism for interacting with the messaging framework from PowerShell which gives you a fairly low-level interface into the VMS.
As such, it can be complex to use and you should consult the MIP SDK documentation to better understand the available messages and how to use them.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Send-MipMessage -MessageId Control.TriggerCommand -DestinationEndpoint $presets[0].FQID -UseEnvironmentManager
```

Activates a PTZ preset using the Control.TriggerCommand message.
The DestinationEndpoint should be the FQID of a PtzPreset object.
To get a list of PtzPreset items for a camera, you could do $presets = $camera.PtzPresetFolder.PtzPresets | Get-VmsVideoOSItem -Kind Preset

## PARAMETERS

### -Data

Some MessageIds such as those related to PTZ are accompanied by some kind of object.
Reference the MIP SDK documentation for more information about expected objects.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationEndpoint

Defines the FQID of the destination client or server endpoint for this message.

```yaml
Type: FQID
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationObject

Defines the FQID of an object on the DestinationEndpoint to receive this message.

```yaml
Type: FQID
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageId

MessageId string to send.

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

### -Reason

Specifies the reason the message is being sent.
Not commonly used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedFqid

Defines the FQID of the device or item related to the provided MessageId.

```yaml
Type: FQID
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResponseMessageId

Defines the MessageId to listen for as a response to this message.
Optional.

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

### -Source

Defines the FQID of the sender (or null if the recipients don't care)

```yaml
Type: FQID
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout

Time, in seconds, to wait for a response.
If ResponseMessageId is null or whitespace, then a response is not expected and this cmdlet will return immediately after sending the message.
Default is 10 seconds.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseEnvironmentManager

Specifies that the message should be sent using EnvironmentManager.Instance instead of MessageCommunicationManager.
Some MIP SDK messages are only delivered correctly when sent using the EnvironmentManager.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: False
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
