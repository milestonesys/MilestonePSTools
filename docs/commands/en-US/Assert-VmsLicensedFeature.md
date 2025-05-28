---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Assert-VmsLicensedFeature/
schema: 2.0.0
---

# Assert-VmsLicensedFeature

## SYNOPSIS
Returns an error if the specified feature is not licensed on the current VMS.

## SYNTAX

```
Assert-VmsLicensedFeature [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
The `Assert-VmsLicensedFeature` cmdlet returns an error if the specified feature is not licensed on the current VMS.
This can be useful when writing tools and scripts that will be used on multiple systems with potentially different sets
of available features.

You can use `(Get-VmsSystemLicense).FeatureFlags` to retrieve a list of valid feature names available on the current VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Assert-VmsLicensedFeature -Name SmartWall
```

This example will do nothing at all if the SmartWall feature flag is present. If the SmartWall feature isn't available,
you will instead receive an error similar to the one in the following example.

### Example 2
```powershell
Assert-VmsLicensedFeature -Name UnavailableFeature

<#
Assert-VmsLicensedFeature : The feature "UnavailableFeature" is not enabled on your VMS.
At line:1 char:1
+ Assert-VmsLicensedFeature -Name UnavailableFeature
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotEnabled: (UnavailableFeature:String) [Write-Error], NotSupportedMIPException
    + FullyQualifiedErrorId : VideoOS.Platform.NotSupportedMIPException,Assert-VmsLicensedFeature
#>
```

This example will do nothing at all if the SmartWall feature flag is present. If the SmartWall feature isn't available,
you will instead receive the error shown in the following example.

### Example 3
```powershell
Assert-VmsLicensedFeature -Name UnavailableFeature -ErrorAction SilentlyContinue -ErrorVariable featureError
Write-Host "The feature '$($featureError.TargetObject)' is not available."
```

In this example we expand on the previous example and demonstrate that the feature name triggering the error is avaiable
from the `TargetObject` property of the `ErrorRecord`. In this case we silence the error and capture the error, if any,
in the `$featureError` variable.

## PARAMETERS

### -Name
Specifies the name of a feature to assert the availability of.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES

## RELATED LINKS
