---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsVideoOSItem/
schema: 2.0.0
---

# Get-VmsVideoOSItem

## SYNOPSIS
Gets `[VideoOS.Platform.Item]` objects of the specified Kind.

## SYNTAX

### GetItemByFQID (Default)
```
Get-VmsVideoOSItem -Fqid <FQID> [<CommonParameters>]
```

### GetItem
```
Get-VmsVideoOSItem [-ServerId <ServerId>] -Id <Guid> -Kind <Guid> [<CommonParameters>]
```

### GetItems
```
Get-VmsVideoOSItem [-Kind <Guid>] [-ItemHierarchy <ItemHierarchy>] [-FolderType <FolderType>]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsVideoOSItem\` cmdlet gets `[VideoOS.Platform.Item]` objects of by calling
one of the GetItem* methods on the `[VideoOS.Platform.Configuration]::Instance`
class from the MIP SDK nuget packages.

The MIP SDK returns one specific item by ID, or an array of items, each of which
may have zero or more child items. This cmdlet will flatten the hierarchy and return
a flat collection of items.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```powershell
Get-VmsVideoOSItem -Kind Camera -FolderType No
```

Returns all enabled camera items.

### EXAMPLE 2
```powershell
Get-VmsVideoOSItem -Kind Hardware -FolderType No
```

Returns all hardware items.

### EXAMPLE 3
```powershell
Get-VmsVideoOSItem -Kind Server
```

Returns all "Server" items including management servers and recording servers.

### EXAMPLE 4
```powershell
Get-VmsVideoOSItem
```

Returns a flat list of all items returned by `[VideoOS.Platform.Configuration]::Instance.GetItems()`
based on the system hierarchy.

### EXAMPLE 5
```powershell
Get-VmsVideoOSItem -ItemHierarchy UserDefined
```

Returns a flat list of all items returned by `[VideoOS.Platform.Configuration]::Instance.GetItems()`
based on the user-defined hierarchy which may not include all cameras if some
cameras are not added to a camera group for example.

## PARAMETERS

### -FolderType
Specifies an optional FolderType value of No, SystemDefined, or UserDefined.
If you are retrieving camera, or hardware objects, you should set FolderType
to "No" unless you also want to receive camera groups and hardware folders.

```yaml
Type: FolderType
Parameter Sets: GetItems
Aliases:
Accepted values: No, SystemDefined, UserDefined

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fqid
Specifies the FQID for a single configuration item. The MIP SDK uses FQIDs or
Fully Qualified Identifiers to resolve items based on their IDs, their "Kind"
such as "Camera" or "Server", and their ServerIds which usually represents the parent
recording server or management server.

An FQID can be created manually when necessary, and it can also be found on any
`VideoOS.Platform.Item` object returned by `Get-VmsVideoOSItem`.

```yaml
Type: FQID
Parameter Sets: GetItemByFQID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Id
Specifies the guid of a single configuration item.

```yaml
Type: Guid
Parameter Sets: GetItem
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ItemHierarchy
Specifies which item hierarchy (or hierarchies) to return items from.

```yaml
Type: ItemHierarchy
Parameter Sets: GetItems
Aliases:
Accepted values: UserDefined, SystemDefined, Both

Required: False
Position: Named
Default value: SystemDefined
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Kind
Specifies the ID or name of an item "Kind". For a list of supported values, run
`[VideoOS.Platform.Kind] | Get-Member -Static -MemberType Property | Where-Object Definition -match 'static guid'`

```yaml
Type: Guid
Parameter Sets: GetItem
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Guid
Parameter Sets: GetItems
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerId
Specifies a ServerId from an existing configuration item such as a management server,
recording server, or camera. Providing the ServerId can help to find and return the
matching configuration item faster when used in a Milestone Federated Hierarchy.

```yaml
Type: ServerId
Parameter Sets: GetItem
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Item

## NOTES

## RELATED LINKS
