---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Test-VmsConnection/
schema: 2.0.0
---

# Test-VmsConnection

## SYNOPSIS
Tests whether there is an active connection to a Milestone XProtect VMS in the current PowerShell session.

## SYNTAX

```
Test-VmsConnection [<CommonParameters>]
```

## DESCRIPTION
The `Test-VmsConnection` cmdlet tests whether there is an active connection to a Milestone XProtect VMS in the current PowerShell session. If `Connect-Vms` or `Connect-ManagementServer` has been used to successfully login to a Milestone XProtect VMS
in the current PowerShell session, the command returns `$true`.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
if (Test-VmsConnection) {
    Disconnect-Vms
    Connect-Vms -ShowDialog
}
```

If currently logged in to a VMS, logout, and then present a login dialog. Since `Connect-Vms` is used with `-ShowDialog`,
and not `-Name 'MyVmsProfileName'`, a named connection profile will not be created and saved to disk for this connection.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
