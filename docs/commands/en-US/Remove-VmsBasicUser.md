---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsBasicUser/
schema: 2.0.0
---

# Remove-VmsBasicUser

## SYNOPSIS
Removes the specified basic user(s).

## SYNTAX

```
Remove-VmsBasicUser [-InputObject] <BasicUser[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsBasicUser` cmdlet can be used to remove Milestone, or external
basic users from the VMS. Note that an external user will be recreated on their
next login to the VMS if one or more registered claims in the user's token match
a claim name/value pairs in a role.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsBasicUser -External | Remove-VmsBasicUser
```

Removes all basic user entries representing users from an external login provider.

### Example 2
```powershell
Get-VmsBasicUser | Where-Object Name -like '*Houston*' | Remove-VmsBasicUser
```

Removes all basic user entries where the user name contains the case-insensitive
string 'Houston'.

## PARAMETERS

### -InputObject
Specifies one or more basic user objects as returned by the `Get-VmsBasicUser` cmdlet.

```yaml
Type: BasicUser[]
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

### VideoOS.Platform.ConfigurationItems.BasicUser[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
