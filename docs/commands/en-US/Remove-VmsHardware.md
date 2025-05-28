---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsHardware/
schema: 2.0.0
---

# Remove-VmsHardware

## SYNOPSIS
Removes a Milestone XProtect VMS hardware device and all child devices.

## SYNTAX

```
Remove-VmsHardware [-Hardware] <Hardware[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Removes a Milestone XProtect VMS hardware device and all child devices.
Any
video, audio, and metadata associated with the device will be immediately,
and irreverisbly deleted.

This command supports -WhatIf, and has a ConfirmImpact rating of "High".
When running commands interactively, it's a good idea to take advantage of
the -WhatIf parameter switch to see what *would* happen if you really ran
the command.

If you do not want to confirm the operation, you can add -Confirm:$false to
your command to disable confirmation.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
linenums="1"
Connect-Vms -ShowDialog -AcceptEula
Get-VmsHardware | Out-GridView -OutputMode Single | Remove-VmsHardware -WhatIf
```

1. Show a Milestone XProtect login dialog, disconnect from any existing session
   if present, and accept the end-user license agreement for MIP SDK.
2. Present a list of all hardware on the VMS from which one entry can be
   selected. The selected hardware will be passed to Remove-VmsHardware.
3. Thanks to the `-WhatIf` switch parameter, the hardware will *not* be removed.
   Instead, the operation will be logged to the terminal to show you what would have
   happened.

Note: To actually remove hardware, remove the -WhatIf switch. And if you expect to do
this a lot, such as on a test system, you can add `-Confirm:$false` to disable
confirmation.

## PARAMETERS

### -Hardware

Specifies one or more Hardware objects to be removed from the VMS.
Use
Get-VmsHardware to retrieve the devices you want to delete.

```yaml
Type: Hardware[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
