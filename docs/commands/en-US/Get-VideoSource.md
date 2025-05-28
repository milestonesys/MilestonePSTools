---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VideoSource/
schema: 2.0.0
---

# Get-VideoSource

## SYNOPSIS

Gets a MIP SDK VideoSource object for a given camera which can be used to navigate the media database to retrieve images

## SYNTAX

```
Get-VideoSource [-Fqid <FQID>] [-Camera <Camera>] [[-CameraId] <Guid>] [[-Format] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

WARNING: This is experimental and has a significant memory leak until a strategy for disposing of unused resources in a powershell environment can be determined.

Gets one of a BitmapVideoSource, JPEGVideoSource or RawVideoSource object depending on the provided Format value.
The default is Raw since that puts no video decoding burden on the Recording Server.

See the MIP SDK documentation link in the related links of this help info for details on how to navigate recordings with these VideoSource objects.
The objects include methods like GetBegin(), GetEnd(), GetNearest(datetime), GetNext() and GetPrevious(), and the results provide information about the timestamp, whether a next or previous image is available and what the timestamp of that image is, in addition to the image data itself.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$src = $camera | Get-VideoSource -Format Jpeg
$src.GetBegin()
$src.GetNext()
```

Gets the first and second images in the media database for the camera referenced in the variable $camera.

## PARAMETERS

### -Camera

Specifies a camera object - typically the output of a Get-VmsCamera command.

```yaml
Type: Camera
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CameraId

Specifies the Guid value of a Camera object.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format

Specifies the format in which data should be returned

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Bitmap, Jpeg, Raw

Required: False
Position: 2
Default value: Raw
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fqid

Specifies a camera by FQID.
Useful when all you have is the FQID such as when you're using a Get-ItemState result, or the output of some event header data.

```yaml
Type: FQID
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.FQID

Specifies a camera by FQID.
Useful when all you have is the FQID such as when you're using a Get-ItemState result, or the output of some event header data.

### VideoOS.Platform.ConfigurationItems.Camera

Specifies a camera object - typically the output of a Get-VmsCamera command.

## OUTPUTS

### VideoOS.Platform.Data.VideoSource

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html)

