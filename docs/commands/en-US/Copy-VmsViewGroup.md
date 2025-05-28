---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Copy-VmsViewGroup/
schema: 2.0.0
---

# Copy-VmsViewGroup

## SYNOPSIS
Copies one or more XProtect Smart Client view groups.

## SYNTAX

```
Copy-VmsViewGroup [-ViewGroup] <ViewGroup[]> [[-DestinationViewGroup] <ViewGroup>] [-Force] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION
Copies one or more XProtect Smart Client view groups to another top-level view
group, or as a child group to a specified destination view group.

If a view group with the same name already exists, the string " - Copy" will be
appended repeatedly until the new name of the top-level view group is unique. The
entire view group and view hierarchy will be duplicated in the destination view
group.

Permissions from the source view group will not be copied to the destination.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$newViewGroup = $viewGroup | Copy-VmsViewGroup -PassThru
$newViewGroup
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of top-level view groups. After selecting view group, a copy of the view
group is created. Both the source and destination view groups will be top-level
view groups. The copy will be named the same, as the original, except the text
" - Copy" will be appended to the end of the name.

### Example 2
```powershell
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$subgroup = $viewGroup | Get-VmsViewGroup | Select-Object -First 1
$destination = New-VmsViewGroup -Name 'MilestonePSTools' -Force |
               New-VmsViewGroup -Name 'Subgroup' -Force
$subGroup | Copy-VmsViewGroup -DestinationViewGroup $destination -PassThru
```

The first subgroup from the selected top-level view group is copied to a subgroup
of a new top-level view group named "MilestonePSTools", demonstrating that both your
source, and destination view groups can be child view groups if needed.

## PARAMETERS

### -DestinationViewGroup
Specifies an optional destination view group. When omitted, the selected view
group will be copied to the root folder as a top-level view group.

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that if a view group with the same name exists in the destination view
group, the existing view group should be overwritten as long as the ID is different
than the source view group. This is likely to throw an error until a Configuration
API bug is resolved on the Management Server in 2022 R2, or via a cumulative patch
for older versions of the VMS.

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

### -PassThru
Specifies that the new view group copy should be returned to the pipeline.

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

### -ViewGroup
Specifies the source view group to be copied.

```yaml
Type: ViewGroup[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

## NOTES

## RELATED LINKS
