---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Test-VmsLicensedFeature/
schema: 2.0.0
---

# Test-VmsLicensedFeature

## SYNOPSIS
Tests whether the provided feature name is available on the connected Milestone XProtect VMS.

## SYNTAX

```
Test-VmsLicensedFeature [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
The `Test-VmsLicensedFeature` cmdlet tests whether the provided feature name is
available on the connected Milestone XProtect VMS. The feature names available
on the current site can be returned using `(Get-VmsSystemLicense).FeatureFlags`
or by using the MIP SDK components directly with `[MilestonePSTools.Connection.MilestoneConnection]::Instance.SystemLicense.FeatureFlags`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Test-VmsLicensedFeature -Name 'SmartMap'
```

Returns `$true` if the Smart Maps feature is available.

### Example 2
```powershell
if ($false -in ('EdgeStorage', 'AdaptiveStreaming' | Test-VmsLicensedFeature)) {
    Write-Error "One or more required features are unavailable on site $(Get-VmsSite)"
}
```

If either the "EdgeStorage" or "AdaptiveStreaming" feature are missing on the current
site, an error is returned.

## PARAMETERS

### -Name
Specifies the name of the licensed feature to test. There is no public document
listing all possible feature names, and the list grows over time. You can see
which features are available on your VMS using `(Get-VmsSystemLicense).FeatureFlags`.

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

### System.Boolean

## NOTES

The MIP SDK documentation doesn't yet clarify how the underlying
`VideoOS.Platform.License.SystemLicense` class works in a Milestone Federated Hierarchy.
The current assumption is that this cmdlet will provide information about the parent
site and not detailed information about which features are available when logged
directly into child sites.

## RELATED LINKS
