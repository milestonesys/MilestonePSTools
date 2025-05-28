---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-EvidenceLock/
schema: 2.0.0
---

# Remove-EvidenceLock

## SYNOPSIS

Removes an evidence lock record which makes it possible for previously-protected recordings to be deleted.

## SYNTAX

### FromMarkedData
```
Remove-EvidenceLock -EvidenceLocks <MarkedData[]> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FromId
```
Remove-EvidenceLock -EvidenceLockIds <String[]> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Remove-EvidenceLock` cmdlet removes an evidence lock record which makes it possible for previously-protected
recordings to be deleted.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "EvidenceLock"

## EXAMPLES

### Example 1

```powershell
$lock = Get-EvidenceLock | Out-GridView -OutputMode Single
$lock | Remove-EvidenceLock
```

This example would remove the selected evidence lock, however the Remove-EvidenceLock cmdlet requires the `-Force` switch
and has a ConfirmImpact value of "High" which normally results in a confirmation prompt before a record is deleted.

## PARAMETERS

### -EvidenceLockIds

Specifies one or more evidence lock record IDs for the records that should be deleted.

```yaml
Type: String[]
Parameter Sets: FromId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EvidenceLocks

Specifies one or more evidence lock records to be deleted. Retrieve evidence lock records using `Get-EvidenceLock`.

```yaml
Type: MarkedData[]
Parameter Sets: FromMarkedData
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force

Specifies that the evidence lock records should be deleted even though it may result in the associated recordings being deleted if they
are older than the configured retention time in the storage profile they reside in.

```yaml
Type: SwitchParameter
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

### VideoOS.Common.Proxy.Server.WCF.MarkedData[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
