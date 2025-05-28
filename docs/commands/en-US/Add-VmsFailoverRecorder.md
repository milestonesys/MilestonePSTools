---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsFailoverRecorder/
schema: 2.0.0
---

# Add-VmsFailoverRecorder

## SYNOPSIS
Adds a failover recording server to an existing failover group.

## SYNTAX

```
Add-VmsFailoverRecorder -FailoverGroup <FailoverGroup> [-FailoverRecorder] <FailoverRecorder[]>
 [-Position <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Add-VmsFailoverRecorder` cmdlet adds a failover recording server to an
existing failover group. An unassigned failover recording server can be moved
into a group, and a failover recording server assigned to a group can be
assigned to a different failover group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1
```powershell
$failovers = Get-VmsFailoverRecorder -Unassigned
$failoverGroup = Get-VmsFailoverGroup -Name 'Failover Group 1'
$failovers | Foreach-Object { $failoverGroup | Add-VmsFailoverRecorder -FailoverRecorder $_ -Verbose }
```

This example retrieves all failover recording servers that have not been
assigned to a failover group, and have not been assigned as hot-standby failover
servers for any one recording server. It then adds all unassigned failover
recording servers to the failover group named "Failover Group 1".

## PARAMETERS

### -FailoverGroup
Specifies an existing failover group. The value can be supplied as a
FailoverGroup object, or the name of a failover group.

```yaml
Type: FailoverGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FailoverRecorder
Specifies an existing failover recording server. The value can be supplied as a
FailoverRecorder object, or the name of a failover recording server.

```yaml
Type: FailoverRecorder[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Position
Specifies the position the failover recording server should have. The value
starts at zero, which represents the first failover recording server in a group
that should assume the role of a failed recording server.

```yaml
Type: Int32
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
