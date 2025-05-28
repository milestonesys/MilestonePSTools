---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Copy-VmsView/
schema: 2.0.0
---

# Copy-VmsView

## SYNOPSIS
Copies one or more XProtect Smart Client views to a destination view group.

## SYNTAX

```
Copy-VmsView [-View] <View[]> [-DestinationViewGroup] <ViewGroup> [-Force] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Copies one or more XProtect Smart Client views to a destination view group. The
elements copied include the name, description, layout, and all view item
definitions.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$view = $viewGroup | Get-VmsViewGroup -Recurse | Get-VmsView | Out-GridView -OutputMode Single
$newViewGroup = New-VmsViewGroup -Name 'MilestonePSTools' -Force | New-VmsViewGroup -Name 'Example 1' -Force
$view | Copy-VmsView -Destination $newViewGroup -PassThru
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of top-level view groups. After selecting view group, a list of views in
that view group are presented.

Once a view is selected, a new view group named 'MilestonePSTools' with a subgroup
named 'Example 1' is created. A copy of the selected view is then placed in the
new subgroup under the new top-level group 'MilestonePSTools'.

## PARAMETERS

### -DestinationViewGroup
Specifies the view group within which a copy of the specified view will be created.

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrite a view with the same name if it exists. If a view exists
and the -Force switch is omitted, the name of the copy will be appended with " - Copy".

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
Specifies that the newly created view should be returned to the pipeline.

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

### -View
Specifies the source view to be copied.

```yaml
Type: View[]
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

### VideoOS.Platform.ConfigurationItems.View[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.View

## NOTES

## RELATED LINKS
