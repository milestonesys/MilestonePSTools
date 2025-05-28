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

function Remove-VmsView {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.View])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.View[]]
        $View
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($v in $View) {
            if ($PSCmdlet.ShouldProcess($($v.Name), "Remove view")) {
                $viewFolder = [VideoOS.Platform.ConfigurationItems.ViewFolder]::new($v.ServerId, $v.ParentPath)
                $result = $viewFolder.RemoveView($v.Path)
                if ($result.State -ne 'Success') {
                    Write-Error $result.ErrorText
                }
            }
        }
    }
}

