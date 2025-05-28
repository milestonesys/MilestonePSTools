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

function Remove-VmsAlarmDefinition {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.AlarmDefinition[]]
        $AlarmDefinition
    )

    begin {
        Assert-VmsRequirementsMet
        $folder = (Get-VmsManagementServer).AlarmDefinitionFolder
    }

    process {
        foreach ($definition in $AlarmDefinition) {
            try {
                if ($PSCmdlet.ShouldProcess($definition.Name, 'Remove Alarm Definition')) {
                    $result = $folder.RemoveAlarmDefinition($definition.Path)
                    if ($result.State -ne 'Success') {
                        Write-Error "An error was returned while removing the alarm definition. $($result.ErrorText)" -TargetObject $definition
                    }
                }
            } catch [VideoOS.Platform.PathNotFoundMIPException] {
                Write-Error -Message "Alarm definition '$($definition.Name)' with Id '$($definition.Id)' does not exist." -Exception $_.Exception -TargetObject $definition
            }
        }
    }
}
