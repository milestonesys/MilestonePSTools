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

function Remove-VmsClientProfile {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ArgumentCompleter([MipItemNameCompleter[ClientProfile]])]
        [MipItemTransformation([ClientProfile])]
        [ClientProfile[]]
        $ClientProfile
    )

    begin {
        Assert-VmsRequirementsMet
        $folder = (Get-VmsManagementServer -ErrorAction Stop).ClientProfileFolder
    }

    process {
        foreach ($p in $ClientProfile) {
            try {
                if ($PSCmdlet.ShouldProcess("ClientProfile $($p.Name)", "Remove")) {
                    $serverTask = $folder.RemoveClientProfile($p.Path)
                    if ($serverTask.State -ne 'Success') {
                        Write-Error -Message "Error creating new client profile: $($serverTask.ErrorText)" -TargetObject $serverTask
                        return
                    }
                }
            } catch {
                Write-Error -Message $_.Message -Exception $_.Exception -TargetObject $p
            }
        }
    }
}

