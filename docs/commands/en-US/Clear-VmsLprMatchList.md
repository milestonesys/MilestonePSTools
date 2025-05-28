---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Clear-VmsLprMatchList/
schema: 2.0.0
---

# Clear-VmsLprMatchList

## SYNOPSIS
Clear all registration numbers from one or more match lists.

## SYNTAX

### Name (Default)
```
Clear-VmsLprMatchList [-Name] <String> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject
```
Clear-VmsLprMatchList -InputObject <LprMatchList[]> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Clear-VmsLprMatchList` cmdlet clears all registration numbers from one or more match lists.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Clear-VmsMatchList -Name Tenants
```

This example removes all entries from a match list named "Tenants". Because the impact of the command is considered
"High", you will normally be asked for confirmation before the action is performed.

### Example 2
```powershell
Clear-VmsMatchList -Name Tenants -Confirm:$false
```

This example removes all entries from a match list named "Tenants". The presence of `-Confirm:$false` tells PowerShell
you do not want to manually confirm. This is how you would use the command in an unattended script.

## PARAMETERS

### -InputObject
Specifies an `LprMatchList` object as returned by `Get-VmsLprMatchList`.

```yaml
Type: LprMatchList[]
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies the name of an existing LPR match list.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the match list should be returned after the registration number entries are cleared.

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

### VideoOS.Platform.ConfigurationItems.LprMatchList[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
