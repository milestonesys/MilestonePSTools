---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsLprMatchList/
schema: 2.0.0
---

# Remove-VmsLprMatchList

## SYNOPSIS
Removes an existing LPR match list.

## SYNTAX

### InputObject (Default)
```
Remove-VmsLprMatchList -InputObject <LprMatchList> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name
```
Remove-VmsLprMatchList [-Name] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsLprMatchList` cmdlet removes an existing LPR match list. Note that you cannot remove the default
"Unlisted license plates" LPR match list, so the cmdlet will automatically ignore attempts to delete it. This is why
you can run `Get-VmsLprMatchList | Remove-VmsLprMatchList` as shown in the examples without getting an error message.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Remove-VmsLprMatchList -Name 'Tenants' -WhatIf
```

Removes the LPR match list named "Tenants" if the `-WhatIf` switch is removed.

## PARAMETERS

### -InputObject
Specifies an LPR match lists as returned by `Get-VmsLprMatchList`.

```yaml
Type: LprMatchList
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies the name of an LPR match list, without support for wildcards.

```yaml
Type: String
Parameter Sets: Name
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

### VideoOS.Platform.ConfigurationItems.LprMatchList

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
