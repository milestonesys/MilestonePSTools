---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Move-VmsHardware/
schema: 2.0.0
---

# Move-VmsHardware

## SYNOPSIS
Moves hardware to a new destination recording server and storage profile.

## SYNTAX

```
Move-VmsHardware [-Hardware] <Hardware[]> [-DestinationRecorder] <RecordingServer>
 [-DestinationStorage] <Storage> [-AllowDataLoss] [-SkipDriverCheck] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Move-VmsHardware` cmdlet moves hardware to a new destination recording server and storage profile.

If the destination recording server does not have the exact same driver version and revision, you must use the
`-SkipDriverCheck` parameter.

If the source recording server cannot be reached by the management server, you must either resolve the issue or
acknowledge that existing recordings will be permanently orphaned from the VMS and potentially deleted if the original
source recording server comes back online in the future. This risk can be accepted by including the `-AllowDataLoss`
parameter.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$selectedHardware = Get-VmsHardware | Out-GridView -OutputMode Multiple
$destinationRecorder = Get-VmsRecordingServer | Out-GridView -OutputMode Single
$destinationStorage = $destinationRecorder | Get-VmsStorage | Out-GridView -OutputMode Single
$selectedHardware | Move-VmsHardware -DestinationRecorder $destinationRecorder -DestinationStorage $destinationStorage
```

Prompts for one or more hardware to be selected, along with a destination recording server and storage location on that recording server. Then proceeds to move the selected hardware accordingly.

By default, if the driver versions don't exactly match between the source and destination recording servers, the move will fail. Similarly, if the source recording server is not connected to the management server, the move will also fail.

To allow a device pack driver version difference between recording servers, use the `-SkipDriverCheck` parameter. And to allow the hardware to be moved even though it may result in loss of data due to the source recording server being unavailable, use the `-AllowDataLoss` parameter.

### Example 1
```powershell
$selectedHardware = Get-VmsHardware | Out-GridView -OutputMode Multiple
Move-VmsHardware -Hardware $selectedHardware -DestinationRecorder Recorder2 -DestinationStorage 'Long-term Storage' -SkipDriverCheck -AllowDataLoss
```

Prompts for one or more hardware to be selected, then attempts to move the selected hardware to the recording server named "Recorder2", using the storage configuration named "Long-term Storage".

The device pack driver versions will not be checked ahead of time. If there is a mismatch, you will see a warning after the successful move.

If the source recording server(s) are not connected to the management server at the time of move, the `-AllowDataLoss` switch indicates that the move should proceed anyway, at the risk of losing recordings on the source recording server(s).

## PARAMETERS

### -AllowDataLoss
Allows hardware to be moved when the source recording server is not reachable by the management server which will result
in orphaned recordings on that recording server and potentially deleted recordings if that recording server returns
online in the future.

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

### -DestinationRecorder
Specifies the recording server to which the specified hardware should be moved.

```yaml
Type: RecordingServer
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationStorage
Specifies the storage profile on the destination recording server where recordings from all devices on the specified
hardware should be stored.

```yaml
Type: Storage
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Hardware
Specifies one or more hardware devices from one or more recording servers to be moved to the specified destination
recording server and storage profile.

```yaml
Type: Hardware[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PassThru
Specifies that hardware objects should be returned to the pipeline after successfully moving to the destination recording server.

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

### -SkipDriverCheck
Specifies that differences between the source and destination driver versions should be ignored.

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

### VideoOS.Platform.ConfigurationItems.Hardware[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## NOTES

## RELATED LINKS
