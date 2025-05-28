---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsLicense/
schema: 2.0.0
---

# Set-VmsLicense

## SYNOPSIS

Sets the Milestone XProtect VMS software license code to a new software license code.

## SYNTAX

```
Set-VmsLicense [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Useful for changing the software license code.
You may do this when moving from a pilot license
to a production license, or when upgrading or downgrading the licensed VMS edition.

If you're importing a new "initial license file" for the same software license code, or importing
an activated software license file downloaded from My Milestone, it is recommended to use
Import-VmsLicense instead.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### EXAMPLE 1

```powershell
Set-VmsLicense -Path C:\path\to\license.lic
```

Invokes the ChangeLicense method in Configuration API to import license.lic.

## PARAMETERS

### -Path

Specifies the path to an existing license file on disk.
Typically this file has a .LIC extension.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseInformation

### VideoOS.Platform.ConfigurationItems.LicenseInformation

Support for license management in Milestone's MIP SDK / Configuration API was introduced in
version 2020 R2.
If the Management Server version is earlier than 2020 R2, this function
will not work.

## NOTES

## RELATED LINKS
