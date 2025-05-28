---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Update-RegisteredService/
schema: 2.0.0
---

# Update-RegisteredService

## SYNOPSIS

Updates Registered Service properties by sending the changes to the Management Server.

## SYNTAX

```
Update-RegisteredService -RegisteredService <ServiceURIInfo> [<CommonParameters>]
```

## DESCRIPTION

The `Update-RegisteredService` cmdlet updates Registered Service properties by sending the modified RegisteredService
object's properties to the Management Server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$logServer = Get-RegisteredService -ServiceType 3d6f1153-92ad-43f1-b467-9482ffd291b2
$logServer.UriArray.Clear()
$logServer.UriArray.Add('http://MyLogServer:22337/LogServer/')
$logServer | Update-RegisteredService
```

Get the log server registered service, if available, and set the uri to "http://mylogserver:22337/LogServer/".

## PARAMETERS

### -RegisteredService

Specifies a registered service object provided by the `Get-RegisteredService` cmdlet.

```yaml
Type: ServiceURIInfo
Parameter Sets: (All)
Aliases:

Required: True
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
