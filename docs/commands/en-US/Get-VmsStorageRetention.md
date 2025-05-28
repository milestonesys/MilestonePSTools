---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsStorageRetention/
schema: 2.0.0
---

# Get-VmsStorageRetention

## SYNOPSIS

Gets a \[timespan\] representing the configured storage retention for the specified storage.

## SYNTAX

```
Get-VmsStorageRetention [[-Storage] <Storage[]>] [<CommonParameters>]
```

## DESCRIPTION

A Milestone Storage object represents both the overall storage configuration and the live
storage information for that storage configuration.
It has ArchiveStorage child items for each
archive path associated with that storage configuration.
To determine the retention for the
whole storage configuration, you need to find the largest "RetainMinutes" value between the
live recording path and all the optional archive storage paths.

This function saves the step of checking whether archives exist and finding the archive child
item with the longest retention.

The value returned represents the maximum age of data before it will be deleted.
The only
exception is if you have used the evidence lock feature which can tag video with custom
retention policies and even keep video indefinitely.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer -Name Test | Get-VmsStorage | Foreach-Object { [pscustomobject]@{ Storage = $_.Name; Retention = ($_ | Get-VmsStorageRetention).TotalDays } }
```

Gets all storage configurations associated with the Recording Server named "Test" and returns the storage names and the maximum retention value in days.

## PARAMETERS

### -Storage

Specifies the the storage object from which to return the maximum retention value.
Use Get-VmsStorage to acquire a Storage object.

```yaml
Type: Storage[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.TimeSpan

## NOTES

## RELATED LINKS
