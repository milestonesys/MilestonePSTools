---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-PlatformItem/
schema: 2.0.0
---

# Get-PlatformItem

## SYNOPSIS

Gets a VideoOS.Platform.Item object representing a configuration item

## SYNTAX

### ByFQID (Default)
```
Get-PlatformItem [-Fqid] <FQID> [<CommonParameters>]
```

### BySearch
```
Get-PlatformItem [[-SearchText] <String>] [[-MaxResultCount] <Int32>] [[-TimeoutSeconds] <Int32>]
 [<CommonParameters>]
```

### ByKind
```
Get-PlatformItem [-Kind] <Guid> [<CommonParameters>]
```

### ListAvailable
```
Get-PlatformItem [-ListAvailable] [[-Hierarchy] <ItemHierarchy>] [-IncludeFolders] [<CommonParameters>]
```

### ById
```
Get-PlatformItem [[-Id] <Guid>] [<CommonParameters>]
```

## DESCRIPTION

The Item is a generic object representing a configuration item in the VMS.
An Item might represent a camera, hardware, server, or generic event.
This cmdlet is especially useful for converting an FQID from Get-ItemState into an item, in order to get the device name faster than possible using Configuration API commands like Get-ConfigurationItem.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ItemState | ForEach-Object { $name = ($_.FQID | Get-PlatformItem).Name; "$name - $($_.State)" }
```

Retrieve the Item name and write the name and ItemState

### EXAMPLE 2

```powershell
Get-PlatformItem -ListAvailable
```

Retrieve all configuration items from the VMS which are not considered Parent objects

### EXAMPLE 3

```powershell
$kind = (Get-Kind -List | Where-Object DisplayName -eq Transact).Kind; Get-PlatformItem -Kind $kind
```

Retrieve all Transact sources configured in the VMS.
First we get the GUID associated with 'Kind.Transact' then we pass that GUID into the Get-PlatformItem -Kind parameter.
You can then inspect the Properties collection associated with the returned Items.

## PARAMETERS

### -Fqid

VideoOS.Platform.FQID of a Milestone configuration Item

```yaml
Type: FQID
Parameter Sets: ByFQID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Hierarchy

Filter the results based on the system hierarchy, user-defined hierarchies like camera groups, or both.

Possible values: UserDefined, SystemDefined, Both

```yaml
Type: ItemHierarchy
Parameter Sets: ListAvailable
Aliases:

Required: False
Position: 1
Default value: SystemDefined
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the Guid identifier for an item

Use only when you have an ID but no knowledge of the device type.

```yaml
Type: Guid
Parameter Sets: ById
Aliases: ObjectId

Required: False
Position: 1
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeFolders

Only child objects with no child items of their own are included by default.
Example: Cameras and user-defined events.

```yaml
Type: SwitchParameter
Parameter Sets: ListAvailable
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind

Specifies the GUID constant for the Kind of object you want to return

```yaml
Type: Guid
Parameter Sets: ByKind
Aliases:

Required: True
Position: 1
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListAvailable

Enumerate all Items in the configuration

```yaml
Type: SwitchParameter
Parameter Sets: ListAvailable
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxResultCount

Specifies the maximum number of results allowed.
When a search returns more than this, it is considered an error.
Default = 1

```yaml
Type: Int32
Parameter Sets: BySearch
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchText

Specifies the name or string to search for

```yaml
Type: String
Parameter Sets: BySearch
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TimeoutSeconds

Specifies the timeout in seconds before a search is terminated.
Default = 60 seconds

```yaml
Type: Int32
Parameter Sets: BySearch
Aliases:

Required: False
Position: 3
Default value: 60
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.FQID

VideoOS.Platform.FQID of a Milestone configuration Item

### System.String

Specifies the name or string to search for

### System.Guid

Specifies the GUID constant for the Kind of object you want to return

## OUTPUTS

### VideoOS.Platform.Item

## NOTES

## RELATED LINKS
