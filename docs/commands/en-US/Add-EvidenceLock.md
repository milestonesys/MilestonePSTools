---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-EvidenceLock/
schema: 2.0.0
---

# Add-EvidenceLock

## SYNOPSIS

Adds a new evidence lock record.

## SYNTAX

```
Add-EvidenceLock -Header <String> [-Description <String>] [-CameraIds <Guid[]>] [-DeviceIds <Guid[]>]
 [-IncludeRelatedDevices] -FootageFrom <DateTime> -FootageTo <DateTime> [-ExpireDate <DateTime>]
 [-RetentionType <String>] [<CommonParameters>]
```

## DESCRIPTION

Adds a new evidence lock record. Evidence locks describe sequences of video for one or more cameras and related devices with custom retention settings. This enables you to retain recordings longer than the normal configured video retention for the selected devices.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "EvidenceLock"

## EXAMPLES

### Example 1

```powershell
Add-EvidenceLock -Header 'Evidence Lock Title' -Description 'Created from PowerShell' -CameraIds (Select-Camera -RemoveDuplicates -AllowFolders -AllowServers).Id -IncludeRelatedDevices -FootageFrom (Get-Date).AddDays(-1) -FootageTo (Get-Date).AddMinutes(-5) -RetentionType UserDefined -ExpireDate (Get-Date).AddDays(300) -Verbose
```

Creates a new evidence lock for the last ~24 hours of video from the selected cameras with a 300-day retention.

## PARAMETERS

### -CameraIds

One or more camera IDs to associate with the new evidence lock record

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description

A detailed description of the evidence lock record

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceIds

Zero or more additional device IDs to be associated with the evidence lock such as related microphones or speakers

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireDate

The date at which the evidence lock should expire and recordings should be deleted based on normal retention settings for their storage configuration

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FootageFrom

Specifies the earliest start time for the recordings associated with the evidence lock

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FootageTo

Specifies the most recent recordings associated with the evidence lock

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header

Specifies the title of the evidence lock

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeRelatedDevices

Specifies whether related devices are automatically associated with the evidence lock

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

### -RetentionType

Specifies the type of retention for the evidence lock

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Indefinite, UserDefined

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.MarkedDataResult

## NOTES

## RELATED LINKS
