---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-BankTable/
schema: 2.0.0
---

# Get-BankTable

## SYNOPSIS

Enumerates Path for media database tables created by a Recording Server.

## SYNTAX

```
Get-BankTable [[-Path] <String>] [[-DeviceId] <String[]>] [[-StartTime] <DateTime>] [[-EndTime] <DateTime>]
 [<CommonParameters>]
```

## DESCRIPTION

The records returned by this function must represent media database folders with names matching the
format used by Milestone.
The format expected is GUID_TAG_TIMESTAMP where GUID is the id of a
device, TAG is a string like LOCAL or ARCHIVE, and TIMESTAMP is a local timestamp in the format
yyyy-MM-dd_HH-mm-ss.

Each record returned by this function will have a DeviceId property of type \[Guid\], an EndTime property
of type \[DateTime\] which will be a local timestamp representing the approximate time that folder was last
added to, a Tag property representing the LOCAL or ARCHIVE string value describing the type of table,
and a Path property with the full path to that folder on the file system.

This function does not rely on cache.xml or archives_cache.xml in any way.
As such, it can be used on
a system with an invalid or missing cache.
However, the accuracy of the timestamps is unreliable because
they are based on the names of the folders on the filesystem which represent the time the Recording Server
renamed that folder when it was converted from a live media database table to a local archive table.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Get-BankTable C:\MediaDatabase\4344cd14-0b12-4c18-8677-5d263c140af4 -DeviceId "94275fef-b977-43f6-bf78-210c615b2967" | Copy-Item -Destination C:\Temp -Container -Recurse -Force
```

Copy all media database tables for device with ID 94275fef-b977-43f6-bf78-210c615b2967 to C:\Temp

## PARAMETERS

### -DeviceId

The GUID of one or more devices you want to retrieve tables for.
If you omit this property, all tables
for all devices will be returned.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime

The local DateTime indicating the last records to be retrieved from the media database.
Since entire folders, each
containing approximately one hour of video, will be retrieved, you could end up with video up to one hour newer than
requested.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: [DateTime]::MaxValue.AddHours(-1)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the media database.
This must be the path to the folder containing the media database tables.
For example, C:\MediaDatabase\4344cd14-0b12-4c18-8677-5d263c140af4 is the full path to the default "Local default"
storage path.
The ID for yours will be different, and if you need to find the ID, you can hold CTRL and click on
the Storage tab of the Recording Server in Management Client.
Then hover over the storage configuration and you
will see the ID displayed in the tooltip.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime

The local DateTime indicating the oldest records to be retrieved from the media database.
Since entire folders, each
containing approximately one hour of video, will be retrieved, you could end up with video up to one hour older than
requested.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: [DateTime]::MinValue
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
