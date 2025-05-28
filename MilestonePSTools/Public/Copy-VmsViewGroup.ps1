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

function Copy-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup[]]
        $ViewGroup,

        [Parameter()]
        [ValidateNotNull()]
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
        foreach ($vg in $ViewGroup) {
            $source = $vg | Get-ConfigurationItem -Recurse | ConvertTo-Json -Depth 100 -Compress | ConvertFrom-Json
            $destFolder = (Get-VmsManagementServer).ViewGroupFolder
            if ($MyInvocation.BoundParameters.ContainsKey('DestinationViewGroup')) {
                $destFolder = $DestinationViewGroup.ViewGroupFolder
            }
            $destFolder.ClearChildrenCache()
            $nameProp = $source.Properties | Where-Object Key -eq 'Name'
            if ($nameProp.Value -in $destFolder.ViewGroups.DisplayName -and $Force) {
                $existingGroup = $destFolder.ViewGroups | Where-Object DisplayName -eq $nameProp.Value
                if ($existingGroup.Path -ne $source.Path) {
                    Remove-VmsViewGroup -ViewGroup $existingGroup -Recurse
                }
            }
            while ($nameProp.Value -in $destFolder.ViewGroups.DisplayName) {
                $nameProp.Value = '{0} - Copy' -f $nameProp.Value
            }
            $params = @{
                Source = $source
            }
            if ($MyInvocation.BoundParameters.ContainsKey('DestinationViewGroup')) {
                $params.ParentViewGroup = $DestinationViewGroup
            }
            $newViewGroup = Copy-ViewGroupFromJson @params
            if ($PassThru) {
                Write-Output $newViewGroup
            }
        }
    }
}

