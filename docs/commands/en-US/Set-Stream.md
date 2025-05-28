---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-Stream/
schema: 2.0.0
---

# Set-Stream

## SYNOPSIS

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

## SYNTAX

```
Set-Stream -Stream <StreamUsageChildItem> [[-StreamId] <String>] [[-Name] <String>] [[-LiveMode] <String>]
 [-LiveDefault] [-Record] [<CommonParameters>]
```

## DESCRIPTION

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$stream | Set-Stream -LiveDefault -Record -LiveMode WhenNeeded
```

Sets the stream as the default live stream, and recorded stream, and sets
LiveMode to "WhenNeeded" which means a stream will only be pulled from the
camera if the rules engine requires it.

## PARAMETERS

### -LiveDefault

Specifies that the stream should be the default live stream.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveMode

Specifies whether the live stream should be retrieved from the camera Always,
Never, or WhenNeeded.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies a new display name for the stream usage.

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

### -Record

Specifies that the stream should be the recorded stream.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stream

Specifies the stream to be updated.

```yaml
Type: StreamUsageChildItem
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -StreamId

Specifies the ID of the stream to be updated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.StreamUsageChildItem

## OUTPUTS

### None

## NOTES

## RELATED LINKS
