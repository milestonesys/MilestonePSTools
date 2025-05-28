---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MethodInfo/
schema: 2.0.0
---

# Get-MethodInfo

## SYNOPSIS

Gets MethodId's and their display names along with the TranslationId value to lookup language-specific display names.

## SYNTAX

```
Get-MethodInfo [[-MethodId] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets MethodId's and their display names along with the TranslationId value to lookup language-specific display names.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-MethodInfo
```

Gets all possible MethodInfo objects

### EXAMPLE 2

```powershell
Get-MethodInfo RemoveAlarmDefinition
```

Gets the MethodInfo for the RemoveAlarmDefinition MethodId

## PARAMETERS

### -MethodId

Specifies the MethodId property for the MethodInfo to retrieve.
This would usually come from the MethodIds property of a ConfigurationItem object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

Specifies the MethodId property for the MethodInfo to retrieve.
This would usually come from the MethodIds property of a ConfigurationItem object.

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.MethodInfo

## NOTES

## RELATED LINKS

[MIP SDK Docs - Configuration API](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)

