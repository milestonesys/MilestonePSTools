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

function Remove-VmsViewGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup[]]
        $ViewGroup,

        [Parameter()]
        [switch]
        $Recurse
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($vg in $ViewGroup) {
            if ($PSCmdlet.ShouldProcess($vg.DisplayName, "Remove ViewGroup")) {
                try {
                    $viewGroupFolder = [VideoOS.Platform.ConfigurationItems.ViewGroupFolder]::new($vg.ServerId, $vg.ParentPath)
                    $result = $viewGroupFolder.RemoveViewGroup($Recurse, $vg.Path)
                    if ($result.State -eq 'Success') {
                        $viewGroupFolder.ClearChildrenCache()
                    } else {
                        Write-Error $result.ErrorText
                    }
                } catch {
                    Write-Error $_
                }
            }
        }
    }
}

