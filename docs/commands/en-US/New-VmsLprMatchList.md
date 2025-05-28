---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsLprMatchList/
schema: 2.0.0
---

# New-VmsLprMatchList

## SYNOPSIS
Creates a new LPR match list.

## SYNTAX

```
New-VmsLprMatchList [-Name] <String> [-TriggerEvent <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsLprMatchList` cmdlet creates a new LPR match list with the provided name and optional list of events that
should be triggered when a license plate in the list is detected.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
New-VmsLprMatchList -Name Tenants
```

Create a new LPR match list named "Tenants".

### Example 2
```powershell
$outputPath = (Get-VmsOutput -Name 'Audio Warning').Path
New-VmsLprMatchList -Name Unauthorized -TriggerEvent $outputPath
```

Create a new LPR match list named "Unauthorized", and activate the output device "Audio Warning" when a license plate
matching an entry in this list is detected.

## PARAMETERS

### -Name
The name of the new LPR match list.

```yaml
Type: String
Parameter Sets: (All)
Aliases: MatchList

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TriggerEvent
Specifies one or more optional events to be triggered when a license plate matches an entry in this match list. The
values required are the Configuration API "Path" values of either a user-defined event, or a hardware output device. For
example, `Output[213d74e4-8310-48b9-9670-ed6be985420b]` or `UserDefinedEvent[662e8ad9-9c54-4649-a0ab-53adcaf12e29]`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LprMatchList

## NOTES

## RELATED LINKS
