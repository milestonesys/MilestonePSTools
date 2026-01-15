# Copyright 2025 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Copy-ViewGroupFromJson {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [pscustomobject]
        $Source,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName,

        [Parameter()]
        [ValidateNotNull()]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $ParentViewGroup
    )

    process {
        if ($MyInvocation.BoundParameters.ContainsKey('NewName')) {
            ($source.Properties | Where-Object Key -eq 'Name').Value = $NewName
        }

        ##
        ## Clean duplicate views in export caused by config api bug
        ##

        $groups = [system.collections.generic.queue[pscustomobject]]::new()
        $groups.Enqueue($source)
        $views = [system.collections.generic.list[pscustomobject]]::new()
        while ($groups.Count -gt 0) {
            $group = $groups.Dequeue()
            $views.Clear()
            foreach ($v in ($group.Children | Where-Object ItemType -eq 'ViewFolder').Children) {
                if ($v.Path -notin (($group.Children | Where-Object ItemType -eq 'ViewGroupFolder').Children.Children | Where-Object ItemType -eq 'ViewFolder').Children.Path) {
                    $views.Add($v)
                } else {
                    Write-Verbose "Skipping duplicate view"
                }
            }
            if ($null -ne ($group.Children | Where-Object ItemType -eq 'ViewFolder').Children) {
                ($group.Children | Where-Object ItemType -eq 'ViewFolder').Children = $views.ToArray()
            }
            foreach ($childGroup in ($group.Children | Where-Object ItemType -eq 'ViewGroupFolder').Children) {
                $groups.Enqueue($childGroup)
            }
        }


        $rootFolder = Get-ConfigurationItem -Path /ViewGroupFolder
        if ($null -ne $ParentViewGroup) {
            $rootFolder = $ParentViewGroup.ViewGroupFolder | Get-ConfigurationItem
        }
        $newViewGroup = $null
        $stack = [System.Collections.Generic.Stack[pscustomobject]]::new()
        $stack.Push(([pscustomobject]@{ Folder = $rootFolder; Group = $source }))
        while ($stack.Count -gt 0) {
            $entry = $stack.Pop()
            $parentFolder = $entry.Folder
            $srcGroup = $entry.Group

            ##
            ## Create matching ViewGroup
            ##
            $invokeInfo = $parentFolder | Invoke-Method -MethodId 'AddViewGroup'
            foreach ($key in ($srcGroup.Properties | Where-Object IsSettable).Key) {
                $value = ($srcGroup.Properties | Where-Object Key -eq $key).Value
                ($invokeInfo.Properties | Where-Object Key -eq $key).Value = $value
            }
            $invokeResult = $invokeInfo | Invoke-Method -MethodId 'AddViewGroup'
            $props = ConvertPropertiesToHashtable -Properties $invokeResult.Properties
            if ($props.State.Value -ne 'Success') {
                Write-Error $props.ErrorText
            }
            $newViewFolder = Get-ConfigurationItem -Path "$($props.Path.Value)/ViewFolder"
            $newViewGroupFolder = Get-ConfigurationItem -Path "$($props.Path.Value)/ViewGroupFolder"
            if ($null -eq $newViewGroup) {
                $serverId = (Get-VmsManagementServer).ServerId
                $newViewGroup = [VideoOS.Platform.ConfigurationItems.ViewGroup]::new($serverId, $props.Path.Value)
            }

            ##
            ## Create all child views of the current view group
            ##
            foreach ($srcView in ($srcGroup.Children | Where-Object ItemType -eq ViewFolder).Children) {
                # Create new view based on srcView layout
                $invokeInfo = $newViewFolder | Invoke-Method -MethodId 'AddView'
                foreach ($key in ($invokeInfo.Properties | Where-Object { $_.IsSettable -and $_.Key -ne 'Id'}).Key) {
                    $value = ($srcView.Properties | Where-Object Key -eq $key).Value
                    ($invokeInfo.Properties | Where-Object Key -eq $key).Value = $value
                }
                $newView = $invokeInfo | Invoke-Method -MethodId 'AddView'

                # Rename view and update any other settable values
                foreach ($key in ($newView.Properties | Where-Object { $_.IsSettable -and $_.Key -ne 'Id'}).Key) {
                    $value = ($srcView.Properties | Where-Object Key -eq $key).Value
                    ($newView.Properties | Where-Object Key -eq $key).Value = $value
                }

                # Update all viewitems of new view to match srcView
                for ($i = 0; $i -lt $newView.Children.Count; $i++) {
                    foreach ($key in ($newView.Children[$i].Properties | Where-Object IsSettable).Key) {
                        $value = ($srcView.Children[$i].Properties | Where-Object Key -eq $key).Value
                        if ($key -eq 'ViewItemDefinitionXml') {
                            $value = $value -replace '^<viewitem id=".{36}"', ('<viewitem id="{0}"' -f (New-Guid).ToString().ToLower())
                        }
                        ($newView.Children[$i].Properties | Where-Object Key -eq $key).Value = $value
                    }
                }

                # Save changes to new view
                $invokeResult = $newView | Invoke-Method -MethodId 'AddView'
                $props = ConvertPropertiesToHashtable -Properties $invokeResult.Properties
                if ($props.State.Value -ne 'Success') {
                    Write-Error $props.ErrorText
                }
            }

            ##
            ## Get the new child ViewGroupFolder, and add all child view groups from the JSON object to the stack
            ##
            foreach ($childViewGroup in ($srcGroup.Children | Where-Object ItemType -eq ViewGroupFolder).Children) {
                $stack.Push(([pscustomobject]@{ Folder = $newViewGroupFolder; Group = $childViewGroup }))
            }
        }

        if ($null -ne $newViewGroup) {
            Write-Output $newViewGroup
        }
    }
}

function ConvertPropertiesToHashtable {
    param([VideoOS.ConfigurationApi.ClientService.Property[]]$Properties)

    $props = @{}
    foreach ($prop in $Properties) {
        $props[$prop.Key] = $prop
    }
    Write-Output $props
}

