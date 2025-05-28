---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsView/
schema: 2.0.0
---

# New-VmsView

## SYNOPSIS
Creates a new view as a child item of the specified XProtect Smart Client view group.

## SYNTAX

### Default (Default)
```
New-VmsView -ViewGroup <ViewGroup> [-Name] <String> [[-Cameras] <Camera[]>] [-StreamName <String>]
 [<CommonParameters>]
```

### Custom
```
New-VmsView -ViewGroup <ViewGroup> [-Name] <String> [[-Cameras] <Camera[]>] [-Columns <Int32>] [-Rows <Int32>]
 [<CommonParameters>]
```

### Advanced
```
New-VmsView -ViewGroup <ViewGroup> [-Name] <String> [[-Cameras] <Camera[]>] [-LayoutDefinitionXml <String>]
 [-ViewItemDefinitionXml <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new XProtect Smart Client view in the specified view group and places cameras
into the view if one or more camera objects are provided.

Views have a complex layout defined in XML, and this command offers advanced users
an easy way to create new views with their own custom layout and view item
definitions. However, the command also enables simple view creation without
the need to construct or manipulate XML data.

The default parameter set will accept a collection of cameras, and automatically
build a view with enough columns and rows. The simple layout generation has simple
logic where the number of columns and rows will always be equal.

If you pass in four cameras, you will receive a 2x2 view layout and all view
items will receive a camera. And if you pass in 5 cameras, a 3x3 view layout will
be created, and only the first 5 view items will receive a camera, leaving four
empty view items.

The custom parameter set will let you specify the cameras, and a number of columns
and rows. The layout will then be generated for you and all cameras will be placed
in the view if there are enough view items. If you pass in 10 cameras but specify
only a 3x2 view layout, then the first 6 cameras will fill the view and the last
four will be discarded with a warning.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$topViewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$newViewGroup = $topViewGroup | New-VmsViewGroup -Name 'New-VmsView Test'
$cameras = Select-Camera -AllowFolders
$newView = $newViewGroup | New-VmsView -Name 'Example 1' -Camera $cameras
$newView

<# OUTPUT
  DisplayName ViewSize Shortcut Id                          LastModified
  ----------- -------- -------- --                          ------------
  Example 1   25                184AB678-C9DC-4149-B925-... 2/18/2022 3:53:34 PM
#>
```

After ensuring there is an open connection to the Management Server, we prompt
for a view group selection, and then create a child group in the selected view
group named "New-VmsView Test".

Then, we prompt for a selection of cameras to place in the view. Inside the new
view group, we create a new view named "Example 1" large enough for all cameras
and place the selected cameras into the view.

The new view object is then displayed in the terminal. There are more properties
available on the view object than are displayed by default - these are only the
most interesting and display-friendly properties.

### Example 2
```powershell
function BuildViewsFromCameraGroups {
    param(
        [VideoOS.Platform.ConfigurationItems.ViewGroup]$StartingGroup,
        [VideoOS.Platform.ConfigurationItems.CameraGroup[]]$CameraGroups,
        [int]$MaxViewSize = 4
    )

    Clear-VmsCache
    $ms = Get-VmsManagementServer

    $stack = [system.collections.generic.stack[hashtable]]::new()
    if ($null -eq $CameraGroups) {
        $CameraGroups = $ms.CameraGroupFolder.CameraGroups
    }
    foreach ($group in $CameraGroups) {
        $stack.Push(
            @{
                ParentViewGroup = $StartingGroup
                CameraGroup = $group
            }
        )
    }

    while ($stack.Count -gt 0) {
        $entry = $stack.Pop()
        $vgParams = @{
            Name = $entry.CameraGroup.Name
            Parent = $entry.ParentViewGroup
            Force = $true
        }
        $viewGroup = New-VmsViewGroup @vgParams

        if ($entry.CameraGroup.CameraFolder.Cameras.Count -gt 0) {
            for ($i = 0; $i -lt $entry.CameraGroup.CameraFolder.Cameras.Count; $i += $MaxViewSize) {
                $start = $i
                $end   = [math]::min($i + $MaxViewSize, $entry.CameraGroup.CameraFolder.Cameras.Count) - 1
                $viewName = if ($start -eq 0 -and $end -eq $entry.CameraGroup.CameraFolder.Cameras.Count - 1) {
                    $viewGroup.DisplayName
                } else {
                    '{0} {1}' -f $viewGroup.DisplayName, (($i / $MaxViewSize) + 1)
                }
                $null = $viewGroup | New-VmsView -Name $viewName -Camera $entry.CameraGroup.CameraFolder.Cameras[$start..$end]
            }
        }

        foreach ($childGroup in $entry.CameraGroup.CameraGroupFolder.CameraGroups) {
            $stack.Push(
                @{
                    ParentViewGroup = $viewGroup
                    CameraGroup = $childGroup
                }
            )
        }
    }
}

Connect-Vms -ShowDialog -AcceptEula
$cameraGroups = Select-VideoOSItem -AllowFolders -HideServerTab -Kind ([VideoOS.Platform.Kind]::Camera) | Foreach-Object {
    try {
        $item = $_
        [VideoOS.Platform.ConfigurationItems.CameraGroup]::new($_.FQID.ServerId, "CameraGroup[$($item.FQID.ObjectId)]")
    } catch {
        Write-Error "Camera Group '$($item.Name)' not found."
    }
}
$viewGroupName = Read-Host -Prompt "New view group name"
$viewgroup = New-VmsViewGroup -Name $viewGroupName -Force
BuildViewsFromCameraGroups -StartingGroup $viewgroup -CameraGroups $cameraGroups -MaxViewSize 9
```

This example prompts the user to login to the Management Server, and then select
one or more camera groups. After receiving a new view group name from a prompt
at the terminal, those camera groups are used as templates to generate view
groups and views in a new top-level view group.

## PARAMETERS

### -Cameras
Specifies one or more cameras to place into the view.

```yaml
Type: Camera[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Columns
Specifies the number of columns the view should have. Think of columns and rows
like a spreadsheet where each cell can contain a view item like a camera, map,
or other type of view item.

```yaml
Type: Int32
Parameter Sets: Custom
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LayoutDefinitionXml
Specifies the XML definition for the view layout. This is only needed if
automating the creation of views with complex view layouts that cannot be
accomplished by defining row and column counts. It is recommended to manually
create a view in XProtect Smart Client, and then inspect the LayoutDefinitionXml for that
view to see what format and information is required.

```yaml
Type: String
Parameter Sets: Advanced
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the new view. Names must be unique within a specific view
group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Rows
Specifies the number of rows the view should have. Think of columns and rows
like a spreadsheet where each cell can contain a view item like a camera, map,
or other type of view item.

```yaml
Type: Int32
Parameter Sets: Custom
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StreamName
Specifies the display name of the camera stream to use for live viewing by default.
If no matching stream can be found for a given camera, the default live stream will be used.

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ViewGroup
Specifies the parent view group within which the new view will be created.

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ViewItemDefinitionXml
Specifies the XML definition for each view item in the view. This is only needed
if automating the creation of views that have non-camera elements in them. It is
recommended to manually create a view in XProtect Smart Client, and then inspect the
ViewItemDefinitionXml for that view to see what format and information is required.

```yaml
Type: String[]
Parameter Sets: Advanced
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
