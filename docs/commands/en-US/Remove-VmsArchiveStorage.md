---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsArchiveStorage/
schema: 2.0.0
---

# Remove-VmsArchiveStorage

## SYNOPSIS

Removes a Milestone XProtect recording server archive storage configuration

## SYNTAX

### ByName
```
Remove-VmsArchiveStorage -Storage <Storage> -Name <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByStorage
```
Remove-VmsArchiveStorage -ArchiveStorage <ArchiveStorage> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If the specified archive is the the last one in the archive chain (it has the largest RetainMinutes value),
this function removes the archive from the storage configuration.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer | Get-VmsStorage -Name 'Example Storage' | Remove-VmsArchiveStorage -Name 'Retired NAS Storage'
```

Removes all archive storages named 'Retired NAS Storage' from all storage configurations named 'Example Storage' on all recording servers

## PARAMETERS

### -ArchiveStorage

Specifies the ArchiveStorage object to be removed

```yaml
Type: ArchiveStorage
Parameter Sets: ByStorage
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name of the existing archive storage configuration to look for on the specified storage configuration

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Storage

Specifies the Storage object from which to look for matching archive storage configurations

```yaml
Type: Storage
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
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
