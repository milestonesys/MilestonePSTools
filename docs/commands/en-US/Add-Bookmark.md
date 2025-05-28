---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-Bookmark/
schema: 2.0.0
---

# Add-Bookmark

## SYNOPSIS

Adds a new bookmark to the timeline for a given device.

## SYNTAX

```
Add-Bookmark [[-DeviceId] <Guid>] [-Timestamp] <DateTime> [[-MarginSeconds] <Int32>] [[-Reference] <String>]
 [[-Header] <String>] [[-Description] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Add-Bookmark cmdlet adds a new bookmark to the timeline for a given device.
The bookmark can later be found by time, name or description, and is represented by a visual marker in the timeline for the given device in playback within XProtect Smart Client and any other integration using the timeline UI component.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Add-Bookmark -DeviceId $id -Timestamp '2019-06-04 14:00:00'
```

Add a bookmark for device with a GUID ID value stored in the variable $id, using a local timestamp of 2PM on the 4th of June, 2019, based on the culture of the PowerShell session.

### EXAMPLE 2

```powershell
Add-Bookmark -DeviceId $id -Timestamp '2019-06-04 14:00:00Z'
```

Add a bookmark for device with a GUID ID value stored in the variable $id, using a UTC timestamp of 2PM UTC on the 4th of June, 2019

### EXAMPLE 3

```powershell
Get-VmsHardware | Get-VmsCamera | Where-Object Name -Like '*Elevator*' | ForEach-Object { Add-Bookmark -DeviceId $_.Id -Timestamp '2019-06-04 14:00:00' -Header 'Vandalism' }
```

Find all enabled cameras with the case-insensitive string 'Elevator' in the name, and
add a bookmark for those cameras at 2PM on June 4th, or 21:00 UTC if the
location where the script is executed has a UTC offset of -7.

## PARAMETERS

### -Description

Specifies the description of the bookmark.
It is helpful to supply a header or description to add context to the bookmark.
The default value is 'Created by MilestonePSTools'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Created by MilestonePSTools
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceId

GUID based identifier of the device for which the bookmark should be created.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header

Specifies the header, or title of the bookmark.
It is helpful to supply a header or description to add context to the bookmark.
The default value is 'Created \<timestamp\>'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Created 2021-08-18 23:10:32.236Z
Accept pipeline input: False
Accept wildcard characters: False
```

### -MarginSeconds

Specifies the time in seconds before, and after the value of Timestamp, which should be considered a part of this bookmark event.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Reference

Specifies a reference string for the bookmark.
The default value will be a string retrieved from the Management Server using the BookmarkGetNewReference() method which returns a string like 'no.016735'.
The value does not need to be unique.

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

### -Timestamp

Timestamp of the event which should be bookmarked.
Value can be a string, and it will be parsed into a DateTime object.
Default is the current time.

Note: The event will be stored with a UTC timestamp on the Management Server.
Supplying a DateTime string can be finicky - it is recommended to thoroughly test any scripts to ensure it results in a bookmark at the expected place in the timeline.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 8/18/2021 11:10:32 PM
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
