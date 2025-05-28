---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-Snapshot/
schema: 2.0.0
---

# Get-Snapshot

## SYNOPSIS

Gets live or recorded still images from a camera connected to a Milestone VMS.

## SYNTAX

### FromLive (Default)
```
Get-Snapshot [-Camera <Camera>] [[-CameraId] <Guid>] [-Live] [-Save] [[-Path] <String>] [[-FileName] <String>]
 [-LocalTimestamp] [-Width <Int32>] [-Height <Int32>] [-KeepAspectRatio] [-IncludeBlackBars] [-UseFriendlyName]
 [-LiftPrivacyMask] [-Quality <Int32>] [-LiveTimeoutMS <Int32>] [<CommonParameters>]
```

### FromPlayback
```
Get-Snapshot [-Camera <Camera>] [[-CameraId] <Guid>] [[-Timestamp] <DateTime>] [-EndTime <DateTime>]
 [-Interval <Double>] [[-Behavior] <String>] [-Save] [[-Path] <String>] [[-FileName] <String>]
 [-LocalTimestamp] [-Width <Int32>] [-Height <Int32>] [-KeepAspectRatio] [-IncludeBlackBars] [-UseFriendlyName]
 [-LiftPrivacyMask] [-Quality <Int32>] [-LiveTimeoutMS <Int32>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-Snapshot` cmdlet is used to retrieve a live still image, a recorded
still image, or a series of recorded images between two `[DateTime]` timestamps
on a given interval.

Currently these images are in JPEG format, and in a future update the output
format will be configurable.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$camera | Get-Snapshot -Live
```

Returns a [`VideoOS.Platform.Live.LiveSourceContent`](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/class_video_o_s_1_1_platform_1_1_live_1_1_live_source_content.html&tree=tree_search.html?search=livesourcecontent) object where the JPEG image is
defined as a byte array in the Contents property.

### Example 2

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$null = $camera | Get-Snapshot -Live -Save -Path c:\temp -UseFriendlyName
```

Saves a file to C:\temp\ in JPG format with the camera's display name followed
by a timestamp as the file name.

### Example 3

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$null = $camera | Get-Snapshot -Timestamp (Get-Date).AddHours(-1) -EndTime (Get-Date) -Interval 10 -Save -Path C:\snaps\ -LiftPrivacyMask -Quality 100
```

### Example 4

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$null = $camera | Get-Snapshot -Behavior GetBegin
```

Gets the oldest recorded image for a camera.

### Example 5

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$null = $camera | Get-Snapshot -Behavior GetEnd
```

Gets the most recent recorded image for a camera.

### Example 6

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$null = $camera | Get-Snapshot -Timestamp (Get-Date).AddDays(-1)
```

Gets a recorded image with a timestamp nearest to 24 hours ago.

## PARAMETERS

### -Behavior

Specifies whether to get the oldest, or newest recorded image available, or
whether to get the nearest image to the specified timestamp. The default
behavior is to get the nearest recorded image to the specified timestamp.

```yaml
Type: String
Parameter Sets: FromPlayback
Aliases:
Accepted values: GetBegin, GetEnd, GetNearest

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Camera

Specifies the camera from which to retrieve a snaphot.

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

Specifies the ID of a camera from which to retrieve a snapshot.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime

Specifies the end timestamp for retrieving many snapshots of recorded video
between two timestamps.

```yaml
Type: DateTime
Parameter Sets: FromPlayback
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName

Specifies the filename to use when saving a snapshot.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Height

When it is desired to scale the snapshot, this specifies the desired image
height.

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

### -IncludeBlackBars

Specifies whether the image should be centered on a black background resulting
in black bars when the resulting image resolution does not match the original
camera resolution.

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

### -Interval

Specifies an interval, in seconds, on which to retrieve snapshots from recorded
video between Timestamp and EndTime.

```yaml
Type: Double
Parameter Sets: FromPlayback
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeepAspectRatio

Specifies that the original image aspect ratio should be maintained when
resizing the snapshot.

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

### -LiftPrivacyMask

Specifies that the privacy mask, if present, should be lifted on the snapshot,
assuming the current user has permission to lift privacy masks.

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

### -Live

Specifies that the snapshots should come from the live stream instead of
recorded video.

```yaml
Type: SwitchParameter
Parameter Sets: FromLive
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiveTimeoutMS

Specifies the number of milliseconds to wait for a live snapshot image to
arrive. The default value is 2000ms or 2 seconds.

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

### -LocalTimestamp

Specifies that a local timestamp should be used in the file name instead of a
UTC timestamp.

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

### -Path

Specifies the folder to which snapshots should be saved.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quality

Specifies the image quality of the resulting JPEG as a percentage. The default
value is 75%.

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

### -Save

Specifies that the image should be saved to disk.

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

Specifies the timestamp from which the nearest snapshot should be retrieved from
recorded video.

```yaml
Type: DateTime
Parameter Sets: FromPlayback
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseFriendlyName

Specifies that the display name should be used in the filename of saved images.

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

### -Width

Specifies the desired image width for the resulting snapshot.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### VideoOS.Platform.Live.LiveSourceContent

### VideoOS.Platform.Data.JPEGData

## NOTES

## RELATED LINKS
