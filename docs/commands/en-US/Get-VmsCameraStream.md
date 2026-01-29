---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsCameraStream/
schema: 2.0.0
---

# Get-VmsCameraStream

## SYNOPSIS
Gets stream configuration information for the specified camera(s).

## SYNTAX

### Name (Default)
```
Get-VmsCameraStream -Camera <Camera[]> [-Name <String>] [-RawValues] [<CommonParameters>]
```

### Enabled
```
Get-VmsCameraStream -Camera <Camera[]> [-Enabled] [-RawValues] [<CommonParameters>]
```

### LiveDefault
```
Get-VmsCameraStream -Camera <Camera[]> [-LiveDefault] [-RawValues] [<CommonParameters>]
```

### PlaybackDefault
```
Get-VmsCameraStream -Camera <Camera[]> [-PlaybackDefault] [-RawValues] [<CommonParameters>]
```

### Recorded
```
Get-VmsCameraStream -Camera <Camera[]> [-Recorded] [-RawValues] [<CommonParameters>]
```

### RecordingTrack
```
Get-VmsCameraStream -Camera <Camera[]> [-RecordingTrack <String>] [-RawValues] [<CommonParameters>]
```

## DESCRIPTION
Video stream configuration in a Milestone XProtect VMS includes properties of
the video stream(s) themselves, such as framerate, codec, and resolution, in
addition to whether the VMS will use those video streams, and for what
purpose.

The results returned from this cmdlet include the immutable name of the video
stream such as "Video stream 1", which is displayed in the settings tab for each
camera in Management Client. A collection of key-value pairs representing the
properties of the video stream is available in the "Settings" property of the
[VmsCameraStreamConfig] object.

A second hashtable with keys matching the keys of the Settings hashtable is
available under a property named "ValueTypeInfo. Each element in the
ValueTypeInfo hashtable is a collection of ValueTypeInformation objects
representing the valid values, or ranges for each setting for the stream. See
the examples for more information.

If the stream is in use by the VMS for either live streaming, or for recording,
then the stream's "Enabled" property will be $true. When a stream is in use,
it will have a DisplayName value representing the name of the stream displayed
to anyone using a client application like XProtect Smart Client. The Name
property is immutable, but you may name the DisplayName property as needed.

Also included are the LiveMode, LiveDefault, and Recorded properties. These
indicate whether the stream is selected as the default live stream, and/or the
recorded stream. And whether the stream is available for live viewing Always,
Never, or WhenNeeded.

The LiveMode of a stream can only be set to "Never" when the stream is
exclusively used for recording. This is to allow administrators to record at a
very high quality, while avoiding unnecessary bandwidth usage by enabling only
a lower-bandwidth stream for live viewing. When the LiveMode is set to
"WhenNeeded", the recording server will only pull that stream from the camera
when a client requests it.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$camera | Get-VmsCameraStream -LiveDefault

<# OUTPUT
Camera  Name           DisplayName Enabled LiveMode   LiveDefault Recorded
------  ----           ----------- ------- --------   ----------- --------
Cam Lab Video stream 1 Live stream True    WhenNeeded True        True
#>
```

After first logging in to the Management Server, we use a helpful camera
selection dialog. Select any camera, and the properties of the default live
stream will be displayed. The properties include Settings and ValueTypeInfo
collections as hashtables, but they are not rendered in the PowerShell terminal
by default because hashtables don't display very useful information unless they
are expanded. The next example will show how to display more information about
the stream settings.

### Example 2
```powershell
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$stream = $camera | Get-VmsCameraStream -LiveDefault
$stream.Settings

<# OUTPUT
Name                           Value
----                           -----
ZFpsMode                       Fixed
Compression                    30
StreamingMode                  RTP/RTSP/TCP
ControlMode                    Variable bit rate
TargetBitrate                  2000
MaxBitrate                     0
Resolution                     1280x720
FPS                            10
MaxGOPMode                     Default (determined by driver)
ControlPriority                None
IncludeTime                    No
EdgeStorageSupported           true
ZGopLength                     300
ZGopMode                       Fixed
MaxGOPSize                     30
ZStrength                      Low
RetentionTime                  7
IncludeDate                    No
Codec                          H.265
#>

($camera | Get-VmsCameraStream -LiveDefault -RawValues).Settings

<# OUTPUT (raw values)
Name                           Value
----                           -----
ZFpsMode                       fixed
Compression                    30
StreamingMode                  TCP
ControlMode                    VariableBitRate
TargetBitrate                  2000
MaxBitrate                     0
Resolution                     1280x720
FPS                            10
MaxGOPMode                     default
ControlPriority                None
IncludeTime                    no
EdgeStorageSupported           True
ZGopLength                     300
ZGopMode                       fixed
MaxGOPSize                     30
ZStrength                      low
RetentionTime                  7
IncludeDate                    no
Codec                          h265
#>
```

This example begins the same as the last, using a camera selection dialog. Then
we store the VmsCameraStreamConfig reference in the "$stream" variable, and
display the content of "$stream.Settings". The results are a collection of
key/value pairs representing a variety of properties of the default live stream
for the selected camera.

The properties will vary widely by camera make, model, and Milestone device pack
driver. For instance, not every camera will have an "FPS" or "Resolution"
property, and in some cases, they may be present, but with different names or
value formats. For example, Resolution for one camera might be formatted like
"1920x1080", while another camera stores resolution values like "MP 1080p". The
properties and their available values are determined by the device pack driver
on the recording server.

By default, the values for settings are the "display values". For example,
the raw value for Codec might be "4", but that is not meaningful for a report,
so the display value for "4" is retrieved from the ValueTypeInfo collection. If
raw values are preferred, you can use the "-RawValues" switch.

Note that there are some settings, such as "EdgeStorageSupported" which are
read-only. However, there is currently no method to discover this using this
cmdlet.

### Example 3
```powershell
# This example will show the properties of an Axis camera using the ONVIF driver
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$stream = $camera | Get-VmsCameraStream -LiveDefault -RawValues
$stream.Settings

<# OUTPUT (partial)
Name                           Value
----                           -----
Codec                          4
#>

$stream.ValueTypeInfo.Codec

<# OUTPUT
TranslationId                        Name                   Value
-------------                        ----                   -----
f98cc65b-4b3c-43c6-b59e-25003f32b9a5 JPEG                   0
e6d2aa07-39fc-49d7-a632-3ceb08b754c6 H.264 Baseline Profile 3
83f64935-44f7-40aa-860d-20fe57be44ce H.264 Main Profile     4
83c9a259-d54e-4179-91e9-d7c053dc0de8 H.264 High Profile     6
5acf7ca5-e822-460b-a70d-d3c82e28af48 H.265 Main Profile     7
#>
```

Building on the last example, here we dig deeper to understand the meaning of
the codec setting value of "4". The setting name "Codec" is a key in the
ValueTypeInfo hashtable and when we reveal the contents, we see a list of
ValueTypeInformation objects showing the display name (Name) and internal value
(Value) for each value available for that setting.

We also see a TranslationId property. This can be used in combination with
the "Get-Translation" cmdlet to get a localized display name for each value.

### Example 4
```powershell
# This example will show the properties of an Axis camera using the ONVIF driver
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$stream = $camera | Get-VmsCameraStream -LiveDefault
$stream.Settings

<# OUTPUT (partial)
Name                           Value
----                           -----
Quality                        70
#>

$stream.ValueTypeInfo.Quality

<# OUTPUT
TranslationId Name      Value
------------- ----      -----
              MinValue  0
              MaxValue  100
              StepValue 1
#>
```

This example shows a different type of value you will encounter - a range. You
will typically see these value types when working with numeric settings like
FPS, Quality, Compression, and so on.

When we check the ValueTypeInfo collection for the Quality property, we see the
range defined as 0-100 using the MinValue and MaxValue entries. There is also
a StepValue indicated, and from this we can determine that only whole numbers
between 0 and 100 are accepted as values for the Quality setting. This value
includes a StepValue, but not every range does.

Since this value is not an "enumeration" type with fixed values like "Low" or
"High", there are no words to translate, and we do not see any TranslationId
values.

### Example 5
```powershell
$codec = @{
    Name = 'Codec'
    Expression = {$_.Settings.Codec}
}
$fps = @{
    Name = 'FPS'
    Expression = {$_.Settings.FPS}
}
Get-VmsHardware | Get-VmsCamera | Get-VmsCameraStream -LiveDefault | `
    Select-Object Camera, Name, DisplayName, Recorded, $codec, $fps | `
    Select-Object -First 10 | `
    Format-Table

<# OUTPUT
Camera                         Name           DisplayName    Recorded Codec FPS
------                         ----           -----------    -------- ----- ---
Learning & Performance (Bos... Video stream 1 Video stream 1     True       15
US101 at Lincoln City - Log... Video stream 1 Video stream 1     True MJPEG 0.5
I-405 at MP 0.8: West Valle... Video stream 1 Video stream 1     True MJPEG 0.5
Camera Lab (AXIS P1435-LE)     Video stream 2 Video stream 2    False H.264 15
Southwest Corner - Rear Ent... Video stream 2 Video stream 2    False H.264 15
Halo Smart Sensor              Video stream 1 Video stream 1     True H.264 10
I-84 at LePage Park - John ... Video stream 1 Video stream 1     True MJPEG 0.5
Gameroom door (AXIS P3245-V... Video stream 2 Video stream 2    False H.264 15
Southwest Corner - Rear Par... Video stream 2 Video stream 2    False H.264 15
Lobby Fisheye (Bosch 7000 M... Video stream 2 Video stream 2    False       15
#>
```

This example shows how you might use the cmdlet to learn about how all camera
live streams are configured. With the "Select-Object -First 10" we limit the
results. The $codec, and $fps hashtables are used to add "calculated properties"
to our use of "Select-Object". When you want to include the nested value of a
property in your results, this is one way to do that.

The camera name is included in the default view for these results, and if you
need more information from the camera object, you can use the hidden "Camera"
property attached to the VmsCameraStreamConfig object returned by this cmdlet.

### Example 6
```powershell
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'

# Get the stream used as the default playback stream
$camera | Get-VmsCameraStream -PlaybackDefault

# Get the stream(s) that are NOT used as the default playback stream
$camera | Get-VmsCameraStream -PlaybackDefault:$false

# Get the primary recording stream
$camera | Get-VmsCameraStream -RecordingTrack Primary

# Get the secondary recording stream (supported in 2023 R2 and later)
$camera | Get-VmsCameraStream -RecordingTrack Secondary

# Get all enabled streams that are not used for recording.
$camera | Get-VmsCameraStream -RecordingTrack None
```

This example shows a few ways you can use the PlaybackDefault and RecordingTrack
parameters which were introduced to support the adaptive playback feature introduced
in 2023 R2.

## PARAMETERS

### -Camera
Specifies one or more camera objects such as are returned by Get-VmsCamera.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Enabled
Specifies that only enabled streams should be returned. This includes any stream
that is used as the default live stream, recorded stream, or is otherwise added
and displayed in the "Streams" tab for the camera in Management Client. It
includes all streams that are configured for any kind of use by the VMS.

```yaml
Type: SwitchParameter
Parameter Sets: Enabled
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveDefault
Specifies that only the default live stream for the given camera should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: LiveDefault
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the video stream as displayed in the Settings tab for the
camera in Management Client.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -PlaybackDefault
Specifies that the returned stream should be the one currently used as the default playback stream.

```yaml
Type: SwitchParameter
Parameter Sets: PlaybackDefault
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawValues
Specifies that the raw, internal values of settings should be returned instead
of returning the display values seen in Management Client.

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

### -Recorded
Deprecated as of 2023 R2 with the introdution of secondary recorded streams.
For compatibility, using the `-Recorded` switch parameter has the same
effect as using `-RecordingTrack Primary`.

```yaml
Type: SwitchParameter
Parameter Sets: Recorded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingTrack
Return only the stream(s) using the specified recording track. The ability to
record a second stream from the same camera on the same recording server was
introduced in XProtect 2023 R2 and is called "Adaptive playback".

```yaml
Type: String
Parameter Sets: RecordingTrack
Aliases:
Accepted values: Primary, Secondary, None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### MilestonePSTools.VmsCameraStreamConfig

## NOTES

## RELATED LINKS
