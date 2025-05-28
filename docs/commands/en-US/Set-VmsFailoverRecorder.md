---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsFailoverRecorder/
schema: 2.0.0
---

# Set-VmsFailoverRecorder

## SYNOPSIS
Updates the settings of a failover recording server.

## SYNTAX

```
Set-VmsFailoverRecorder [-FailoverRecorder] <FailoverRecorder> [[-Name] <String>] [[-Enabled] <Boolean>]
 [[-Description] <String>] [[-DatabasePath] <String>] [[-UdpPort] <Int32>] [[-MulticastServerAddress] <String>]
 [[-PublicAccessEnabled] <Boolean>] [[-PublicWebserverHostName] <String>] [[-PublicWebserverPort] <Int32>]
 [-Unassigned] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsFailoverRecorder` cmdlet updates the settings for a failover recording server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1
```powershell
$allFailoverRecorders = Get-VmsFailoverRecorder -Recurse
$allFailoverRecorders | Set-VmsFailoverRecorder -Enabled $true -DatabasePath D:\MediaDB
```

Retrieve all failover recording servers, including failover recorders in a failover group, failover recorders acting as
hot standby recorders, and unassigned failover recorders and store them in the variable `$allFailoverRecorders`. Then,
set all failover recorder "Enabled" properties to `$true`, and set the media database paths on all failover recorders to
"D:\MediaDB".

## PARAMETERS

### -DatabasePath
Specifies a new, absolute file path for the failover recording server to use when recording video on behalf of another
recording server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies a new description for the failover recorder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Specifies whether the failover recorder should be enabled. A failover recorder might be disabled during maintenance for example.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FailoverRecorder
Specifies the failover recorder to be updated. Use `Get-VmsFailoverRecorder` to retrieve failover recorders.

```yaml
Type: FailoverRecorder
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MulticastServerAddress
Specifies a new multicast server address for the failover recorder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new display name for the failover recorder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the updated failover recorder should be returned to the pipeline.

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

### -PublicAccessEnabled
Specifies that public access (from an unrecognized IP subnet) should be enabled. Enabling this will make it possible
for "remote" connections to use a different hostname or IP address than "local" connections.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PublicWebserverHostName
Specifies the hostname, fully-qualified domain name, or IP address for clients to use when connecting from IP subnets
that are not considered "local" by the management server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PublicWebserverPort
Specifies a TCP port for clients to use when connecting from IP subnets that are not considered "local" by the management server.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UdpPort
Specifies which UDP port to use for status messages shared between failover recorders.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unassigned
Specifies that the failover recorder should be unassigned from the failover group it is currently a member of.

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

### VideoOS.Platform.ConfigurationItems.FailoverRecorder

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.FailoverRecorder

## NOTES

## RELATED LINKS
