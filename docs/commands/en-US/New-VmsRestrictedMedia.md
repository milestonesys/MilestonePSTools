---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsRestrictedMedia/
schema: 2.0.0
---

# New-VmsRestrictedMedia

## SYNOPSIS
Create a new video playback restriction for one or more devices.

## SYNTAX

```
New-VmsRestrictedMedia [-DeviceId] <Guid[]> [-StartTime] <DateTime> [-EndTime] <DateTime> [-Header] <String>
 [[-Description] <String>] [-IgnoreRelatedDevices] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsRestrictedMedia` cmdlet creates a new video playback restriction for one or more devices.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1
```powershell
$cameras = Select-Camera -AllowFolders -AllowServers -RemoveDuplicates

$splat = @{
    Header      = 'Example video playback restriction'
    Description = 'Description of video playback restriction'
    StartTime   = (Get-Date).Date
    EndTime     = Get-Date
}
$cameras | New-VmsRestrictedMedia @splat
```

This example prompts the user to select one or more cameras, with the option to select an entire camera group or
recording server. Then a playback restriction is created from midnight of the current day until the current time for the
selected cameras and their related devices (microphones, speakers, and metadata).

PowerShell's splatting feature is used in this example to reduce the line width, and the camera Id's are piped to the
function instead of using the `DeviceId` named property directly.

### Example 2
```powershell
$cameras = Select-Camera -AllowFolders -AllowServers -RemoveDuplicates
$start = (Get-Date).AddHours(-1)
$end = Get-Date
$cameras | New-VmsRestrictedMedia -Header 'Example' -StartTime $start -EndTime $end
```

This example prompts the user to select one or more cameras, with the option to select an entire camera group or
recording server. Then a playback restriction is created for the past hour for the selected cameras, and their related
devices (microphones, speakers, and metadata). In this example, the parameters are provided in-line, and the optional
description is omitted.

### Example 3
```powershell
$cameras = Select-Camera -AllowFolders -AllowServers -RemoveDuplicates
$start = (Get-Date).AddHours(-1)
$end = Get-Date
$cameras | New-VmsRestrictedMedia -Header 'Example' -StartTime $start -EndTime $end -IgnoreRelatedDevices
```

This example is identical to the previous example, except the related devices (microphones, speakers, and metadata) are
excluded from the restriction.

## PARAMETERS

### -Description

Specifies an optional description for the video playback restriction.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceId
Specifies one or more devices to be included in the media restriction by Id.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EndTime
Specifies the end of the period for which the media restriction should apply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header
Specifies the title of the media restriction.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreRelatedDevices
Specifies that the related devices (microphones, speakers, and metadata) should not be included in the media restriction.

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

### -StartTime
Specifies the start of the period for which the media restriction should apply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid[]

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

## NOTES

## RELATED LINKS
