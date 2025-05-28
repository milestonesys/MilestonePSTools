---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsFailoverRecorder/
schema: 2.0.0
---

# Remove-VmsFailoverRecorder

## SYNOPSIS
Removes a failover recorder from the specified failover group.

## SYNTAX

```
Remove-VmsFailoverRecorder -FailoverGroup <FailoverGroup> [-FailoverRecorder] <FailoverRecorder> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsFailoverRecorder` cmdlet removes a failover recorder from the specified failover group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1
```powershell
$group = Get-VmsFailoverGroup -Name 'Failover Group 1'
$failover = $group | Get-VmsFailoverRecorder | Select-Object -First 1
$group | Remove-VmsFailoverRecorder -FailoverRecorder $failover -Verbose -WhatIf
```

In this example we retrieve Failover Group 1, and one failover recorder in the group, then remove the failover recorder
from the group - or at least it _would_ be removed if the `-WhatIf` switch is removed.

## PARAMETERS

### -FailoverGroup
Specifies a FailoverGroup object. Use `Get-VmsFailoverGroup` to retrieve a failover group.

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
Specifies a FailoverRecorder object, or the display name of a failover recorder in the group.

```yaml
Type: FailoverRecorder
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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
