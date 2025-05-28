---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsModuleConfig/
schema: 2.0.0
---

# Set-VmsModuleConfig

## SYNOPSIS
Used to change MilestonePSTools module settings.

## SYNTAX

### InputObject
```
Set-VmsModuleConfig [-InputObject] <ModuleSettings> [<CommonParameters>]
```

### Options
```
Set-VmsModuleConfig [-EnableTelemetry <Boolean>] [-LogTelemetry <Boolean>] [-EnableDebugLogging <Boolean>]
 [-ProxyPoolSize <Int32>] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsModuleConfig` cmdlet is used to change MilestonePSTools module settings. The settings available include
telemetry, debug logging, hardware acceleration behavior, and more.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Set-VmsModuleConfig -EnableDebugLogging $false -EnableTelemetry $false
```

Disable debug logging and telemetry.

## PARAMETERS

### -EnableDebugLogging
Specifies whether or not to log debug messages to `ProgramData\Milestone\MIPSDK\`.

```yaml
Type: Boolean
Parameter Sets: Options
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableTelemetry
Specifies whether anonymous telemetry is sent to Azure Application Insights. See [about_Telemetry](./about_Telemetry.md)
for more information.

```yaml
Type: Boolean
Parameter Sets: Options
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Specifies a modified version of the ModuleSettings object returned by `Get-VmsModuleConfig`.

```yaml
Type: ModuleSettings
Parameter Sets: InputObject
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -LogTelemetry
Specifies whether or not to log a JSON object representing all telemetry sent to Azure Application Insights. See
[about_Telemetry](./about_Telemetry.md) for more information.

```yaml
Type: Boolean
Parameter Sets: Options
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyPoolSize
Specifies how many WCF client proxies to create for each type. A value of two or more _may_ improve performance for
operations that are not limited by serialization of commands by the management server.

```yaml
Type: Int32
Parameter Sets: Options
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### MilestonePSTools.Models.ModuleSettings

## OUTPUTS

### None
## NOTES

## RELATED LINKS

[about_Telemetry](./about_Telemetry.md)

