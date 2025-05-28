---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsSite/
schema: 2.0.0
---

# Get-VmsSite

## SYNOPSIS

Gets a `VideoOS.Platform.Item` object representing a Milestone XProtect management server.

## SYNTAX

```
Get-VmsSite [-ListAvailable] [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsSite` cmdlet can be used to identify which site is currently selected,
or which sites are available to be selected. When logged into a Milestone
Federated Hierarchy, many cmdlets only operate on the currently "selected" site
which will be the site that was directly logged in to using `Connect-Vms`.

To view and modify the configuration of resources on a child site, you can pipe
the output from `Get-VmsSite` to `Select-VmsSite`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsSite
```

This command returns a `[VideoOS.Platform.Item]` object representing the currently selected site.

### EXAMPLE 2

```powershell
Get-VmsSite -ListAvailable
```

This command lists all available sites in a Milestone Federated Hierarchy and works the same way as `Get-VmsSite -Name *`.

Note that it will include child sites even if you did not login to them by using `-IncludeChildSites` with `Connect-Vms`.

### EXAMPLE 3

```powershell
Get-VmsSite -Name Site2
```

This command command will return an object representing the site named "Site2". If no such site exists, it will return an
error because there is no wildcard in the Name parameter.

### EXAMPLE 4

```powershell
Get-VmsSite -Name DR-*
```

This command gets all Items representing sites where the display name begins with "DR-". If no matching sites exist, no
values are returned. Due to the presence of the wildcard character "*", there will be no error.

## PARAMETERS

### -ListAvailable
List all available sites in a Milestone Federated Hierarchy to choose from.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the display name of a site, with support for wildcards, used to filter the list of available sites.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Item

## NOTES

## RELATED LINKS
