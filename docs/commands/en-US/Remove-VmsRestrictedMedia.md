---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsRestrictedMedia/
schema: 2.0.0
---

# Remove-VmsRestrictedMedia

## SYNOPSIS
Removes an existing live, or recorded media restriction.

## SYNTAX

### RestrictedMedia
```
Remove-VmsRestrictedMedia -RestrictedMedia <RestrictedMedia> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RestrictedMediaLive
```
Remove-VmsRestrictedMedia -RestrictedMediaLive <RestrictedMediaLive> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### DeviceId
```
Remove-VmsRestrictedMedia -DeviceId <Guid[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsRestrictedMedia` cmdlet removes an existing live, or recorded media restriction.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1
```powershell
Get-VmsRestrictedMedia | Remove-VmsRestrictedMedia
```

Removes (deletes) all media playback restrictions. Since `Get-VmsRestrictedMedia` is used here without the `-Live`
switch, only the playback restrictions are removed. Any live restrictions will remain in place. Since the
`ConfirmImpact` attribute on this cmdlet is set to `High`, you will be prompted for confirmation before any restrictions
are removed.

### Example 2
```powershell
Get-VmsRestrictedMedia -Live | Remove-VmsRestrictedMedia
```

Removes (deletes) all live media restrictions. All playback restrictions will remain in place.

### Example 3
```powershell
Get-VmsRestrictedMedia | Where-Object Header -match 'Accident' | Remove-VmsRestrictedMedia
```

Removes (deletes) all playback media restrictions with the word 'accident' in the header.

## PARAMETERS

### -DeviceId
Specifies one or more devices, by Id, for which live media restrictions should be removed.

```yaml
Type: Guid[]
Parameter Sets: DeviceId
Aliases: Id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RestrictedMedia
Specifies a media playback restriction object as returned by `Get-VmsRestrictedMedia`.

```yaml
Type: RestrictedMedia
Parameter Sets: RestrictedMedia
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RestrictedMediaLive
Specifies a live media restriction object as returned by `Get-VmsRestrictedMedia -Live`.

```yaml
Type: RestrictedMediaLive
Parameter Sets: RestrictedMediaLive
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMedia

### VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive

### System.Guid[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
