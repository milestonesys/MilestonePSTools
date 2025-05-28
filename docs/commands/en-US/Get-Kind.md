---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-Kind/
schema: 2.0.0
---

# Get-Kind

## SYNOPSIS

Gets the display name and category of a Kind by Guid, or lists all known Kinds from VideoOS.Platform.Kind

## SYNTAX

### Convert
```
Get-Kind [-Kind] <Guid> [<CommonParameters>]
```

### List
```
Get-Kind [-List] [<CommonParameters>]
```

## DESCRIPTION

Most configuration items in the VMS are identified by "Kind" such as Camera, Server, and Microphone.
Some commands will return an obscure object like an FQID which the VMS knows how to use to locate the item in the configuration but there is very little meaningful identifiable information for a user in an FQID.

The Kind property is a Guid, and the VideoOS.Platform.Kind class can convert a Kind ID into a display name describing the Kind, and a category name such as VideoIn or AudioOut.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ItemState | ForEach-Object { $name = ($_.FQID | Get-VmsVideoOSItem).Name; $kind = $_.FQID | Get-Kind; Write-Output "$name is a $($kind.DisplayName) in category $($kind.Category)"}
```

Retrieve the Item name and write the name and ItemState

## PARAMETERS

### -Kind

Item.FQID.Kind value as a Guid

```yaml
Type: Guid
Parameter Sets: Convert
Aliases:

Required: True
Position: 0
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -List

List all known Kinds

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: True
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Guid

Item.FQID.Kind value as a Guid

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
