---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsRestrictedMedia/
schema: 2.0.0
---

# Set-VmsRestrictedMedia

## SYNOPSIS
Updates properties of an existing media restriction.

## SYNTAX

```
Set-VmsRestrictedMedia [-InputObject] <RestrictedMedia> [[-IncludeDeviceId] <Guid[]>]
 [[-ExcludeDeviceId] <Guid[]>] [[-Header] <String>] [[-Description] <String>] [[-StartTime] <DateTime>]
 [[-EndTime] <DateTime>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsRestrictedMedia` cmdlet updates properties of an existing media restriction. It is used to change the header
(title), description, start and end timestamps, and add or remove devices to the media restriction.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1
```powershell
$restriction = Get-VmsRestrictedMedia | Select-Object -First 1

$splat = @{
    Header      = 'New header value'
    Description = 'Updated description'
    StartTime   = $restriction.StartTime.AddHours(-1)
    EndTime     = $restriction.StartTime.AddHours(1)
    PassThru    = $true
}
$restriction | Set-VmsRestrictedMedia @splat
```

This example updates the first discovered media restriction with a new header, and description. It also expands the
restricted period by one hour on both ends of the existing restricted time period.

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

### -EndTime
Specifies the end of the period for which the media retriction should apply.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDeviceId
Specifies one or more devices, by Id, to exclude from the specified media restriction.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
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

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDeviceId
Specifies one or more devices, by Id, to include in the specified media restriction.

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

### -InputObject
Specifies a media restriction object as returned by `Get-VmsRestrictedMedia`.

```yaml
Type: RestrictedMedia
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru
Return the updated media restriction to the pipeline.

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

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

## NOTES

## RELATED LINKS
