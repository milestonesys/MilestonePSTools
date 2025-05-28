---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsLprMatchList/
schema: 2.0.0
---

# Set-VmsLprMatchList

## SYNOPSIS
Sets the basic name and trigger event properties for an LPR match list.

## SYNTAX

### InputObject (Default)
```
Set-VmsLprMatchList -InputObject <LprMatchList> [-NewName <String>] [-TriggerEvent <String[]>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name
```
Set-VmsLprMatchList [-Name] <String> [-NewName <String>] [-TriggerEvent <String[]>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsLprMatchList` sets the basic name and trigger event properties for an existing LPR match list.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsLprMatchList -Name Tenants | Set-VmsLprMatchList -NewName Occupants
```

Updates the LPR match list "Tenants" with the new name "Occupants".

## PARAMETERS

### -InputObject
Specifies an LPR match list as returned by `Get-VmsLprMatchList`.

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
Specifies the name of an existing LPR match list with support for wildcards.

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

### -NewName
Specifies a new name for the LPR match list.

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

### -PassThru
Specifies that the updated LPR match list should be returned.

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

### -TriggerEvent
Specifies one or more UserDefinedEvent or Output object paths.

```yaml
Type: String[]
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

### VideoOS.Platform.ConfigurationItems.LprMatchList

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
