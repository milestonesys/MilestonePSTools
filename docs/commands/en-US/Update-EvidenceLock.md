---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Update-EvidenceLock/
schema: 2.0.0
---

# Update-EvidenceLock

## SYNOPSIS

Updates an evidence lock entry with the changes made to an evidence lock object in the local PowerShell session.

## SYNTAX

```
Update-EvidenceLock -EvidenceLock <MarkedData> [<CommonParameters>]
```

## DESCRIPTION

The `Update-EvidenceLock` cmdlet updates an evidence lock entry with the changes made to an evidence lock object in the local PowerShell session.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "EvidenceLock"

## EXAMPLES

### Example 1

```powershell
$lock = Get-EvidenceLock -SearchText 'Case 1234 - Test Evidence Lock'
$lock.RetentionOption.RetentionOptionType = 'Months'
$lock.RetentionOption.RetentionUnits = 1
$lock | Update-EvidenceLock
```

Locate evidence locks with the text "Case 1234 - Test Evidence Lock" in the header or description, and update the retention
time to "1 Month" assuming the "1 Month" duration is present in the Evidence Lock profile settings in Management Client
found in Tools > Options > Evidence Lock.

### Example 2

```powershell
$lock = Get-EvidenceLock -DeviceIds 3D9DD26B-9A48-43D2-BFEA-3FEB6E8CD2EE
$lock.DeviceIds = $lock.DeviceIds | Where-Object { $_ -ne '3D9DD26B-9A48-43D2-BFEA-3FEB6E8CD2EE' }
if ($lock.DeviceIds.Count -eq 0) {
    $lock | Remove-EvidenceLock -Force
} else {
    $lock | Update-EvidenceLock    
}
```

Locate all evidence locks with the device id "3D9DD26B-9A48-43D2-BFEA-3FEB6E8CD2EE" in the list of associated devices, and
either removes the device from the evidence lock, or deletes the evidence lock if it was the only device in the evidence
lock entry.

## PARAMETERS

### -EvidenceLock

Specifies an object retrieved using `Get-EvidenceLock` which has changes to be sent to the Management Server.

```yaml
Type: MarkedData
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Common.Proxy.Server.WCF.MarkedData

## OUTPUTS

### None

## NOTES

## RELATED LINKS
