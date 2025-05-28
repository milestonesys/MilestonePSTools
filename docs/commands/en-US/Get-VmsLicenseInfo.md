---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLicenseInfo/
schema: 2.0.0
---

# Get-VmsLicenseInfo

## SYNOPSIS

Returns basic license information.

## SYNTAX

```
Get-VmsLicenseInfo [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsLicenseInfo` cmdlet returns basic license information of the connected site. The
information returned shows the main license name and version (e.g. "XProtect Corporate
2025 R1"), SLC (e.g. "XPCO"), SKU, CareLevel (e.g. "Plus"), CareId, and ActivationAutomatic.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1: Get the basic license info for the current site

```powershell
Get-VmsLicenseInfo
```

```Output
DisplayName                Slc                   Sku  CareLevel CareId ActivationAutomatic
-----------                ---                   ---  --------- ------ -------------------
XProtect Corporate 2025 R1 M01-C01-251-01-123456 XPCO Plus             False
```

The output of this command provides the product display name, SLC, and a few other properties of interest.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseInformation

## NOTES

## RELATED LINKS

[Get-VmsLicenseDetails](./Get-VmsLicenseDetails.md)
[Get-VmsLicensedProducts](./Get-VmsLicensedProducts.md)
[Get-VmsLicenseOverview](./Get-VmsLicenseOverview.md)

