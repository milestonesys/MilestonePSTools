---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-RegisteredService/
schema: 2.0.0
---

# Remove-RegisteredService

## SYNOPSIS

Removes a registered service entry from a Milestone XProtect VMS.

## SYNTAX

```
Remove-RegisteredService [-RegisteredService <ServiceURIInfo>] [<CommonParameters>]
```

## DESCRIPTION

The `Remove-RegisteredService` cmdlet removes a registered service entry from a Milestone XProtect VMS. You can see
a list of registered services in the Management Client under Tools > Registered Services.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-RegisteredService | Out-GridView -OutputMode Single | Remove-RegisteredService
```

Prompts to select a registered service entry, and then removes the selected registered service.

## PARAMETERS

### -RegisteredService

Specifies a registered service entry returned by `Get-RegisteredService`.

```yaml
Type: ServiceURIInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: VideoOS.Platform.Configuration+ServiceURIInfo
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.Configuration+ServiceURIInfo

## OUTPUTS

### None

## NOTES

## RELATED LINKS
