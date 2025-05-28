---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsLprMatchListEntry/
schema: 2.0.0
---

# Remove-VmsLprMatchListEntry

## SYNOPSIS
Removes one or more registration numbers from an LPR match list.

## SYNTAX

### InputObject (Default)
```
Remove-VmsLprMatchListEntry -InputObject <LprMatchList> -RegistrationNumber <String[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Name
```
Remove-VmsLprMatchListEntry [-Name] <String> -RegistrationNumber <String[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsLprMatchListEntry` cmdlet removes one or more registration numbers from an LPR match list.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsLprMatchList Tenants | Remove-VmsLprMatchListEntry -RegistrationNumber B865309
```

Removes the registration number "B865309" from the LPR match list named "Tenants".

## PARAMETERS

### -InputObject
Specifies an `LprMatchList` object as returned by `Get-VmsLprMatchList`.

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
Specifies the name of an existing LPR match list.

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

### -RegistrationNumber
Specifies a license plate registration number.

```yaml
Type: String[]
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: Name
Aliases:

Required: True
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

### VideoOS.Platform.ConfigurationItems.LprMatchList

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
