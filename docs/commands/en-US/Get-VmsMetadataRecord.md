---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsMetadataRecord/
schema: 2.0.0
---

# Get-VmsMetadataRecord

## SYNOPSIS
Gets one or more records from a metadata device.

## SYNTAX

### Metadata (Default)
```
Get-VmsMetadataRecord [-Timestamp <DateTime>] [-Until <DateTime>] [-Count <Int32>] -Metadata <Metadata> [-Raw]
 [<CommonParameters>]
```

### Camera
```
Get-VmsMetadataRecord [-Timestamp <DateTime>] [-Until <DateTime>] [-Count <Int32>] -Camera <Camera> [-Raw]
 [<CommonParameters>]
```

### Id
```
Get-VmsMetadataRecord [-Timestamp <DateTime>] [-Until <DateTime>] [-Count <Int32>] -Id <Guid> [-Raw]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsMetadataRecord` cmdlet gets one or more records from a metadata device. Metadata records are usually XML
documents based on the [ONVIF Metadata Stream schema](https://github.com/onvif/specs/blob/development/wsdl/ver10/schema/metadatastream.xsd).
The actual format for metadata records depends on the device driver used in XProtect.

Metadata records can be retrieved based on a timespan defined by the `Timestamp` and `Until` parameters, or a number of
records can be returned based on the `Count` parameters, starting from the provided timestamp.

The resulting metadata objects can be difficult to understand, and the contents will vary widely from one camera model
to the next. The configuration of analytics/metadata directly on the camera will have a significant impact on the type
of metadata records returned by this cmdlet.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$destination = 'C:\temp\'
$camera = Select-Camera -SingleSelect
$camera | Get-VmsMetadataRecord -Timestamp (Get-Date).AddHours(-1) -Until (Get-Date) | Where-Object {
    'Face' -in $_.GetMetadataStream().VideoAnalyticsItems.Frames.Objects.Appearance.Class.ClassCandidates.Type
} | ForEach-Object {
    $camera | Get-Snapshot -Timestamp $_.GetMetadataStream().VideoAnalyticsItems.Frames[0].UtcTime -Quality 100 -Save -Path $destination
} | Select-Object DateTime, Width, Height, HardwareDecodingStatus
```

This example retrieves all metadata records for the last hour for a user-selected camera with at least one face, and
saves a JPEG snapshot using the timestamp from the metadata record.

Note that any bounding boxes defined in the metadata are not drawn on the JPEG. However, if the camera overlays bounding
boxes directly to the video stream, they will be visible.

## PARAMETERS

### -Camera
Specifies a camera object returned by `Get-VmsCamera` which has one "Related metadata" listed in the **Client** tab in
the camera settings in Management Client. If the camera has no related metadata, or more than one related metadata, you
must be more specific by using the `Metadata` or `Id` parameters instead.

```yaml
Type: Camera
Parameter Sets: Camera
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Count
Specifies the number of metadata records to return, beginning from the time specified by `Timestamp`. This parameter is
ignored when using the `Until` parameter.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Specifies the Id of the metadata device for which to retrieve records.

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Metadata
Specifies the metadata device object for which to retrieve records.

```yaml
Type: Metadata
Parameter Sets: Metadata
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Raw
Specifies that the `MetadataPlaybackData` object returned by the `MetadataPlaybackSource` class should be returned
instead of the `MetadataContent` object. Use this if you require access to the VMS timestamp associated with the
metadata record in addition to the timestamp defined within the metadata content.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timestamp
Specifies the timestamp from which to look for metadata records. The strategy used to retrieve metadata is
**GetNearest**, which means you may receive a metadata record with a timestamp before, or after the provided timestamp.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Until
When specified, all metadata records between `Timestamp` and `Until` will be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.Metadata.MetadataContent

## NOTES

## RELATED LINKS
