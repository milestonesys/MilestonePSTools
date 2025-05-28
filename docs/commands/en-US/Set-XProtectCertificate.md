---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-XProtectCertificate/
schema: 2.0.0
---

# Set-XProtectCertificate

## SYNOPSIS

Sets the certificate to use for a given Milestone XProtect VMS service

## SYNTAX

### Disable
```
Set-XProtectCertificate -VmsComponent <String> [-Disable] [-ServerConfiguratorPath <String>] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Enable
```
Set-XProtectCertificate -VmsComponent <String> -Thumbprint <String> [-UserName <String>]
 [-ServerConfiguratorPath <String>] [-RemoveOldCert] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Sets the certificate to use for a given Milestone XProtect VMS service.
Compatible Milestone
components include XProtect Management Server, Recording Server, and Mobile Server.

The Milestone Server Configurator CLI is used to apply the certificate, and CLI support was
introduced in version 2020 R3.
If you're running an older version of Milestone XProtect
software, you must upgrade to at least version 2020 R3 to use this function.

REQUIREMENTS  

- Does not require a VMS connection
- Requires elevated privileges (run as Administrator)

## EXAMPLES

### EXAMPLE 1

```powershell
Set-XProtectCertificate -VmsComponent MobileServer -Thumbprint $thumbprint -RemoveOldCert -Force
```

Sets the Milestone Mobile Server to use the certificate with thumbprint matching the string in the $thumbprint variable
and if successfull, it removes any other certificates with a matching subject name from the Cert:\LocalMachine\My
certificate store.
Since the Force switch is provided, the Server Configurator will be closed if it's currently open.

### EXAMPLE 2

```powershell
Set-XProtectCertificate -VmsComponent MobileServer -Disable -Force
```

Kills the Server Configurator process if it's currently running, then disables encryption for the Milestone Mobile Server.

## PARAMETERS

### -Disable

Specifies that encryption for the specified Milestone XProtect service should be disabled

```yaml
Type: SwitchParameter
Parameter Sets: Disable
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Specifies that the Server Configurator process should be terminated if it's currently running

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveOldCert

Specifies that all certificates issued to

```yaml
Type: SwitchParameter
Parameter Sets: Enable
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerConfiguratorPath

Specifies the path to the Milestone Server Configurator executable.
The default location is C:\Program Files\Milestone\Server Configurator\ServerConfigurator.exe

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C:\Program Files\Milestone\Server Configurator\ServerConfigurator.exe
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint

Specifies the thumbprint of the certificate to apply to Milestone XProtect service

```yaml
Type: String
Parameter Sets: Enable
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserName

Specifies the Windows user account for which read access to the private key is required

```yaml
Type: String
Parameter Sets: Enable
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VmsComponent

Specifies the Milestone component on which to update the certificate
- Server: Applies to communication between Management Server and Recording Server, as well as client connections to the HTTPS port for the Management Server.
- StreamingMedia: Applies to all connections to Recording Servers.
Typically on port 7563.
- MobileServer: Applies to HTTPS connections to the Milestone Mobile Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Server, StreamingMedia, MobileServer, EventServer

Required: True
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

## OUTPUTS

## NOTES

Use the Verbose switch to see the command-line arguments provided to the Server Configurator utility.

## RELATED LINKS
