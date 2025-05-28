---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-PlaybackInfo/
schema: 2.0.0
---

# Get-PlaybackInfo

## SYNOPSIS

Gets the UTC timestamp of the first and last record in the media database for a device.

## SYNTAX

### FromPath (Default)
```
Get-PlaybackInfo -Path <String[]> [-SequenceType <String>] [-Parallel] [<CommonParameters>]
```

### FromDevice
```
Get-PlaybackInfo -Device <IConfigurationItem[]> [-SequenceType <String>] [-Parallel] [<CommonParameters>]
```

### DeprecatedParameterSet
```
Get-PlaybackInfo [-SequenceType <String>] [-Parallel] [-Camera <Camera>] [-CameraId <Guid>] [-UseLocalTime]
 [<CommonParameters>]
```

## DESCRIPTION

Gets the UTC timestamp of the first and last record in the media database for a device.
The
result is returned as a PSCustomObject with a Begin and End property representing the first
and last record timestamps in the media database.

The method for retrieving this data used to be based on the RawDataSource class, but a
faster method is now used which is based on a SequenceDataSource class.
Sequences represent
timespans in the media database where recordings, or motion are present.
To use the
SequenceDataSource in this function, we ask for the first sequence occuring sometime between
unix epoch and now, and we use the StartDateTime property.
We then ask for the first sequence
occuring between now and unix epoch in the reverse direction, and use the EndDateTime property.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Select-Camera -SingleSelect | Get-PlaybackInfo
```

Begin                 End                   Path
-----                 ---                   ----
9/17/2021 11:21:53 PM 10/17/2021 5:15:15 PM Camera\[9c55377a-c2e4-4f03-99b6-d684e730c4e1\]

Presents a camera selection dialog, and after you've selected a camera, it returns an object with
the first and last image timestamps.

## PARAMETERS

### -Camera

Deprecated.
Specifies a camera object - typically the output of a Get-VmsCamera command.

```yaml
Type: Camera
Parameter Sets: DeprecatedParameterSet
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CameraId

Deprecated.
Specifies the Guid value of a Camera object.

```yaml
Type: Guid
Parameter Sets: DeprecatedParameterSet
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Device

Specifies the Camera, Microphone, Speaker, or Metadata object.
The Path property is used from
these objects to construct the VideoOS.Platform.ConfigItem used to construct the SequenceDataSource.

```yaml
Type: IConfigurationItem[]
Parameter Sets: FromDevice
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Parallel

Specifies that multiple requests should be processed in parallel.
If fewer than 60 devices are
specified in the Path or Device parameters, then this switch has no impact.
Using multiple
threads for a small number of devices can end up taking longer than doing them sequentially,
especially with the operation completes relatively quickly to begin with.

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

### -Path

Specifies the Milestone "Configuration API" path for the device.
The format of a Configuration
API path is ItemType\[guid\].
For example, Camera\[5cb24b72-d946-4e87-83a2-9ad79da2f40b\].
This
property is available on all Configuration API generic item types, and strongly typed objects
like Cameras and Microphones.
The format provides both the ItemType value and the ID which are
used to locate the VideoOS.Platform.ConfigItem representing the camera in
VideoOS.Platform.Configuration.Instance, and this item is used to construct the SequenceDataSource.

```yaml
Type: String[]
Parameter Sets: FromPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SequenceType

Specifies the type of sequence to return playback info for.
The default is RecordingSequence,
and that makes the most sense to use with this cmdlet.
This parameter is provided in case it
is interesting to know the first and last "motion" sequence instead.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: MotionSequence, RecordingSequence, TimelineMotionDetected, TimelineRecording

Required: False
Position: Named
Default value: RecordingSequence
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseLocalTime

Deprecated.
Convert the UTC timestamps from the Recording Server(s) to local time using the
region settings of the current session.

```yaml
Type: SwitchParameter
Parameter Sets: DeprecatedParameterSet
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

## OUTPUTS

## NOTES

The original version of Get-PlaybackInfo only worked for cameras, and we realize now the
UseLocalTime switch was unnecessary.
It's easy enough to call ToLocalTime() if you want to
switch to your local timezone.
As such, the Camera, CameraId, and UseLocalTime parameters are
deprecated.
They'll still work for a while, but with warnings.
Instead of explicitly using them,
consider piping your devices into this function, or using the -Device or -Path parameters.

A bonus of using the new parameters is that you can provide an array of objects or configuration
item paths, include the Parallel switch, and the results may be returned faster through the use
of runspaces for running requests in parallel.

## RELATED LINKS

[MIP SDK Docs - SequenceDataSource](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/class_video_o_s_1_1_platform_1_1_data_1_1_sequence_data_source.html&tree=tree_search.html?search=sequencedatasource)

