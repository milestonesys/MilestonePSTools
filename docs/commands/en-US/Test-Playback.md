---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Test-Playback/
schema: 2.0.0
---

# Test-Playback

## SYNOPSIS

Tests whether the recording server has recordings at, before, or after the given DateTime.

## SYNTAX

```
Test-Playback [-Camera <Camera>] [-CameraId <Guid>] [-Timestamp <DateTime>] [-Mode <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The `Test-Playback` cmdlet tests whether the recording server has recordings at, before, or after the given DateTime.

Recordings in a Milestone XProtect VMS are stored with UTC timestamps, so the provided DateTime object will be converted
to UTC if the Kind property on the specified timestamp is either "Local" or "Unspecified".

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsCamera | Where-Object { ($_ | Test-Playback -Timestamp (Get-Date).AddDays(-30) -Mode Reverse) -eq $false }
```

Returns a list of cameras without recordings older than 30 days.

### Example 2

```powershell
Get-VmsCamera | Where-Object { $false -eq ($_ | Test-Playback -Mode Any -Timestamp (Get-Date)) }
```

Returns a list of cameras without any available recordings.

## PARAMETERS

### -Camera
Specifies a camera object as is returned by `Get-VmsCamera`

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
Specifies the ID of a camera object. Scripts can often be optimized to retrieve device IDs using a less-expensive method than `Get-VmsCamera`
such as `Get-VmsVideoOSItem`.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Mode
Specifies the mode for the underlying MIP SDK `GoToWithResult()` method call. See the related links for more information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Forward, Reverse, Any

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timestamp
Specifies a DateTime value representing the point in time to check for recordings in the media database. DateTime objects
will be automatically converted to UTC timestamps by calling the `.ToUniversalTime()` method, as all recordings are stored
with UTC timestamps.

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

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS

[VideoOS.Platform.Data.RawVideoSource.GoToWithResult()](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/class_video_o_s_1_1_platform_1_1_data_1_1_raw_video_source.html%23ab2f2ee15190d0bc8fa1ab7c16700b79d)

