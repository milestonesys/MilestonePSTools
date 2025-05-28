---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MobileServerInfo/
schema: 2.0.0
---

# Get-MobileServerInfo

## SYNOPSIS

Gets details about the local Milestone XProtect Mobile Server installation.

## SYNTAX

```
Get-MobileServerInfo [<CommonParameters>]
```

## DESCRIPTION

Gets details about the local Milestone XProtect Mobile Server installation.
Properties include:

- Version
- ExePath
- ConfigPath
- ManagementServerIp
- ManagementServerPort
- HttpIp
- HttpPort
- HttpsIp
- HttpsPort
- CertHash

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Get-MobileServerInfo
```

Gets a collection of useful Mobile Server properties.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
