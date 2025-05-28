---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Assert-VmsRequirementsMet/
schema: 2.0.0
---

# Assert-VmsRequirementsMet

## SYNOPSIS
Returns an error if any custom "\[RequiresVms*\] attribute present on the calling function fails validation.

## SYNTAX

```
Assert-VmsRequirementsMet [<CommonParameters>]
```

## DESCRIPTION
MilestonePSTools includes custom attributes that are used to decorate certain
internal commands and parameters where those commands or parameters are only
supported when a specific feature is available on the connected VMS, or when the
connected VMS is a certain version.

You may be familiar with validation attributes for parameters such as
`[ValidateSet('Option1', 'Option2')]`, `[ValidateRange(1, 10)]`, or
`[ValidateNotNullOrEmpty()]`. However, some entire commands in
MilestonePSTools require the VMS version to be at some minimum level, such as
the `Set-VmsHardwareDriver` command, and some commands require a certain VMS
feature to be available such as the `Get-VmsFailoverRecorder` cmdlets.

PowerShell does not provide any utility for executing a validation method on a
custom attribute unless that attribute is applied to a parameter, so the
`Assert-VmsRequirementsMet` command can be added to any begin/end/process block
and it will throw an error if there are any "RequiresVms*" attributes decorating
your PowerShell functions or cmdlets.

The advantage of this is two-fold; your commands can be self-documenting in
terms of minimum/maximum version requirements, and you do not have to detect
these issues yourself or worry about having consistent error messaging as the
validation errors will always be consistent.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
function Get-SomethingRequiringMinimumVersion {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsVersion('23.1')]
    param()
    
    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        "This string will only be returned if the connected VMS is at least 23.1, or if '-ErrorAction SilentlyContinue' is included when calling Get-SomethingRequiringMinimumVersion."
    }
}

Get-SomethingRequiringMinimumVersion
```

Returns a string message if the connected VMS is at least version 23.1.
Otherwise it throws an error like 'Server version must be greater than or equal
to ...'

### Example 2
```powershell
function Get-SomethingRequiringExactVersion {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsVersion('[23.1]')]
    param()
    
    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        "This string will only be returned if the connected VMS is exactly 23.1, or if '-ErrorAction SilentlyContinue' is included when calling Get-SomethingRequiringExactVersion."
    }
}

Get-SomethingRequiringExactVersion
```

Returns a string message if the connected VMS is exactly version 23.1. Otherwise
it throws an error like 'Server version must be exactly ...'

### Example 3
```powershell
function Get-SomethingRequiringVersionRange {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsVersion('[,23.1]')]
    param()
    
    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        "This string will only be returned if the connected VMS version is less than or equal to 23.1, or if '-ErrorAction SilentlyContinue' is included when calling Get-SomethingRequiringVersionRange."
    }
}

Get-SomethingRequiringVersionRange
```

Returns a string message if the connected VMS is less than or equal to version 23.1. Otherwise
it throws an error like 'Server version must be less than or equal to ...'

### Example 4
```powershell
function Get-SomethingRequiringVersionRange {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsVersion('[22.1,23.1)')]
    param()
    
    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        "This string will only be returned if the connected VMS version is greater than or equal to 22.1 and less than 23.1, or if '-ErrorAction SilentlyContinue' is included when calling Get-SomethingRequiringVersionRange."
    }
}

Get-SomethingRequiringVersionRange
```

Returns a string message if the connected VMS is greater than or equal to 22.1 and less than 23.1. Otherwise
it throws an error like 'Server version must be greater than or equal to ...' or 'Server version must be less than ...' depending on the VMS version.

### Example 5
```powershell
function Get-SomethingRequiringMinVersionAndFeature {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsVersion('23.2')]
    [MilestonePSTools.RequiresVmsFeature('RecordingServerFailover')]
    param()
    
    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        "This string will only be returned if the connected VMS version is greater than or equal to 23.2 and if the RecordingServerFailover feature is available, or if '-ErrorAction SilentlyContinue' is included when calling Get-SomethingRequiringMinVersionAndFeature."
    }
}

Get-SomethingRequiringMinVersionAndFeature
```

Returns a string message if the connected VMS version is greater than or equal
to 23.2 and the RecordingServerFailover feature is available. Otherwise it
throws an error like 'Server version must be greater than or equal to ...' or
'The feature "RecordingServerFailover" is not available on your VMS.'

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

See Microsoft's NuGet package versioning documentation linked below for more
information about the syntax for specifying minimum and maximum version numbers.
The `[MilestonePSTools.RequiresVmsVersion()]` attribute supports all permutations
of minimum, maximum, inclusive, exclusive, and exact version specifications.

For a list of available feature flags on your connected VMS, inspect the `FeatureFlags`
property on the object returned by `Get-VmsSystemLicense`. Or simply run the command
`(Get-VmsSystemLicense).FeatureFlags | Sort-Object` to display a sorted list of
available features.

## RELATED LINKS

[Version range notation](https://learn.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges)

