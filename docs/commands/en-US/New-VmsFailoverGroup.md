---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsFailoverGroup/
schema: 2.0.0
---

# New-VmsFailoverGroup

## SYNOPSIS

Creates a new failover group in the current Milestone XProtect VMS site.

## SYNTAX

```
New-VmsFailoverGroup [-Name] <String> [-Description <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `New-VmsFailoverGroup` cmdlet creates a new failover group which can contain
one or more failover recording servers.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1

```powershell
Connect-Vms -ShowDialog -AcceptEula

New-VmsFailoverGroup -Name 'FO Group 1' -Description 'First failover group'
New-VmsFailoverGroup -Name 'FO Group 2' -Description 'Second failover group'
```

Prompts user to login to a Milestone VMS, then creates two failover groups.

## PARAMETERS

### -Description
An optional description for the new failover group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
A unique name for the new failover group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.FailoverGroup

## NOTES

## RELATED LINKS
