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

function Remove-VmsBasicUser {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[BasicUser]])]
        [MipItemTransformation([BasicUser])]
        [BasicUser[]]
        $InputObject
    )

    begin {
        Assert-VmsRequirementsMet
        $folder = (Get-VmsManagementServer).BasicUserFolder
    }

    process {
        foreach ($user in $InputObject) {
            $target = "Basic user $($InputObject.Name)"
            if ($user.IsExternal) {
                $target += " <External IDP>"
            }
            if ($PSCmdlet.ShouldProcess($target, "Remove")) {
                try {
                    $null = $folder.RemoveBasicUser($user.Path)
                } catch {
                    Write-Error -Message $_.Exception.Message -TargetObject $user
                }
            }
        }
    }
}

