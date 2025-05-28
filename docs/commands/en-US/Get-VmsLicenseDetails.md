---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLicenseDetails/
schema: 2.0.0
---

# Get-VmsLicenseDetails

## SYNOPSIS

Gets the license details of the connected site.

## SYNTAX

```
Get-VmsLicenseDetails [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsLicenseDetails` cmdlet returns the license details information of the connected site. The
information returned shows the License Type, how many are activated, how many changes without
activation are remaining, how many are in grace period, how many have an expired grace period,
and how many are without activation.

The information returned is similar to what the Management Client shows in the License Information
section under License Details.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1

```powershell
Get-VmsLicenseDetails
```

```Output
LicenseType                    Activated    InGrace      GraceExpired NotLicensed  ChangesWithoutActivation
-----------                    ---------    -------      ------------ -----------  ------------------------
Device License                 11           0            0            0            0 out of 10
Milestone Interconnect Camera  1            0            0            0            N/A
MIPSDK-ServerConnectionLicense 0            0            0            0            N/A
MIPSDK-SiteLicense             0            0            1            0            N/A
XPAC                           0            0            0            0            N/A
XPIM                           0            0            0            0            N/A
XPT                            1            0            0            0            N/A
XPLPR-VideoSourceLicense       1            0            0            0            N/A
XPLPR-CountryModuleLicense     1            0            0            0            N/A
```

Returns the License Details

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseDetailChildItem

## NOTES

## RELATED LINKS
