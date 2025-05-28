---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsCameraStream/
schema: 2.0.0
---

# Set-VmsCameraStream

## SYNOPSIS
Sets properties of one or more video stream.

## SYNTAX

### RemoveStream
```
Set-VmsCameraStream [-Disabled] -Stream <VmsCameraStreamConfig[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### AddOrUpdateStream
```
Set-VmsCameraStream -Stream <VmsCameraStreamConfig[]> [-DisplayName <String>] [-LiveMode <String>]
 [-LiveDefault] [-Recorded] [-RecordingTrack <String>] [-PlaybackDefault] [-UseEdge] [-Settings <Hashtable>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Use this cmdlet to update specific properties of a video stream such as the
framerate, resolution, or codec, as well as to specify how the VMS should use
the stream. For example, if a stream should no longer be used by the VMS, you
may disable it. Or if you wish to enable a stream, and configure it as
the new default live stream, you may enable it and indicate that it should be
the LiveDefault stream from now on.

When viewing camera settings in Management Client, there are two tabs for
configuring stream settings. The "Settings" tab shows general settings that
may apply to all streams or control general streaming behavior of the camera,
as well as one or more video streams each with a set of properties exclusive to
that stream.

The "Streams" tab is where you can indicate which of the available streams from
the camera to use, and how they should be used. By default, a single stream
usage is present in the Streams tab, and it usually is associated with
"Video stream 1". This stream is both the LiveDefault and the Recorded stream,
and the LiveMode may be "WhenNeeded" or "Always".

This cmdlet consolidates both the Settings tab, and the Streams tab, to
simplify the configuration of all properties associated with streams and how
they are used by the VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$stream = $camera | Get-VmsCameraStream -LiveDefault
$settings = @{
    FPS = 10
    Codec = 'h265'
}
$stream | Set-VmsCameraStream -Settings $settings -Verbose

<# OUTPUT
VERBOSE: Performing the operation "Changing FPS from 15 to 10" on target "Video stream 1 on Cam Lab Camera".
VERBOSE: Performing the operation "Save changes" on target "Video stream 1 on Cam Lab Camera".
#>
```

After ensuring that we are connected to the Management Server, and prompting to
select a camera, we select the default live stream for the camera. Next, a
hashtable with the settings we want to apply is created, and we pass that
hashtable to Set-VmsCameraStream.

With the "-Verbose" switch present, we get detailed output which tells us
exactly which changes were made. In this case, the FPS was changed from 15 to
10, but the codec wasn't changed because it was already set to h265.

### Example 2
```powershell
foreach ($camera in Select-Camera -AllowFolders -RemoveDuplicates) {
    $streams = $camera | Get-VmsCameraStream

    $streams | Where-Object LiveMode -eq 'Never' | Set-VmsCameraStream -LiveMode WhenNeeded
    $streams[0] | Set-VmsCameraStream -LiveDefault -RecordingTrack Primary -PlaybackDefault

    if ($streams.Count -gt 1 ) {
        $streams[1..($streams.Count - 1)] | Set-VmsCameraStream -Disabled
    }
}
```

Disable all except for one stream on the selected cameras. Before making the
first stream the default live stream, and primary recorded stream, we ensure that none
of the streams have a LiveMode value of "Never" by switching all enabled
streams to a LiveMode value of "WhenNeeded".

### Example 3
```powershell
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$streams = $camera | Get-VmsCameraStream | Select-Object -First 2
$streams[0] | Set-VmsCameraStream -LiveMode WhenNeeded -LiveDefault -PlaybackDefault -RecordingTrack Primary -DisplayName "Primary stream"
$streams[1] | Set-VmsCameraStream -LiveMode WhenNeeded -LiveDefault -PlaybackDefault -RecordingTrack Secondary -DisplayName "Secondary stream"
$camera | Get-VmsCameraStream -Recorded:$false | Set-VmsCameraStream -Disabled
Get-VmsCamera | get-vmsCameraStream

<# OUTPUT
Camera   Name           DisplayName      Enabled LiveMode   LiveDefault Recorded RecordingTrack      PlaybackDefault UseEdge
------   ----           -----------      ------- --------   ----------- -------- --------------      --------------- -------
Camera 1 Video stream 1 Primary stream   True    WhenNeeded False       True     Primary recording   False           False
Camera 1 Video stream 2 Secondary stream True    WhenNeeded True        True     Secondary recording True            False
#>
```

Configures the first two streams for adaptive streaming and adaptive playback.
The first stream is recorded to the primary recording track, the second stream
is recorded to the secondary recording track, and all other streams, if present,
are disabled.

## PARAMETERS

### -Disabled
Specifies that the stream should be disabled. This is the same as clicking the
"Delete" button in the Streams tab for a camera in Management Client.

Note that while Management Client will automatically reassign the "LiveDefault"
and "Record" properties to another video stream when the deleted stream was the
default live, and/or recorded stream, this cmdlet will not. If the stream to be
disabled is the recorded, or default live stream, you must re-assign those
responsibilities to another stream first.

```yaml
Type: SwitchParameter
Parameter Sets: RemoveStream
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
Specifies a new name to be displayed to users when selecting streams in client
applications. Specifying this parameter is the same as entering an new name in
the "Name" column in the Streams tab in Management Client.

Note: Specifying a value for this parameter will automatically add the stream
to the Streams tab if it is not already enabled.

```yaml
Type: String
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveDefault
Specifies that the stream should be used by default for live viewing.

Note: Specifying a value for this parameter will automatically add the stream
to the Streams tab if it is not already enabled.

```yaml
Type: SwitchParameter
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveMode
Specifies the LiveMode for the stream which can be either Always, Never, or
WhenNeeded.

A value of "Always" means the recording server will request a live
stream from the camera at all times, even when that stream is not requested by
a client.

A value of "WhenNeeded" means the recording server will only request a live
stream from the camera when required, such as when a client is requesting that
stream, or when that stream is required by a recording rule.

Note: Specifying a value for this parameter will automatically add the stream
to the Streams tab if it is not already enabled.

```yaml
Type: String
Parameter Sets: AddOrUpdateStream
Aliases:
Accepted values: Always, Never, WhenNeeded

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlaybackDefault
Specifies that the stream should be the default stream used for playback. The
adaptive playback feature can then switch to the other recorded stream if
available based on the size of the camera tile.

REQUIREMENTS  

- Requires VMS feature "MultistreamRecording"
- Requires VMS version 23.2

```yaml
Type: SwitchParameter
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recorded
Deprecated as of 2023 R2. For compatibility, using the `-Recorded` switch parameter
has the same effect as using `-RecordingTrack Primary -PlaybackDefault` unless one
or both of these parameters are also specified.

```yaml
Type: SwitchParameter
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingTrack
Specifies which recording track to save the stream to.

```yaml
Type: String
Parameter Sets: AddOrUpdateStream
Aliases:
Accepted values: Primary, Secondary, None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Settings
Accepts a hashtable of settings used to update the properties of a given
stream. A warning will be issued if a key does not match known settings for
the stream. Settings may be changed on disabled video streams without enabling
them.

```yaml
Type: Hashtable
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stream
Accepts a VmsCameraStreamConfig as is returned by the Get-VmsCameraStream
cmdlet.

```yaml
Type: VmsCameraStreamConfig[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UseEdge
Specifies that the device's edge storage should be used, if available. Operators
can then mark a segment of video in the timeline and retrieve the edge storage
which might have higher quality than the recorded stream.

```yaml
Type: SwitchParameter
Parameter Sets: AddOrUpdateStream
Aliases:

Required: False
Position: Named
Default value: None
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

### VmsCameraStreamConfig

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
