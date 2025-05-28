---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Disconnect-Vms/
schema: 2.0.0
---

# Disconnect-Vms

## SYNOPSIS
Disconnects the current VMS logon session(s).

## SYNTAX

```
Disconnect-Vms [<CommonParameters>]
```

## DESCRIPTION
The `Disconnect-Vms` cmdlet closes the current VMS logon session(s). If not already connected to a VMS, the cmdlet does
nothing and does not throw an error.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Disconnect-Vms
```

Closes any open VMS logon sessions.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
