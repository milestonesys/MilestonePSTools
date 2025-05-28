---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-StreamProperties/
schema: 2.0.0
---

# Get-StreamProperties

## SYNOPSIS

Get a list of configuration properties from the designated camera stream

## SYNTAX

### ByNumber
```
Get-StreamProperties -Camera <Camera> [-StreamNumber <Int32>] [<CommonParameters>]
```

### ByName
```
Get-StreamProperties -Camera <Camera> [-StreamName <String>] [<CommonParameters>]
```

## DESCRIPTION

Get a list of configuration properties from the designated camera stream.
These properties provide detailed information including
the property key, current value, the value type, and in the case of certain value types, a list of valid values or a range of
valid values.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Select-Camera | Get-StreamProperties -StreamName 'Video stream 1'
```

Opens a dialog to select a camera, then returns the stream properties for 'Video stream 1'.
The objects returned are rich property
objects with a number of properties attached to them in addition to their keys and values.

## PARAMETERS

### -Camera

Specifies the camera to retrieve stream properties for

```yaml
Type: Camera
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -StreamName

Specifies a StreamUsageChildItem from Get-Stream

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StreamNumber

Specifies the stream number starting from 0.
For example, "Video stream 1" is usually in the 0'th position in the StreamChildItems collection.

```yaml
Type: Int32
Parameter Sets: ByNumber
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

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.Property[]

## NOTES

## RELATED LINKS
