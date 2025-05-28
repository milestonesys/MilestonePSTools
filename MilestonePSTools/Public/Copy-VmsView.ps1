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

function Copy-VmsView {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.View])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.View[]]
        $View,

        [Parameter(Mandatory)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $DestinationViewGroup,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($v in $View) {
            $newName = $v.Name
            if ($DestinationViewGroup.ViewFolder.Views.Name -contains $newName) {
                if ($Force) {
                    $existingView = $DestinationViewGroup.ViewFolder.Views | Where-Object Name -eq $v.Name
                    $existingView | Remove-VmsView -Confirm:$false
                } else {
                    while ($newName -in $DestinationViewGroup.ViewFolder.Views.Name) {
                        $newName = '{0} - Copy' -f $newName
                    }
                }
            }
            $params = @{
                Name = $newName
                LayoutDefinitionXml = $v.LayoutViewItems
                ViewItemDefinitionXml = $v.ViewItemChildItems.ViewItemDefinitionXml
            }
            $newView = $DestinationViewGroup | New-VmsView @params
            Write-Output $newView
        }
    }
}

