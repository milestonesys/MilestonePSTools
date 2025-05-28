---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Stop-VmsRestrictedLiveMode/
schema: 2.0.0
---

# Stop-VmsRestrictedLiveMode

## SYNOPSIS
Stops one or more live media restrictions and converts them into a media playback restriction.

## SYNTAX

```
Stop-VmsRestrictedLiveMode [-DeviceId] <Guid[]> [-StartTime] <DateTime> [[-EndTime] <DateTime>]
 [-Header] <String> [[-Description] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Stop-VmsRestrictedLiveMode` cmdlet stops one or more live media restrictions and converts them into a media
playback restriction.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1
```powershell
Get-VmsRestrictedMedia -Live | Stop-VmsRestrictedLiveMode -Header 'Accident' -EndTime (Get-Date)
```

In this example, all current live media restrictions are combined into one media playback restriction. The result is
that there will no longer be _any_ live media restrictions, and there will be a new _playback restriction_ with the
header "Accident" with an end time of "now" and the start time will automatically be set to the `StartTime` value of the
last live media restriction returned by `Get-VmsRestrictedMedia -Live`.

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
Specifies one or more devices with live media restrictions to include in a new playback media restriction.

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

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header
Specifies the title of the new media playback restriction.

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

### -StartTime
Specifies the start of the period for which the new media playback restriction should apply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid[]

### System.DateTime

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

## NOTES

## RELATED LINKS
