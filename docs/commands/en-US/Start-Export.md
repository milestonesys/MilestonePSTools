---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Start-Export/
schema: 2.0.0
---

# Start-Export

## SYNOPSIS

Starts exporting audio/video from specified devices in the specified format.

## SYNTAX

### MKV (Default)
```
Start-Export [-EvidenceLock <MarkedData>] [-CameraIds <Guid[]>] [-MicrophoneIds <Guid[]>]
 [-SpeakerIds <Guid[]>] [-StartTime <DateTime>] [-EndTime <DateTime>] [-Path <String>] [-Name <String>]
 [-Format <String>] [-Force] [<CommonParameters>]
```

### AVI
```
Start-Export [-EvidenceLock <MarkedData>] [-CameraIds <Guid[]>] [-MicrophoneIds <Guid[]>]
 [-SpeakerIds <Guid[]>] [-StartTime <DateTime>] [-EndTime <DateTime>] [-Path <String>] [-Name <String>]
 [-Format <String>] [-Force] [-Codec <String>] [-MaxAviSizeInBytes <Int32>] [<CommonParameters>]
```

### DB
```
Start-Export [-EvidenceLock <MarkedData>] [-CameraIds <Guid[]>] [-MicrophoneIds <Guid[]>]
 [-SpeakerIds <Guid[]>] [-StartTime <DateTime>] [-EndTime <DateTime>] [-Path <String>] [-Name <String>]
 [-Format <String>] [-UseEncryption] [-Force] [-Password <String>] [-AddSignature] [-PreventReExport]
 [<CommonParameters>]
```

## DESCRIPTION

This command performs AVI, MKV and Database exports of video and audio.
It can take a list of camera, microphone, and speaker device ID's, or it can receive an Evidence Lock object as pipeline input.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Start-Export -CameraIds $id -Format DB -StartTime '2019-06-04 14:00:00' -EndTime '2019-06-04 14:15:00' -Path C:\Exports -Name Sample
```

Exports 15 minutes of video from camera with ID $id in the native Milestone Database format, starting at 2:15 PM local time, and saving to a folder at C:\Exports\Sample.

## PARAMETERS

### -AddSignature

Add a digital signature to the database export which can help verify the authenticity of an export.

```yaml
Type: SwitchParameter
Parameter Sets: DB
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CameraIds

Specifies the ID of one or more cameras using the GUID-based identifier typical of objects in a Milestone configuration.
Multiple IDs should be separated by a comma.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Codec

Specifies the codec to use to encode video in an AVI export.

```yaml
Type: String
Parameter Sets: AVI
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime

Specifies the end of the range of media to be exported.
Timestamps will be parsed in the same way as StartTime.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1/1/0001 12:00:00 AM
Accept pipeline input: False
Accept wildcard characters: False
```

### -EvidenceLock

Specifies the evidence lock record to use as a source for the camera and audio device ID's, start and end timestamps, and export name.

Note 1: If -Name is not supplied, the Header value of the evidence lock will be used to specify the folder or file name where the export is stored.

Note 2: If exporting in anything but DB format, only the first device will be exported, and the order is not guaranteed.
As such it is recommended only to pipe Evidence Locks into this command when you know there is only one device in the evidence lock.

```yaml
Type: MarkedData
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force

Ignore communication errors with recording servers by removing any devices on unresponsive servers from the overall export and proceeding without error.

Omitting this flag will result in a complete export failure in the event one or more devices cannot be reached due to a recording server not responding.

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

### -Format

Specifies the desired format for the export.
AVI and MKV files can contain only one camera and only the first device supplied will be exported.

Note: MKV will almost always be a better option than AVI.
MKV exports are much faster, require fewer resources to produce, and have the best quality.
AVI exports require transcoding from the original codec to a new codec.
There will be loss of quality, high CPU resource utilization and the time required is substantially higher than either MKV or DB.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AVI, MKV, DB

Required: False
Position: Named
Default value: MKV
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxAviSizeInBytes

Some exports can be very large in size.
AVI exports can be split into multiple files.
Default MaxAviSizeInBytes is 512MB or 536870912 bytes.

```yaml
Type: Int32
Parameter Sets: AVI
Aliases:

Required: False
Position: Named
Default value: 536870912
Accept pipeline input: False
Accept wildcard characters: False
```

### -MicrophoneIds

Specifies the ID of one or more microphones using the GUID-based identifier typical of objects in a Milestone configuration.
Multiple IDs should be separated by a comma.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of the resulting AVI or MKV file, or the subfolder for the DB export.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password

Specifies the password to be used for encrypting and decrypting the database export when UseEncryption is specified.

```yaml
Type: String
Parameter Sets: DB
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the directory where the export will be placed.
AVI and MKV's will be saved as a file in this directory while DB exports will be saved in a subfolder in this directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: .\
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreventReExport

Disallow recipients of a database export from performing a new export of their own.

```yaml
Type: SwitchParameter
Parameter Sets: DB
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SpeakerIds

Specifies the ID of one or more speakers using the GUID-based identifier typical of objects in a Milestone configuration.
Multiple IDs should be separated by a comma.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime

Specifies the start of the range of media to be exported.
Time must always be interpreted internally as UTC, so if you supply an ambiguously formatted timestamp, it is likely to be interpreted as local time and will be adjusted to UTC.

Example: This timestamp will be interpreted as 5PM local time - '2019-06-07 17:00:00'

Example: This timestamp will be interpreted as 5PM local time - '2019-06-07 5:00:00 PM'

Example: This timestamp will be interpreted as 5PM UTC time - '2019-06-07 17:00:00Z'

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1/1/0001 12:00:00 AM
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseEncryption

Encrypt the Database export

```yaml
Type: SwitchParameter
Parameter Sets: DB
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

### VideoOS.Common.Proxy.Server.WCF.MarkedData

Specifies the evidence lock record to use as a source for the camera and audio device ID's, start and end timestamps, and export name.

Note 1: If -Name is not supplied, the Header value of the evidence lock will be used to specify the folder or file name where the export is stored.

Note 2: If exporting in anything but DB format, only the first device will be exported, and the order is not guaranteed.
As such it is recommended only to pipe Evidence Locks into this command when you know there is only one device in the evidence lock.

## OUTPUTS

## NOTES

## RELATED LINKS
