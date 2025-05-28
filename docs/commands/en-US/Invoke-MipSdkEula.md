---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Invoke-MipSdkEula/
schema: 2.0.0
---

# Invoke-MipSdkEula

## SYNOPSIS

Opens the end-user license agreement file for MIP SDK in the default RTF file viewer

## SYNTAX

```
Invoke-MipSdkEula [<CommonParameters>]
```

## DESCRIPTION

This module is built upon Milestone's MIP SDK and requires the use of the redistributable MIP SDK binaries.
As such, it is required for the user of this module to accept the agreement prior to use.

This command will open the MIPSDK_EULA.txt file included with MilestonePSTools in the default viewer.
If you prefer to get the raw text as a string, you can use Get-MipSdkEula instead.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Invoke-MipSdkEula
```

Opens the EULA in the default .TXT file viewer.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
