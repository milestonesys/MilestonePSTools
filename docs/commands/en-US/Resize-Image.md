---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Resize-Image/
schema: 2.0.0
---

# Resize-Image

## SYNOPSIS

Resizes a \[System.Drawing.Image\] object to the given height with the same aspect ratio.

## SYNTAX

```
Resize-Image [-Image] <Image> [-Height] <Int32> [[-Quality] <Int64>] [[-OutputFormat] <String>]
 [-DisposeSource] [<CommonParameters>]
```

## DESCRIPTION

Resizes a \[System.Drawing.Image\] object to the given height with the same aspect ratio and outputs a new
Image object which uses the same codec as the original image unless otherwise specified.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$image = $camera | Get-Snapshot -Live | ConvertFrom-Snapshot | Resize-Image -Height 200 -DisposeSource
$image.Size
```

Get's a live snapshot from $camera and converts it to a System.Drawing.Image object, resizes it to 200 pixels tall and disposes the original image.

## PARAMETERS

### -DisposeSource

Specifies that the original image object should be disposed.

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

### -Height

Specifies the new desired height for the resulting resized image

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Image

Specifies the Image object to be resized

```yaml
Type: Image
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OutputFormat

Specifies the desired output format such as 'BMP', 'JPEG', 'GIF', 'TIFF', 'PNG'

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: BMP, JPEG, GIF, TIFF, PNG

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quality

Specifies the desired image quality of the resulting resized image

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 95
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [System.Drawing.Image]

### [System.Drawing.Image]

Don't forget to call Dispose() when you're done with the image!

## NOTES

## RELATED LINKS
