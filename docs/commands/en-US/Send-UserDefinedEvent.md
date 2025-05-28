---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Send-UserDefinedEvent/
schema: 2.0.0
---

# Send-UserDefinedEvent

## SYNOPSIS

Triggers a User-defined Event.

## SYNTAX

### FromObject
```
Send-UserDefinedEvent [-UserDefinedEvent] <UserDefinedEvent> [[-Cameras] <Camera[]>]
 [[-Microphones] <Microphone[]>] [[-Speakers] <Speaker[]>] [[-Metadatas] <Metadata[]>]
 [[-Inputs] <InputEvent[]>] [[-Outputs] <Output[]>] [<CommonParameters>]
```

### FromId
```
Send-UserDefinedEvent [-Id] <String> [[-Cameras] <Camera[]>] [[-Microphones] <Microphone[]>]
 [[-Speakers] <Speaker[]>] [[-Metadatas] <Metadata[]>] [[-Inputs] <InputEvent[]>] [[-Outputs] <Output[]>]
 [<CommonParameters>]
```

## DESCRIPTION

The `Send-UserDefinedEvent` cmdlet triggers a specified User-defined Event. The following device objects can
be attached as metadata to the event:

- Cameras
- Inputs
- Metadatas
- Microphones
- Outputs
- Speakers

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Send-UserDefinedEvent -Id 'C2CB71E4-FB93-42F5-96FA-BD91514051A8'
```

Triggers User-defined Event with ID 'C2CB71E4-FB93-42F5-96FA-BD91514051A8'

### Example 2

```powershell
$cam = Select-Camera
Get-UserDefinedEvent -Name 'SampleUDE' | Send-UserDefinedEvent -Cameras $cam
```

Prompts user to select one or more cameras from a UI. Then gets a User-defined Event with name 'SampleUDE'
and pipes it to `Send-UserDefinedEvent` to triggerit and include the selected cameras as associated
metadata.

## PARAMETERS

### -Cameras

Specifies one or more `Camera` objects as returned by `Get-VmsCamera` or `Select-Camera`.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the ID of the User-defined Event object to be sent.

```yaml
Type: String
Parameter Sets: FromId
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Inputs

Specifies one or more `Input` objects as returned by `Get-VmsInput`.

```yaml
Type: InputEvent[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Metadatas

Specifies one or more `Metadata` objects as returned by `Get-VmsMetadata`.

```yaml
Type: Metadata[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Microphones

Specifies one or more `Microphone` objects as returned by `Get-VmsMicrophone`.

```yaml
Type: Microphone[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Outputs

Specifies one or more `Output` objects as returned by `Get-VmsOutput`.

```yaml
Type: Output[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Speakers

Specifies one or more `Speaker` objects as returned by `Get-VmsSpeaker`.

```yaml
Type: Speaker[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserDefinedEvent

Specifies the `User-defined Event` as returned by `Get-UserDefinedEvent`.

```yaml
Type: UserDefinedEvent
Parameter Sets: FromObject
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.UserDefinedEvent

## OUTPUTS

## NOTES

## RELATED LINKS
