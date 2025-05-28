---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsFailoverGroup/
schema: 2.0.0
---

# Set-VmsFailoverGroup

## SYNOPSIS
Updates the settings of the specifies failover group.

## SYNTAX

```
Set-VmsFailoverGroup -FailoverGroup <FailoverGroup> [-Name] <String> [-Description <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsFailoverGroup` cmdlet updates the settings of the specifies failover group. Only name and description properties
are present on failover groups at this time.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1
```powershell
Get-VmsFailoverGroup | Set-VmsFailoverGroup -Description "Contact helpdesk@vms.local before making any changes to failover groups."
```

This example adds a notice to the failover group description informing administrators not to change failover settings
without talking to someone first.

## PARAMETERS

### -Description
Specifies a new description for the failover group.

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

### -FailoverGroup
Specifies a failover group object as is returned by `Get-VmsFailoverGroup`

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

### -Name
Specifies a new name for the failover group.

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

### -PassThru
Specifies that the updated failover group should be returned to the pipeline.

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

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.FailoverGroup

## NOTES

## RELATED LINKS
