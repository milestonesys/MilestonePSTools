---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsFailoverRecorder/
schema: 2.0.0
---

# Get-VmsFailoverRecorder

## SYNOPSIS
Gets one or more matching failover recording servers from the VMS.

## SYNTAX

### FailoverGroup (Default)
```
Get-VmsFailoverRecorder [-FailoverGroup <FailoverGroup>] [-Recurse] [<CommonParameters>]
```

### HotStandby
```
Get-VmsFailoverRecorder [-HotStandby] [<CommonParameters>]
```

### Unassigned
```
Get-VmsFailoverRecorder [-Unassigned] [<CommonParameters>]
```

### Id
```
Get-VmsFailoverRecorder -Id <Guid> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsFailoverRecorder` cmdlet returns matching failover recording servers from the VMS configuration.

Failover recording servers can be "unassigned", meaning they have not been added to a failover group. They can also be
"hotstandby" servers, meaning they are not a member of a failover group, and they have been selected to be used exclusively
for failover of a specific recording server. Finally, a failover server can be in a single failover recorder group.

Failover groups can be selected as either a primary, or secondary failover group for a given recording server, and multiple
recording servers can use the same failover group, regardless of the number of failover recording servers in the group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1
```powershell
Get-VmsFailoverRecorder
```

When used without parameters, all unassigned and hotstandby failover recording servers are returned.

### Example 2
```powershell
Get-VmsFailoverRecorder -Unassigned
```

All failover recording servers that have not been added to a failover group, and have not been selected as a hotstandby
are returned.

### Example 3
```powershell
Get-VmsFailoverRecorder -Hotstandby
```

Only hotstandby recording servers are returned.

### Example 4
```powershell
Get-VmsFailoverGroup | Foreach-Object {
    $group = $_
    Get-VmsFailoverRecorder -FailoverGroup $group | Foreach-Object {
        [pscustomobject]@{
            FailoverGroup    = $group.Name
            FailoverRecorder = $_.Name
        }
    }
}
```

This example demonstrates how to use the `-FailoverGroup` parameter. It will generate a table of failover recorders and
the name of the failover group they are assigned to.

### Example 4
```powershell
Get-VmsFailoverRecorder -Recurse
```

Returns all unassigned, hotstandby, and failover recording servers assigned to failover groups.

## PARAMETERS

### -FailoverGroup
Specifies a FailoverGroup object returned by `Get-VmsFailoverGroup`.

```yaml
Type: FailoverGroup
Parameter Sets: FailoverGroup
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -HotStandby
Specifies that only hotstandby failover recorders should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: HotStandby
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Specifies the GUID of a specific failover recorder, regardless of whether it is
in a group, unassigned, or a hotstandby failover recorder.

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Recurse
Specifies that all failover recording servers should be returned from all failover
groups, as well as any unassigned or hotstandby failovers.

```yaml
Type: SwitchParameter
Parameter Sets: FailoverGroup
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unassigned
Specifies that only failover recorders that are unassigned should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: Unassigned
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.FailoverGroup

### System.Guid

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.FailoverRecorder

## NOTES

## RELATED LINKS
