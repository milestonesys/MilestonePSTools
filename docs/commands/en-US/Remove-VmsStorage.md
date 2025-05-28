---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsStorage/
schema: 2.0.0
---

# Remove-VmsStorage

## SYNOPSIS

Removes a Milestone XProtect recording server storage configuration and all of the child archive storages if present

## SYNTAX

### ByName
```
Remove-VmsStorage -RecordingServer <RecordingServer> -Name <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByStorage
```
Remove-VmsStorage -Storage <Storage> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

If the specified storage is not marked as the default storage, and there are no devices configured to record to the
storage, this function removes the storage configuration including any and all archive storages attached to the live
drive represented by the storage configuration.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer | Remove-VmsStorage -Name 'Old Storage Config'
```

Removes the storage configuration named 'Old Storage Config' from all recording servers

## PARAMETERS

### -Name

Specifies the name of the existing storage configuration to look for on the specified recording server

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

### -RecordingServer

Specifies the RecordingServer object from which to look for matching storage configurations

```yaml
Type: RecordingServer
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Storage

Specifies the Storage object to be removed

```yaml
Type: Storage
Parameter Sets: ByStorage
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
