---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsStorage/
schema: 2.0.0
---

# Add-VmsStorage

## SYNOPSIS

Adds a new live Recording Storage configuration to a Recording Server

## SYNTAX

### WithoutEncryption (Default)
```
Add-VmsStorage -RecordingServer <RecordingServer> -Name <String> [-Description <String>] -Path <String>
 [-Retention <TimeSpan>] -MaximumSizeMB <Int32> [-Default] [-EnableSigning] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### WithEncryption
```
Add-VmsStorage -RecordingServer <RecordingServer> -Name <String> [-Description <String>] -Path <String>
 [-Retention <TimeSpan>] -MaximumSizeMB <Int32> [-Default] [-EnableSigning] -EncryptionMethod <String>
 -Password <SecureString> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Adds a new live Recording Storage configuration to a Recording Server

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
<example usage>
```

Explanation of what the example does

## PARAMETERS

### -Default

Specifies whether this storage should become the default storage for all devices added to the Recording
Server in the future.

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

### -Description

Specifies the optional description of the storage configuration.

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

### -EnableSigning

Specifies whether digital signatures should be used to sign recordings on the storage configuration.

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

### -EncryptionMethod

Specifies which encryption method should be used.
If no encryption is desired, omit this parameter.

```yaml
Type: String
Parameter Sets: WithEncryption
Aliases:
Accepted values: Light, Strong

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumSizeMB

Specifies the maximum size for the live storage before data should be archived or deleted.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of the storage configuration.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password

Specifies the password used to create the encryption key to use when EncryptionMethod is specified.

```yaml
Type: SecureString
Parameter Sets: WithEncryption
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the path under which the new storage folder will be created on the Recording Server or UNC
path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServer

Specifies the Recording Server to which the storage configuration should be added.
This should be a
RecordingServer object such as that returned by the Get-VmsRecordingServer cmdlet.

```yaml
Type: RecordingServer
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Retention

Specifies the retention, as a `[timespan]`, after which the recordings will be deleted, or archived if
you choose to add an archive storage to the new storage configuration after it is created.

REQUIREMENTS  

- Minimum: 00:01:00, Maximum: 365000.00:00:00

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
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

### VideoOS.Platform.ConfigurationItems.Storage

## NOTES

## RELATED LINKS
