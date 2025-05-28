---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsFailoverGroup/
schema: 2.0.0
---

# Remove-VmsFailoverGroup

## SYNOPSIS

Removes an existing failover group from the current Milestone XProtect VMS site.

## SYNTAX

```
Remove-VmsFailoverGroup [-FailoverGroup] <FailoverGroup> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Remove-VmsFailoverGroup` cmdlet removes an existing failover group,
which can each contain one or more failover recording servers.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1

```powershell
Connect-Vms -ShowDialog -AcceptEula

Get-VmsFailoverGroup | Select-Object -First 1 | Remove-VmsFailoverGroup -WhatIf
```

Prompts user to login to a Milestone VMS, then attempts to remove the first
failover group returned by `Get-VmsFailoverGroup` but does not actually remove
the failover group thanks to the `-WhatIf` switch.

## PARAMETERS

### -FailoverGroup

Specifies a FailoverGroup object returned by the `Get-VmsFailoverGroup` cmdlet.

```yaml
Type: FailoverGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Specifies that any members of the failover group should be removed from the group and then the group should be deleted.

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

### VideoOS.Platform.ConfigurationItems.FailoverGroup

## OUTPUTS

### None

## NOTES

## RELATED LINKS
