---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Copy-EvidenceLock/
schema: 2.0.0
---

# Copy-EvidenceLock

## SYNOPSIS

Copies an existing Evidence Lock by creating a new Evidence Lock record with the same parameters.

## SYNTAX

```
Copy-EvidenceLock -Source <MarkedData> [<CommonParameters>]
```

## DESCRIPTION

At the time of making this cmdlet, 2019-06-05, an evidence lock record on the Management Server doesn't necessarily mean that same evidence lock is known by the Recording Server.
There are various situations in which this data might be out of sync and a user might believe data is evidence locked but in fact the Recording Server disagrees.

The purpose of this cmdlet is to create a copy of an existing Evidence Lock record so that we know it exists on the Recording Server, assuming no error is thrown when creating the copy.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "EvidenceLock"

## EXAMPLES

### EXAMPLE 1

```powershell
$records = Get-EvidenceLock; $records[0] | Copy-EvidenceLock
```

Retrieves all evidence locks into $records, and creates a copy of the first record in that list.
You could do Get-EvidenceLock | Copy-EvidenceLock but I suspect this may result in a unending loop.
Best to get all locks into a single array that you can then enumerate.

## PARAMETERS

### -Source

Specifies a MarkedData record returned by a call to `Get-EvidenceLock`.

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

### VideoOS.Common.Proxy.Server.WCF.MarkedDataResult

## NOTES

## RELATED LINKS
