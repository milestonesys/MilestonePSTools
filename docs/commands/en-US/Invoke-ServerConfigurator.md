---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Invoke-ServerConfigurator/
schema: 2.0.0
---

# Invoke-ServerConfigurator

## SYNOPSIS

Invokes the Milestone Server Configurator utility using command-line arguments

## SYNTAX

### EnableEncryption
```
Invoke-ServerConfigurator [-EnableEncryption] [-CertificateGroup <Guid>] -Thumbprint <String> [-Path <String>]
 [-PassThru] [<CommonParameters>]
```

### DisableEncryption
```
Invoke-ServerConfigurator [-DisableEncryption] [-CertificateGroup <Guid>] [-Path <String>] [-PassThru]
 [<CommonParameters>]
```

### ListCertificateGroups
```
Invoke-ServerConfigurator [-ListCertificateGroups] [-Path <String>] [<CommonParameters>]
```

### Register
```
Invoke-ServerConfigurator [-Register] [-AuthAddress <Uri>] [-OverrideLocalManagementServer] [-Path <String>]
 [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

The Server Configurator is the utility responsible for managing the registration of
Management Servers, Recording Servers and Data Collectors as well as the configuration of
certificates for Management/Recorder communication, Client/Recorder communication and
Mobile Server/Web Client/Mobile communication.

In the 2020 R3 release, command-line parameters were introduced for the Server Configurator
making it possible to automate registration and certificate configuration processes.
Since
PowerShell offers a more rich environment for discovering parameters and valid values as
well as more useful object-based output, this cmdlet was written to wrap the utility with
a PowerShell-friendly interface.

REQUIREMENTS  

- Does not require a VMS connection
- Requires elevated privileges (run as Administrator)

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-ServerConfigurator -ListCertificateGroups
```

Lists the available Certificate Groups such as 'Server certificate',
'Streaming media certificate' and 'Mobile streaming media certificate', and their ID's.

### EXAMPLE 2

```powershell
Invoke-ServerConfigurator -Register -AuthAddress http://MGMT -PassThru
```

Registers all local Milestone components with the authorization server at http://MGMT and
outputs a \[pscustomobject\] with the exit code, and standard output/error from the invocation
of the Server Configurator executable.

## PARAMETERS

### -AuthAddress

Specifies the address of the Authorization Server which is usually the Management Server
address.
A \[uri\] value is expected, but only the URI host value will be used.
The scheme
and port will be inferred based on whether encryption is enabled/disabled and is fixed to
port 80/443 as this is how Server Configurator is currently designed.

```yaml
Type: Uri
Parameter Sets: Register
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateGroup

Specifies the CertificateGroup \[guid\] identifying which component for which encryption
should be enabled or disabled. Omit this parameter to modify the encryption state
for all components managed by server configurator.

```yaml
Type: Guid
Parameter Sets: EnableEncryption, DisableEncryption
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableEncryption

Disable encryption for all components managed by server configurator, or only
for the CertificateGroup specified.

```yaml
Type: SwitchParameter
Parameter Sets: DisableEncryption
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableEncryption

Enable encryption for all components managed by server configurator, or only
for the CertificateGroup specified.

```yaml
Type: SwitchParameter
Parameter Sets: EnableEncryption
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListCertificateGroups

List the available certificate groups on the local machine.
Output will be a \[hashtable\]
where the keys are the certificate group names (which may contain spaces) and the values
are the associated \[guid\] id's.

```yaml
Type: SwitchParameter
Parameter Sets: ListCertificateGroups
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverrideLocalManagementServer
When using the `AuthAddress` parameter to specify a custom URL during
registration directly on the management server, supply this switch parameter and
serverconfigurator.exe will be invoked with the `/overridelocalmanagementserver`
argument.

You would do this when DNS name other than the management server's fully-qualified
domain name (FQDN) will be used to access the VMS. Note that "server" encryption
cannot be enabled, or disabled, once the management server DNS name has been
overridden. This is a limitation of serverconfigurator.exe. To enable server
encryption if it is currently disabled, or to disable it if it is currently
enabled, you must open the Server Configurator application, and click the "undo"
button on the address field in the "Register" activity tab.

```yaml
Type: SwitchParameter
Parameter Sets: Register
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

Specifies that the standard output from the Server Configurator utility should be written
after the operation is completed.
The output will include the following properties:
- StandardOutput
- StandardError
- ExitCode

```yaml
Type: SwitchParameter
Parameter Sets: EnableEncryption, DisableEncryption, Register
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the path to the Server Configurator utility.
Omit this path and the path will
be discovered using Get-RecorderConfig or Get-ManagementServerConfig by locating the
installation path of the Management Server or Recording Server and assuming the Server
Configurator is located in the same path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Register

Register all local components with the optionally specified AuthAddress.
If no
AuthAddress is provided, the last-known address will be used.

```yaml
Type: SwitchParameter
Parameter Sets: Register
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint

Specifies the thumbprint of the certificate to be used to encrypt communications with the
component designated by the CertificateGroup id.

```yaml
Type: String
Parameter Sets: EnableEncryption
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

## OUTPUTS

## NOTES

## RELATED LINKS
