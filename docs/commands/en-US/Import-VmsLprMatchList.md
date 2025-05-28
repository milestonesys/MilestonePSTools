---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsLprMatchList/
schema: 2.0.0
---

# Import-VmsLprMatchList

## SYNOPSIS
Create or update LPR match lists by importing data from a CSV file.

## SYNTAX

### Path
```
Import-VmsLprMatchList [-Path] <String[]> [-Append] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath
```
Import-VmsLprMatchList -LiteralPath <String[]> [-Append] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Import-VmsLprMatchList` cmdlet creates or updates LPR match lists by importing data from a CSV file. If a match
list doesn't exist, it will be created, and if the `-Append` switch is used, the registration number entries will be
added or updated. When `-Append` is omitted, all records in existing match lists will be removed and replaced by the
values in the CSV file.

The minimum requirements for your CSV file are that it includes a header with the columns "MatchList", and
"RegistrationNumber". If any other columns are present, they will be interpreted as "custom fields" and imported
accordingly.

The column names are not case sensitive, and the order of the columns is not important.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
# Export all Parking* match lists to CSV files
Get-VmsMatchList -Name Parking* | ForEach-Object {
    $_ | Get-VmsLprMatchListEntry | Export-Csv ".\MatchList - $($_.Name).csv"
}

# Remove all Parking* match lists
Get-VmsMatchList -Name Parking* | Remove-VmsMatchList

#Re-import all Parking* match lists with all their original registration numbers and custom fields
Import-VmsLprMatchList -Path .\MatchList*.csv
```

The example demonstrates how you can both _export_ all LPR match lists to CSV file, and how you can use the exact same
output from `Get-VmsLprMatchListEntry` to import data back in to the same VMS or a different VMS.

## PARAMETERS

### -Append
Specifies that registration numbers should be added to whatever records are already present in the LPR match list(s). If
a registration number already exists, any custom fields will be updated based on the values provided in the CSV file.

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

### -LiteralPath
Specifies a path to one or more CSV files. The value of LiteralPath is used exactly as it's typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell PowerShell to not interpret any characters as escape sequences.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies a path to one or more CSV files. Wildcards are accepted. The default location is the current directory (`.`).

```yaml
Type: String[]
Parameter Sets: Path
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

### System.String[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
