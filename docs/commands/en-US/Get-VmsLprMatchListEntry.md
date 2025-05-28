---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLprMatchListEntry/
schema: 2.0.0
---

# Get-VmsLprMatchListEntry

## SYNOPSIS
Get matching registration numbers from one or more match lists.

## SYNTAX

### InputObject (Default)
```
Get-VmsLprMatchListEntry -InputObject <LprMatchList[]> [-RegistrationNumber <String>] [<CommonParameters>]
```

### Name
```
Get-VmsLprMatchListEntry [[-Name] <String>] [-RegistrationNumber <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsLprMatchListEntry` cmdlet gets matching registration numbers from one or more match lists. If the match list
has custom fields, the custom fields will be included along with the registration number(s).

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsMatchList | Get-VmsLprMatchListEntry
```

Get all registration numbers from all match lists. Note that when PowerShell displays these records in the terminal,
you may not see all custom fields unless the same custom field names are present in all match lists. However, each
entry object returned will always have all the custom field properties attached.

### Example 2

```powershell
Get-VmsMatchList -Name Tenants | Get-VmsLprMatchListEntry
```

Get all the match list entries for the list named "Tenants".

### Example 3

```powershell
Get-VmsMatchList -Name Parking* | ForEach-Object {
    $_ | Get-VmsLprMatchListEntry | Export-Csv ".\MatchList - $($_.Name).csv"
}
```

Get all the match list entries from all match lists beginning with the word "Parking" and export each of them to their
own CSV file along with their custom fields if present.

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

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RegistrationNumber
Specifies a license plate registration number.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList[]

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
