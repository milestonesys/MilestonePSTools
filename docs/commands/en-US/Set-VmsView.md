---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsView/
schema: 2.0.0
---

# Set-VmsView

## SYNOPSIS
Sets properties of an existing XProtect Smart Client view.

## SYNTAX

```
Set-VmsView [-View] <View> [[-Name] <String>] [[-Description] <String>] [[-Shortcut] <Int32>]
 [[-ViewItemDefinition] <String[]>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets properties of an existing view.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
foreach ($view in Get-VmsView) {
    $updateView = $false
    foreach ($viewItem in $view.ViewItemChildItems) {
        $xml = [xml]$viewItem.ViewItemDefinitionXml
        if ($xml.viewitem.type -ne 'VideoOS.RemoteClient.Application.Data.ContentTypes.CameraContentType.CameraViewItem, VideoOS.RemoteClient.Application') {
            continue
        }
        $attribNode = $xml.viewitem.iteminfo.Attributes['imagequality']
        if ($null -ne $attribNode -and $attribNode.Value -ne '100') {
            $attribNode.Value = '100'
            $updateView = $true
        }
        $propNode = $xml.viewitem.properties.property | Where-Object name -eq 'imagequality'
        if ($null -ne $propNode -and $propNode.Value -ne '100') {
            $propNode.Value = '100'
            $updateView = $true
        }
        $viewItem.ViewItemDefinitionXml = $xml.OuterXml
    }

    if ($updateView) {
        $view | Set-VmsView -ViewItemDefinition $view.ViewItemChildItems.ViewItemDefinitionXml -Verbose
    }
}
```

After ensuring there is an open connection to the Management Server, we enumerate
through all views in all public view groups (and the current user's private view group)
recursively. If any views are found with one or more view items with an image quality
other than "Full", the quality is reset to 100 or "Full" and the view is updated.

## PARAMETERS

### -Description
Specifies a new description for the view.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new name of the view.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the modified view should be passed through to the pipeline or out
to the terminal.

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

### -Shortcut
Specifies a numeric shortcut for accessing the view in XProtect Smart Client using the
keyboard shortcut "* [shortcut] ENTER".

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -View
Specifies the view to be updated. It is recommended to use Get-VmsView to
retrieve a value for this parameter.

```yaml
Type: View
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ViewItemDefinition
Specifies an array of strings containing the ViewItemDefinitionXml content to place
in the respective view item within the view. It is recommended to inspect existing
views using Get-VmsView to determine the necessary XML schema for the view item
definitions.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### VideoOS.Platform.ConfigurationItems.View

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.View

## NOTES

## RELATED LINKS
