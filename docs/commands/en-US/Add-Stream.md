---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-Stream/
schema: 2.0.0
---

# Add-Stream

## SYNOPSIS

Deprecated. Use Get-VmsCameraStream and Set-VmsCameraStream instead.

## SYNTAX

```
Add-Stream -Camera <Camera> [<CommonParameters>]
```

## DESCRIPTION

Deprecated. Use Get-VmsCameraStream and Set-VmsCameraStream instead.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$camera | Add-Stream
```

Adds a new stream usage for the camera assigned to the $camera variable.

## PARAMETERS

### -Camera

Specifies a camera object returned by Get-VmsCamera.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.StreamUsageChildItem

## NOTES

## RELATED LINKS
