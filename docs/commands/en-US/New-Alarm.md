---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-Alarm/
schema: 2.0.0
---

# New-Alarm

## SYNOPSIS

Generates a partially filled Alarm object to be sent using Send-Alarm.

## SYNTAX

```
New-Alarm -Message <String> [-Description <String>] [-CustomTag <String>] [-Source <Item>]
 [-RelatedItems <Item[]>] [-Vendor <String>] [-Timestamp <DateTime>] [<CommonParameters>]
```

## DESCRIPTION

The partially completed Alarm object can be modified as needed before sending to the Event Server with the Send-Alarm cmdlet.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$cameraItem = Get-VmsCamera -Id '948aa6a2-9a46-4c4c-8279-af0485428d75' | Get-VmsVideoOSItem -Kind Camera
$alarm = New-Alarm -Message "Important Alarm Message" -Source $cameraItem
$alarm | Send-Alarm
```

Retrieves the Item object for Camera with the given Id and creates an Alarm with this camera as the source.

The Alarm object is then sent to the Event Server which generates a new alarm.

## PARAMETERS

### -CustomTag

Specifies the Alarm.EventHeader.CustomTag value which could be used later for searching or filtering in calls to Get-AlarmLines.

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

### -Description

Specifies the detailed description of the alarm.
This appears in the XProtect Smart Client under the alarm's Instructions field.

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

### -Message

Specifies the alarm message

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: MilestonePSTools Default Alarm Message
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelatedItems

Specifies one or more items such as cameras as references or related items so that video from all related cameras is associated with the alarm.

To get an Item object, try passing a Camera or Input object for example into the Get-PlatformItem cmdlet.

Alternatively you can construct your own Item.
All you need is the FQID property to contain a ServerId, ObjectId and Kind.

```yaml
Type: Item[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

Specifies an alarm source to automatically fill in the Alarm.EventHeader.Source property.

To get an Item object, try passing a Camera or Input object for example into the Get-VmsVideoOSItem cmdlet.

Alternatively you can construct your own Item.
All you need is the FQID property to contain a ServerId, ObjectId and Kind.

```yaml
Type: Item
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timestamp

Specifies the timestamp associated with the alarm.

Default is DateTime.UtcNow.
All DateTimes will be converted to UTC time automatically if needed.

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

### -Vendor

Specifies a vendor name as the source for the alarm.
Default is MilestonePSTools.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: MilestonePSTools
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Data.Alarm

## NOTES

## RELATED LINKS
