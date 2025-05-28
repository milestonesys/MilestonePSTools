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

function New-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param (
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $Parent,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $vgFolder = (Get-VmsManagementServer).ViewGroupFolder
        if ($null -ne $Parent) {
            $vgFolder = $Parent.ViewGroupFolder
        }
        if ($Force) {
            $vg = $vgFolder.ViewGroups | Where-Object DisplayName -eq $Name
            if ($null -ne $vg) {
                Write-Output $vg
                return
            }
        }
        try {
            $result = $vgFolder.AddViewGroup($Name, $Description)
            if ($result.State -eq 'Success') {
                $vgFolder.ClearChildrenCache()
                Get-VmsViewGroup -Name $Name -Parent $Parent
            } else {
                Write-Error $result.ErrorText
            }
        } catch {
            if ($Force -and $_.Exception.Message -like '*Group name already exist*') {
                Get-VmsViewGroup -Name $Name
            } else {
                Write-Error $_
            }
        }
    }
}

