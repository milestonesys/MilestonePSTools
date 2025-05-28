---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsClientProfileAttributes/
schema: 2.0.0
---

# Set-VmsClientProfileAttributes

## SYNOPSIS
Updates a smart client profile with the provided attributes for one or more namespaces.

## SYNTAX

```
Set-VmsClientProfileAttributes -ClientProfile <ClientProfile> [[-Attributes] <IDictionary>]
 [-Namespace <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsClientProfileAttributes` cmdlet updates a smart client profile with
the provided attributes for one or more namespaces. This can be used to make
large or small configuration changes to one or more smart client profiles without
using `Export-VmsClientProfile` and `Import-VmsClientProfile` to export and import
changes from a file on disk.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
$general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
$general.ApplicationAutoLogin.Value = 'Unavailable'
Get-VmsClientProfile -DefaultProfile | Set-VmsClientProfileAttributes $general -Verbose
```

Set the "Auto-login" general setting in the default smart client profile to "Unavailable".

## PARAMETERS

### -Attributes
A dictionary or hashtable where the keys match one or more client profile attribute
names for a given namespace, and the values are either a string, or a `[pscustomobject]`
with a Value property of type `[string]` and optional Locked property of type
`[bool]`.

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientProfile
Specifies a smart client profile. The value can be either a ClientProfile object
as returned by Get-VmsClientProfile, or it can be the name of an existing
client profile.

```yaml
Type: ClientProfile
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Namespace
Specifies one or more existing client profile attribute namespaces. When the
dictionary provided for the `Attributes` parameter contains a key named `Namespace`
this namespace parameter can be omitted. If the namespace name isn't provided
in the attributes dictionary, then the Namespace parameter is required.

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

### VideoOS.Platform.ConfigurationItems.ClientProfile

## OUTPUTS

### None

## NOTES

## RELATED LINKS
