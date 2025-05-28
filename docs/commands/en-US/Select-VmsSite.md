---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Select-VmsSite/
schema: 2.0.0
---

# Select-VmsSite

## SYNOPSIS

Selects a Management Server "site" to perform further commands against.

## SYNTAX

### Site
```
Select-VmsSite -Site <Item> [<CommonParameters>]
```

### ByName
```
Select-VmsSite [[-Name] <String>] [<CommonParameters>]
```

### MainSite
```
Select-VmsSite [-MainSite] [<CommonParameters>]
```

## DESCRIPTION

The Select-VmsSite cmdlet allows you to switch between two or more sites in a Milestone Federated Architecture.
Most commands in this module operate against only the selected site, so a script intended to perform operations across two or more sites should be designed to enumerate through the available sites.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Select-VmsSite -MainSite
```

This command selects the site you initially connected to in the current Connect-Vms session.

Note: While this switch parameter is named MainSite, it is possible that the main site for this session is a child to another site.
But since you logged into this site, it is considered the main site for the duration of this PowerShell session.

### EXAMPLE 2

```powershell
Select-VmsSite -Name 'High School'
```

This command selects the first site named exactly 'High School'.

Note: It is possible for two sites to have the same display name.
This command selects the first site with the given name, and the order is not guaranteed.
It is recommended to uniquely name your sites.

### EXAMPLE 3

```powershell
Select-VmsSite -Name '*School'
```

This command gets the Item representing a site where the Name property equals "Site2".

### EXAMPLE 4

```powershell
Get-VmsSite -ListAvailable | ForEach-Object { $_ | Select-VmsSite; Get-VmsManagementServer | Select-Object Name, Version }
```

This snippet will enumerate all sites available to the current user, and retrieve the Management Server Name and Version.

Note: The % symbol in this command is shorthand for the Foreach-Object cmdlet, and $_ within the foreach code block is a reference to each instance of a site item returned from Get-VmsSite.

## PARAMETERS

### -MainSite
Select the original, parent site connected to with `Connect-Vms`.

```yaml
Type: SwitchParameter
Parameter Sets: MainSite
Aliases: MasterSite

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the display name of a site with support for wildcard characters.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Site
Specifies a `VideoOS.Platform.Item` object representing a site returned by `Get-VmsSite`.

```yaml
Type: Item
Parameter Sets: Site
Aliases: SiteItem

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.Item

Specifies an Item object representing a Management Server, typically returned by the Get-VmsSite cmdlet.

## OUTPUTS

### VideoOS.Platform.Item

## NOTES

## RELATED LINKS
