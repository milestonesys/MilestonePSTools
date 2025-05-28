---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsClientProfile/
schema: 2.0.0
---

# Remove-VmsClientProfile

## SYNOPSIS
Removes an existing smart client profile.

## SYNTAX

```
Remove-VmsClientProfile [-ClientProfile] <ClientProfile[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsClientProfile` cmdlet removes an existing smart client profile. If
the profile is assigned as the default smart client profile for any roles, those
roles will be updated to use the default smart client profile automatically.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile -Verbose -WhatIf
```

Removes all smart client profiles except for the default client profile. To use
this example, remove the `WhatIf` switch.

## PARAMETERS

### -ClientProfile
Specifies a smart client profile. The value can be either a ClientProfile object
as returned by Get-VmsClientProfile, or it can be the name of an existing
client profile.

```yaml
Type: ClientProfile[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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

### VideoOS.Platform.ConfigurationItems.ClientProfile[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
