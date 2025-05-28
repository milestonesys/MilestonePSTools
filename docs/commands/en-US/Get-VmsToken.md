---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsToken/
schema: 2.0.0
---

# Get-VmsToken

## SYNOPSIS

Gets the current token issued by the Management Server to this PowerShell session.

## SYNTAX

### CurrentSite (Default)
```
Get-VmsToken [<CommonParameters>]
```

### ServerId
```
Get-VmsToken [-ServerId <ServerId>] [<CommonParameters>]
```

### Site
```
Get-VmsToken [-Site <Item>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsToken` cmdlet returns the token issued by the Management Server for
the current user session. Tokens are used internally to verify a user or service
has been authenticated by the Management and is authorized to access resources.

Tokens are renewed in the background automatically, and expire in 4 hours by
default.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsToken
```

Get a token from the currently selected management server.

### EXAMPLE 2
```powershell
$svc = $recordingServer | Get-RecorderStatusService2
$token = $recordingServer | Get-VmsToken
$svc.GetRecorderStatus($token)
```

Create a RecorderStatusService2 client which can be used to retrieve detailed
server, storage, and device information from a recording server, retrieve a token
specifically for the site that recording server is from, regardless of the currently
selected site, and retrieve the recorder status using the token for authentication.

## PARAMETERS

### -ServerId
Specifies a `VideoOS.Platform.ServerId` used to determine which token to return
when used in a Milestone Federated Hierarchy. All configuration items like management
servers and cameras have a ServerId property, and all `VideoOS.Platform.Item` objects
returned by `Get-VmsVideoOSItem` have an FQID.ServerId property.

```yaml
Type: ServerId
Parameter Sets: ServerId
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Site
A value returned from `Get-VmsSite` can be used to indicate the site for which the
returned token should be valid.

```yaml
Type: Item
Parameter Sets: Site
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
