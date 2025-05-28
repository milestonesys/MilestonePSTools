---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRestrictedMedia/
schema: 2.0.0
---

# Get-VmsRestrictedMedia

## SYNOPSIS
Gets live and playback video restriction entries.

## SYNTAX

```
Get-VmsRestrictedMedia [-Live] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsRestrictedMedia` cmdlet gets live and playback video restriction entries. Playback restrictions are returned
by default, and live video restrictions are returned when the `-Live` switch is present and evaluates to `$true`.

When retrieving video playback restrictions, a `RestrictedMedia` object is returned which includes the following
properties: `Header`, `Description`, `StartTime`, `EndTime`, `DeviceIds`, `UserName`, `LastModified`, and `Id`.

When retrieving live video restrictions, a `RestrictedMediaLive` object is returned which includes the following
properties: `DeviceId`, `StartTime`, `UserName`, and `LastModified`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1

```powershell
Get-VmsRestrictedMedia
```

Get a list of all restricted video playback records.

### Example 2

```powershell
Get-VmsRestrictedMedia -Live
```

Get a list of all restricted video playback records.

### Example 3

```powershell
$camera = Select-Camera -SingleSelect
Get-VmsRestrictedMedia | Where-Object DeviceIds -contains $camera.Id
```

Get a list of all video playback restrictions including the ID of the selected camera, if any exist.

### Example 4

```powershell
$camera = Select-Camera -SingleSelect
Get-VmsRestrictedMedia -Live | Where-Object DeviceId -eq $camera.Id
```

Get the active live video restriction associated the selected camera, if one exists.

## PARAMETERS

### -Live

Return live video restrictions instead of playback video restrictions.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

### VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive

## NOTES

## RELATED LINKS
