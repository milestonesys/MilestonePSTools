---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-Bookmark/
schema: 2.0.0
---

# Get-Bookmark

## SYNOPSIS

Gets one or more bookmarks based on the supplied parameters

## SYNTAX

```
Get-Bookmark [[-DeviceId] <Guid[]>] [[-StartTime] <DateTime>] [-EndTime <DateTime>] [-PageSize <Int32>]
 [-Users <String[]>] [-SearchText <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets all bookmarks matching the supplied parameters.
If there is any overlap between the timespan represented by the StartTime and EndTime parameters, and the timespan represented by the TimeBegin and TimeEnd properties of the Bookmarks themselves, the Bookmarks will be included in the results.
Since a Bookmark usually has a "Time Triggered" as well as a short timespan before and after the trigger time, this means your Bookmark search may return Bookmarks which have a "TimeTrigged" value which falls outside the bounds of the StartTime and EndTime parameters, but their TimeBegin or TimeEnd timestamps do fall within the specified time period.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Bookmark -DeviceId $id -StartTime (Get-Date).Date.ToUniversalTime()
```

Get all bookmarks for device with ID $id occurring any time during the current day.

### EXAMPLE 2

```powershell
Get-Bookmark -StartTime ([DateTime]::UtcNow).AddHours(-2)
```

Get all bookmarks for any device where the bookmark time is in the last two hours.

### EXAMPLE 3

```powershell
Get-Bookmark -StartTime (Get-Date).Date.ToUniversalTime().AddDays(-1) -EndTime (Get-Date).Date.ToUniversalTime()
```

Get all bookmarks for the previous day.

### EXAMPLE 4

```powershell
Get-Bookmark -StartTime ([DateTime]::MinValue) -SearchText "Auto"
```

Get all bookmarks with the word "Auto" occuring in the Header or Description properties.

## PARAMETERS

### -DeviceId

Optional device ID to filter the results on.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime

UTC time representing the end of the bookmark search period.
Default is "now".

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 8/18/2021 11:10:32 PM
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

A larger page size may result in a longer wait for the first set of results, but overall shorter processing time.
Default is 1000.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchText

Search the header or description for the bookmarks in the defined time period for a keyword or phrase.

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

### -StartTime

UTC time representing the start of the bookmark search period.
Default is 24 hours ago.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 8/17/2021 11:10:32 PM
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users

List of users to filter the search on.
Users are typically searched using the format domain\username.

```yaml
Type: String[]
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

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.Bookmark

## NOTES

## RELATED LINKS
