---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-GenericEvent/
schema: 2.0.0
---

# Remove-GenericEvent

## SYNOPSIS

Removes Generic Events from the currently connected XProtect VMS site.

## SYNTAX

### GenericEvent (Default)
```
Remove-GenericEvent [-GenericEvent <GenericEvent>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Id
```
Remove-GenericEvent [-Id <Guid>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Remove-GenericEvent` cmdlet removes the specified Generic Event from the system.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-GenericEvent | Where-Object Name -eq 'Offline' | Remove-GenericEvent
```

Gets the Generic Event with the name 'Offline' and pipes it to `Remove-GenericEvent` which removes the event.

### Example 2

```powershell
Remove-GenericEvent -Id '7f47ab39-372e-4257-a182-1a8c5c24c52a'
```

Removes the Generic Event that has the ID of '7f47ab39-372e-4257-a182-1a8c5c24c52a'.

## PARAMETERS

### -GenericEvent

Specifies a Generic Event to be removed, as returned by `Get-GenericEvent`.

```yaml
Type: GenericEvent
Parameter Sets: GenericEvent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Id

Specifies the ID of the Generic Event object to be deleted.

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### VideoOS.Platform.ConfigurationItems.GenericEvent

### System.String

## OUTPUTS

### None

## NOTES

## RELATED LINKS
