---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsCameraMotion/
schema: 2.0.0
---

# Get-VmsCameraMotion

## SYNOPSIS
Gets the motion detection settings for one or more cameras.

## SYNTAX

```
Get-VmsCameraMotion [-Camera] <Camera[]> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsCameraMotion` cmdlet gets the motion detection settings for one or more cameras. The MotionDetection object
for a camera can be accessed using `$camera.MotionDetectionFolder.MotionDetections[0]`. This command can be considered a
PowerShell-friendly shortcut for accessing these settings.

The only difference between using this command or accessing the MotionDetection objects directly is that this command
adds a NoteProperty to the MotionDetection object named "Camera" to make it easier to access the Camera object
associated with the MotionDetection object.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```
Get-VmsCamera | Get-VmsCameraMotion | Where-Object Enabled -eq $false | Select-Object -ExpandProperty Camera
```

Get all enabled cameras where motion detection is disabled.

## PARAMETERS

### -Camera
One or more cameras returned by the Get-VmsCamera cmdlet.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.MotionDetection

## NOTES

## RELATED LINKS
