---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsRecordingServer/
schema: 2.0.0
---

# Set-VmsRecordingServer

## SYNOPSIS
Sets properties of one or more recording servers.

## SYNTAX

```
Set-VmsRecordingServer [-RecordingServer] <RecordingServer[]> [-Name <String>] [-Description <String>]
 [-PublicAccessEnabled <Boolean>] [-PublicWebserverPort <Int32>] [-PublicWebserverHostName <String>]
 [-ShutdownOnStorageFailure <Boolean>] [-MulticastServerAddress <String>]
 [-PrimaryFailoverGroup <FailoverGroup>] [-SecondaryFailoverGroup <FailoverGroup>]
 [-HotStandbyFailoverRecorder <FailoverRecorder>] [-DisableFailover] [-FailoverPort <Int32>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets properties of one or more recording servers.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$recorder | Set-VmsRecordingServer -PublicAccessEnabled $true -PublicWebserverPort 7563 -PublicWebserverHostName demo.milestonesys.com
```

Enables public access for a recording server, and sets the public hostname/fqdn
and port.

## PARAMETERS

### -Description
Specifies an optional description for the recording server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DisableFailover
Specifies that failover features should be disabled for this recording server.

REQUIREMENTS  

- Requires VMS feature "RecordingServerFailover"

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

### -FailoverPort
Specifies a TCP port value for the recording server to use when listening for status messages from failover recorders.

REQUIREMENTS  

- Requires VMS feature "RecordingServerFailover"

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HotStandbyFailoverRecorder
Specifies an unassigned failover recording server to designate as the hot standby failover for the recording server.

REQUIREMENTS  

- Requires VMS feature "RecordingServerFailover"

```yaml
Type: FailoverRecorder
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MulticastServerAddress
Specifies a multicast server address to use when clients should receive live video
from the recording server using multicast instead of unicast.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies a new display name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
Return the modified object to the caller or the pipeline.

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

### -PrimaryFailoverGroup
Specifies the failover group to use as the primary failover server group for the recording server.

REQUIREMENTS  

- Requires VMS feature "RecordingServerFailover"

```yaml
Type: FailoverGroup
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PublicAccessEnabled
Specifies that the recording server should advertise a different address for users
connecting from any network not considered by the management server to be "local".
This means any client logging in to the management server with a source IP address
(from the management server's perspective) that does not fall within the subnet
of one of the management server's network interfaces, or within one of the local
network ranges defined in Management Client under Tools > Options > Network, will
be considered "external" and they will be provided with the "public" address for
all recording servers instead of the "Local web server address".

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PublicWebserverHostName
Specifies the public hostname, IP, or DNS name for clients to use when connecting
from a "non-local" network IP.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PublicWebserverPort
Specifies the public TCP port for clients to use when connecting from a
"non-local" network IP.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServer
Specifies the recording server to modify, either by object or by name.

```yaml
Type: RecordingServer[]
Parameter Sets: (All)
Aliases: Recorder

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SecondaryFailoverGroup
Specifies the failover group to use as the secondary failover server group for the recording server. If all failover servers in the primary failover group are busy or unavailable, the first available failover server in the secondary failover group will assume responsibility for the recording server.

REQUIREMENTS  

- Requires VMS feature "RecordingServerFailover"

```yaml
Type: FailoverGroup
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShutdownOnStorageFailure
Specifies that the recording server should shut down when there is a storage
failure resulting in an inability to record. This may be important when you have
a failover recording server that should take over during such an event.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### VideoOS.Platform.ConfigurationItems.RecordingServer[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.RecordingServer
## NOTES

## RELATED LINKS
