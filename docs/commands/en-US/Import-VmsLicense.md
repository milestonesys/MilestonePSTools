---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsLicense/
schema: 2.0.0
---

# Import-VmsLicense

## SYNOPSIS

Imports a Milestone XProtect VMS initial license file or activated license file.

## SYNTAX

```
Import-VmsLicense [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Imports a Milestone XProtect VMS initial license file or activated license file.
This function
cannot be used to change to a different software license code.
For that, you must use
Set-VmsLicense instead.

You will typically use this function in tandem with Export-VmsLicenseRequest.
The expected
workflow would be:

1.
Export a license request file from the VMS because it doesn't have an internet connection.
2.
Take the license request file to an internet-connected PC to perform a manual license activation
    on My Milestone and download the activated license file.
3.
Copy the activated license file to the VMS server or network, and import the activated license file.

Alternatively, you might need to import a new "Initial license file" in order to enable a new
licensed feature before you can perform license activation.
In that case you would import the
initial license file, export a license request, activate the license request and import the
activated license file.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### EXAMPLE 1

```powershell
Import-VmsLicense -Path C:\path\to\license.lic
```

Imports the license file 'license.lic' and if successful, returns updated license information properties.

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
