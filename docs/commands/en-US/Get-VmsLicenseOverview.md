---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLicenseOverview/
schema: 2.0.0
---

# Get-VmsLicenseOverview

## SYNOPSIS

Gets a license overview of the connected site.

## SYNTAX

```
Get-VmsLicenseOverview [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsLicenseOverview` cmdlet gets an overview of overall activations on the SLC. This is
particularly useful if the SLC is being used in multiple systems (e.g. in a federated)
environment. The default output is similar to what the Management Client shows in the License
Information section under 'License Overview - All sites'.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1

```powershell
Get-VmsLicenseOverview
```

```Output
LicenseType                    Activated
-----------                    ---------
Device License                 369 out of 6000
Milestone Interconnect Camera  42 out of 6000
XPAC                           70 out of 5000
XPIM                           0 out of 1
XPT                            4 out of 50
XPLPR-VideoSourceLicense       8 out of 20
XPLPR-CountryModuleLicense     15 out of 20
```

Returns the License Overview for all sites.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseOverviewAllChildItem

## NOTES

## RELATED LINKS
