---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLprEvent/
schema: 2.0.0
---

# Get-VmsLprEvent

## SYNOPSIS
Get matching LPR detection event records.

## SYNTAX

```
Get-VmsLprEvent [-RegistrationNumber <String>] [-MatchList <String>] [-CameraId <Guid>] [-StartTime <DateTime>]
 [-EndTime <DateTime>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsLprEvent` cmdlet gets matching LPR detection event records. The search can be narrowed by providing a
registration number, the name of a match list, or a camera ID, along with a time range using the `StartTime` and
`EndTime` parameters.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$camera = Get-VmsCamera -Name 'Parking Entrance'
$camera | Get-VmsLprEvent -StartTime (Get-Date).AddDays(-30) -EndTime (Get-Date) -MatchList Tenants
```

This example retrieves the last 30-days of license plate detection events for registration numbers in the "Tenants"
match list where the plate was read from the camera named "Parking Entrance".

### Example 2
```powershell
$splat = @{
    StartTime = (Get-Date).AddDays(-90)
    EndTime   = Get-Date
    MatchList = 'Unlisted license plate'
}
Get-VmsLprEvent @splat | Select-Object Timestamp, ObjectValue, SourceName | Export-Csv .\lprevents.csv
```

This example retrieves the last 90-days of license plate detection events where the registration number is not a part
of any configured match list. From each event record, the timestamp, registration number (ObjectValue), and camera name
(SourceName) are selected and exported to a csv file.

### Example 3
```powershell
$splat = @{
    StartTime = (Get-Date).AddDays(-90)
    EndTime   = Get-Date
    MatchList = 'Unlisted license plate'
}
$properties = @(
    'Timestamp',
    @{n='RegistrationNumber'; e={$_.ObjectValue}},
    @{n='Camera';             e={$_.SourceName}},
    @{n='PlateStyle';         e={($_.ObjectData | ConvertFrom-Json).PlateStyleId}}
)
Get-VmsLprEvent @splat | Select-Object $properties | Export-Csv lprevents.csv
```

This example is similar to the previous example, but it uses "calculated properties" to rename a couple columns to
something more appropriate. It also adds the plate style identifier if available in JSON document stored in the
`ObjectData` property of the event record.

## PARAMETERS

### -CameraId
Specifies the ID of a camera used for license plate recognition.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases: Id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EndTime
Specifies the end of the time period to search.

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

### -MatchList
Specifies the name of an existing LPR match list.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Message

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RegistrationNumber
Specifies a license plate registration number.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ObjectValue, Plate

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
Specifies the beginning of the time period to search.

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

### System.Guid

## OUTPUTS

### VideoOS.Platform.Proxy.Alarm.EventLine

## NOTES

## RELATED LINKS
