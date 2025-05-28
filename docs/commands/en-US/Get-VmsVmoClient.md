---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsVmoClient/
schema: 2.0.0
---

# Get-VmsVmoClient

## SYNOPSIS
Gets a Milestone VMO Client used to access and configure a management server.

## SYNTAX

```
Get-VmsVmoClient [<CommonParameters>]
```

## DESCRIPTION
The VMO Client is used internally by Milestone's MIP SDK, but is not supported for external use as it is an
undocumented interface. However, it is provided for advanced users to use at their own risk. In some cases it can be
used to perform operations that are not possible using supported MIP SDK interfaces.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```
$client = Get-VmsVmoClient
```

Creates a VMO client and stores it in the $client variable.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [VideoOS.Management.VmoClient.VmoClient]

## NOTES

## RELATED LINKS
