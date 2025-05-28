---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Start-VmsRestrictedLiveMode/
schema: 2.0.0
---

# Start-VmsRestrictedLiveMode

## SYNOPSIS
Starts a new live media restriction for one or more devices.

## SYNTAX

```
Start-VmsRestrictedLiveMode [-DeviceId] <Guid[]> [[-StartTime] <DateTime>] [-IgnoreRelatedDevices]
 [<CommonParameters>]
```

## DESCRIPTION
The `Start-VmsRestrictedLiveMode` cmdlet starts a new live media restriction for one or more devices.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.2
- Requires VMS feature "RestrictedMedia"

## EXAMPLES

### Example 1
```powershell
$cameras = Select-Camera -AllowFolders -AllowServers -RemoveDuplicates
$cameras | Start-VmsRestrictedLiveMode -StartTime (Get-Date).AddMinutes(-30)
```

This example prompts the user to select one or more cameras, and then creates a live media restriction on all selected
cameras with a `StartTime` of one half hour ago.

## PARAMETERS

### -DeviceId
Specifies one or more devices for which to create a live media restriction. By default, related devices are
automatically included.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IgnoreRelatedDevices
Specifies that the restrictions should apply _only_ on the devices specified and not on related devices (microphones,
speakers, and metadata).

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

### -StartTime
Specifies the time at which the restriction should begin. For example, if an incident occurred 30 minutes ago, you might
set `StartTime` to a timestamp 5-10 minutes earlier than that.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid[]

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive

## NOTES

## RELATED LINKS
