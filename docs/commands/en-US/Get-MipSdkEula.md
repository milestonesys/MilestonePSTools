---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MipSdkEula/
schema: 2.0.0
---

# Get-MipSdkEula

## SYNOPSIS

Returns the MIP SDK end-user license agreement as a string

## SYNTAX

```
Get-MipSdkEula [<CommonParameters>]
```

## DESCRIPTION

This module is built upon Milestone's MIP SDK and requires the use of the redistributable MIP SDK binaries.
As such, it is required for the user of this module to accept the agreement prior to use.

This command will return the contents of the MIPSDK_EULA.txt file included with MilestonePSTools.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Get-MipSdkEula
```

Gets the content of the EULA for the MIP SDK.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
