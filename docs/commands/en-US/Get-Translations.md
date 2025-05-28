---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-Translations/
schema: 2.0.0
---

# Get-Translations

## SYNOPSIS

Gets a translation table mapping internal property keys or guids to a language-specific display name

## SYNTAX

```
Get-Translations [[-LanguageId] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets a translation table mapping internal property keys or guids to a language-specific display name.

This is specifically useful when you need to get a display name, or a non-English translation, for a property where a translationId is present.

Note that the GetTranslations command appears to fall back to en-US when no matching language code is available.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Translations es-ES
```

Invokes the AddUserDefinedEvent method which returns a ConfigurationItem of type InvokeInfo.
Fill out the Name property of this ConfigurationItem and resend to the Invoke-Method command to create a new User Defined Event.

## PARAMETERS

### -LanguageId

Specifies the language ID string such as en-US, in order to retrieve the appropriate translations

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: En-US
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS

[MIP SDK Docs - Configuration API](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)

