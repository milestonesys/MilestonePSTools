---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLicensedProducts/
schema: 2.0.0
---

# Get-VmsLicensedProducts

## SYNOPSIS

Gets the licensed proects of the connected site.

## SYNTAX

```
Get-VmsLicensedProducts [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsLicensedProducts` cmdlet returns the licensed products information of the connected site.
The information returned shows the Product Name, SLC, expiration date, Care Plus expiration date,
and Care Premium expiration date.

The information returned is similar to what the Management Client shows in the License Information
section under Installed Products.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1

```powershell
Get-VmsLicensedProducts
```

```Output
DisplayName                    Slc                    ExpirationDate  CarePlus                      CarePremium
-----------                    ---                    --------------  --------                      -----------
XProtect Corporate 2025 R1     M01-C01-251-01-1A23BC  Unrestricted    2027-09-30T00:00:00.0000000Z  N/A
Milestone XProtect Smart Wall  M01-P03-100-01-1A23BC  Unrestricted    Unrestricted
XPLPR                          M01-P02-100-01-1A23BC  Unrestricted    Unrestricted
XPAC                           M01-P01-100-01-1A23BC  Unrestricted    Unrestricted
XPT                            M01-P08-100-01-1A23BC  Unrestricted    Unrestricted
XPIM                           M01-P06-100-01-1A23BC  Unrestricted    Unrestricted
```

Returns the licensed products information

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseInstalledProductChildItem

## NOTES

## RELATED LINKS
