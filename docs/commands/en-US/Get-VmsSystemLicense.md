---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsSystemLicense/
schema: 2.0.0
---

# Get-VmsSystemLicense

## SYNOPSIS
Gets a SystemLicense object representing the licensed product for the current
site and the feature flags for licensed features.

## SYNTAX

```
Get-VmsSystemLicense [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsSystemLicense` cmdlet gets a SystemLicense object representing the
licensed product for the current site and the feature flags for licensed features.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsSystemLicense
```

Returns a SystemLicense object representing the license for the current site.

### Example 2
```powershell
Get-VmsSystemLicense | Select-Object -ExpandProperty FeatureFlags
```

Returns a list of feature flags representing licensed and available features.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.License.SystemLicense

## NOTES

## RELATED LINKS
