---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLprMatchList/
schema: 2.0.0
---

# Get-VmsLprMatchList

## SYNOPSIS
Gets the matching LPR match list(s).

## SYNTAX

```
Get-VmsLprMatchList [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsLprMatchList` cmdlet gets all LPR match lists including the default "Unlisted license plate" match list,
or it gets the match list(s) matching the value provided for the `Name` parameter.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsMatchList -Name Tenants
```

Get the LPR match list named "Tenants".

### Example 2
```powershell
Get-VmsMatchList -Name Parking*
```

Get all LPR match lists with a name beginning with "Parking".

## PARAMETERS

### -Name
Specifies the name of an existing LPR match list with support for wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
