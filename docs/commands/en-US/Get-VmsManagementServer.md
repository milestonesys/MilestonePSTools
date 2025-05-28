---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsManagementServer/
schema: 2.0.0
---

# Get-VmsManagementServer

## SYNOPSIS

Gets the Management Server for the currently selected site.

## SYNTAX

```
Get-VmsManagementServer [<CommonParameters>]
```

## DESCRIPTION

Gets a ManagementServer object representing the Management Server for the
currently selected site. The ManagementServer object can be used directly to
access all VMS configuration properties available through the Configuration
API.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsManagementServer | Select-Object Name, ComputerName, Version

<# OUTPUT
  Name           ComputerName Version
  ----           ------------ -------
  Milestone Demo AMERICASDEMO 21.2.0.1
#>
```

Presents a login dialog, gets a Configuration API object representing the
Management Server, and displays the Name, ComputerName, and Version properties.

### Example 2

```powershell
$ms = Get-VmsManagementServer
$ms.ViewGroupFolder.ViewGroups | Select-Object Name, LastModified
<# OUTPUT
  Name              LastModified
  ----              ------------
  [BASIC]\test      3/30/2020 4:53:01 PM
  Public View Group 9/19/2018 1:48:35 PM
  Interconnects     8/12/2020 12:19:49 PM
#>
```

Gets a Configuration API object representing the Management Server, and
navigates into the ViewGroup child objects to return the name of each ViewGroup
and the LastModified timestamp. Timestamps are always in UTC until you call
.ToLocalTime() on the DateTime object.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ManagementServer

## NOTES

## RELATED LINKS
