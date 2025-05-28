---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Send-Alarm/
schema: 2.0.0
---

# Send-Alarm

## SYNOPSIS

Sends a new Alarm object to the Event Server.

## SYNTAX

```
Send-Alarm -Alarm <Alarm> [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

A new alarm object can be created with New-Alarm, then after the properties are filled out as desired, you can send the alarm to the Event Server to create a new AlarmLine directly.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$cameraItem = Get-VmsCamera -Id 948aa6a2-9a46-4c4c-8279-af0485428d75 | Get-VmsVideoOSItem -Kind Camera
$alarm = New-Alarm -Message "Important Alarm Message" -Source $cameraItem
$alarm | Send-Alarm
```

Retrieves the Item object for Camera with the given Id and creates an Alarm with this camera as the source.

The Alarm object is then sent to the Event Server which generates a new alarm.

## PARAMETERS

### -Alarm

An alarm object to send to the Event Server through an AlarmClient instance.

Create an alarm with New-Alarm and fill out the properties before sending it.

```yaml
Type: Alarm
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru

Pass the alarm object back into the pipeline.

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

### VideoOS.Platform.Data.Alarm

An alarm object to send to the Event Server through an AlarmClient instance.

Create an alarm with New-Alarm and fill out the properties before sending it.

## OUTPUTS

## NOTES

## RELATED LINKS
