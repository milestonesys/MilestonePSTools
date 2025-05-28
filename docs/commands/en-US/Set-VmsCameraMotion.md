---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsCameraMotion/
schema: 2.0.0
---

# Set-VmsCameraMotion

## SYNOPSIS
Sets motion detection settings for one or more cameras.

## SYNTAX

```
Set-VmsCameraMotion [-Camera] <Camera[]> [[-DetectionMethod] <String>] [[-Enabled] <Boolean>]
 [[-ExcludeRegions] <String>] [[-GenerateMotionMetadata] <Boolean>] [[-GridSize] <String>]
 [[-HardwareAccelerationMode] <String>] [[-KeyframesOnly] <Boolean>] [[-ManualSensitivity] <Int32>]
 [[-ManualSensitivityEnabled] <Boolean>] [[-ProcessTime] <String>] [[-Threshold] <Int32>]
 [[-UseExcludeRegions] <Boolean>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsCameraMotion` cmdlet sets motion detection settings for one or more cameras.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```
$splat = @{
    Enabled                  = $true
    HardwareAccelerationMode = 'Automatic'
    KeyframesOnly            = $true
    DetectionMethod          = 'Fast'
    ProcessTime              = 'Ms500'
    GenerateMotionMetadata   = $true
    ManualSensitivityEnabled = $false
    UseExcludeRegions        = $false
    GridSize                 = 'Grid16X16'
    ExcludeRegions           = '0' * (16*16)
}
Get-VmsCamera | Set-VmsCameraMotion @splat -Verbose -WhatIf
```

Updates all cameras to the default motion detection settings when the -WhatIf switch is removed.

## PARAMETERS

### -Camera
One or more cameras on which to update motion detection settings.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DetectionMethod
A value of **Normal**, **Optimized**, or **Fast** which represent 100%, 25%, and 12% detection resolution respectively. A **DetectionMethod** of **Optimized** would only evaluate every 4th pixel requiring less compute than
'Normal' or 100%.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Normal, Optimized, Fast

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
A boolean value specifying whether motion detection should be enabled or disabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeRegions
A string of 0's and 1's representing the chosen grid size.
Areas of the grid marked with a 1 will be excluded from
motion detection.

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

### -GenerateMotionMetadata
Specifies whether motion metadata used to support smart search capabilities will be generated.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GridSize
The size of the grid representing the motion detection exclusion region.
Supported values are **Grid8X8**, **Grid16X16**, **Grid32X32**, **Grid64X64**.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Grid8X8, Grid16X16, Grid32X32, Grid64X64

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HardwareAccelerationMode
Set the HardwareAccelerationMode to **Automatic**, or **Off**.

REQUIREMENTS  

- Requires VMS feature "HardwareAcceleratedVMD"

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Automatic, Off

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyframesOnly
Only evaluate keyframes for motion.
By default, keyframes usually arrive once per second.
They can be much farther
apart when using a custom keyframe interval, or a "smart" codec with a dynamic GOP (group of pictures) length.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManualSensitivity
A value between 0 and 300 representing how much an individual pixel must change before it is considered a changing
pixel. Note that the Management Client user interface represents this number as a range of 0-100. In PowerShell you
should see a number 3x larger than the number shown in Management Client.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManualSensitivityEnabled
Specifies that the ManualSensitivity and Threshold parameters should be used to evaluate motion instead of using
automatic motion detection.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the camera object to the pipeline after updating motion detection settings.

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

### -ProcessTime
Specifies the time interval between each image evaluated for motion.
This applies only to cameras streaming MJPEG.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Ms100, Ms250, Ms500, Ms750, Ms1000

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Threshold
Specifies how many pixels must change in order to trigger a motion started event.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseExcludeRegions
Specifies whether the ExcludeRegions mask should be applied so that changes in the masked areas of the image are ignored
for motion detection.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## NOTES

## RELATED LINKS
