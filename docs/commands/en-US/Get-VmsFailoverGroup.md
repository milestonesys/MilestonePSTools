---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsFailoverGroup/
schema: 2.0.0
---

# Get-VmsFailoverGroup

## SYNOPSIS

Gets one or more failover groups.

## SYNTAX

### Name (Default)
```
Get-VmsFailoverGroup [[-Name] <String>] [<CommonParameters>]
```

### Id
```
Get-VmsFailoverGroup -Id <Guid> [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsFailoverGroup` cmdlet gets one or more existing failover groups,
which can each contain failover recording servers.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "RecordingServerFailover"

## EXAMPLES

### Example 1

```powershell
Get-VmsFailoverGroup
```

Gets all existing failover groups.

### Example 2

```powershell
Get-VmsFailoverGroup -Name FO1
```

Gets the failover group named FO1.

### Example 3

```powershell
Get-VmsFailoverGroup -Name Site-A*
```

Gets all failover groups having a name that starts with "Site-A".

### Example 4

```powershell
Get-VmsFailoverGroup -Id 556d1e2a-bed9-4ae5-b54a-f27d49839525
```

Gets the failover group with Id '556d1e2a-bed9-4ae5-b54a-f27d49839525'.

## PARAMETERS

### -Id

Specifies the ID of an existing failover group.

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

### -Name
Specifies the name of an existing failover group with support for wildcards.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.FailoverGroup

## NOTES

## RELATED LINKS
