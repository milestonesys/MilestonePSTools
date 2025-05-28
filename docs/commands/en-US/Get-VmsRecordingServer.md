---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRecordingServer/
schema: 2.0.0
---

# Get-VmsRecordingServer

## SYNOPSIS
Gets one or more matching recording servers from the VMS.

## SYNTAX

### ByName (Default)
```
Get-VmsRecordingServer [[-Name] <String>] [<CommonParameters>]
```

### ById
```
Get-VmsRecordingServer -Id <Guid> [<CommonParameters>]
```

### ByHostname
```
Get-VmsRecordingServer [-HostName <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets one or more matching recording servers from the VMS. Recording servers can
be retrieved by name, ID, or hostname.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRecordingServer
```

Gets a list of all recording servers in the VMS.

### Example 2
```powershell
Get-VmsRecordingServer -Name "Portland*"
```

Gets a list of all recording servers with a name starting with "Portland".

### Example 3
```powershell
Get-VmsRecordingServer -Id 4a10679c-a8c6-4aa9-a418-1898f2b0198d
```

Gets the recording server with ID "4a10679c-a8c6-4aa9-a418-1898f2b0198d". Note
that when retrieving items by ID, it typically bypasses the local configuration
api cache. This means it guarantees an API call to the management server which may,
or may not be an advantage.

## PARAMETERS

### -HostName
Specifies the hostname of the recording server to retrieve, with support for wildcards.

```yaml
Type: String
Parameter Sets: ByHostname
Aliases: ComputerName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Id
Specifies the ID of the recording server to retrieve.

```yaml
Type: Guid
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the recording server to retrieve, with support for wildcards.

```yaml
Type: String
Parameter Sets: ByName
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

### System.String

### System.Guid

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.RecordingServer

## NOTES

These configuration api objects are cached in the PowerShell session. Additions,
removals, or changes to these objects outside of the current PowerShell session
may not be reflected until you execute the `Clear-VmsCache` cmdlet, login again,
or start a new PowerShell session.

## RELATED LINKS
