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

function Remove-VmsFailoverGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [FailoverGroupNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.FailoverGroup]
        $FailoverGroup,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ShouldProcess($FailoverGroup.Name, "Remove FailoverGroup")) {
            if ($FailoverGroup.FailoverRecorderFolder.FailoverRecorders.Count -gt 0) {
                if (-not $Force) {
                    throw "Cannot delete FailoverGroup with members. Try again with -Force switch to remove member FailoverRecorders."
                }
                $FailoverGroup | Get-VmsFailoverRecorder | Foreach-Object {
                    $FailoverGroup | Remove-VmsFailoverRecorder -FailoverRecorder $_ -Confirm:$false
                }
            }
            try {
                $serverTask = (Get-VmsManagementServer).FailoverGroupFolder.RemoveFailoverGroup($FailoverGroup.Path)
                while ($serverTask.Progress -lt 100) {
                    Start-Sleep -Milliseconds 100
                    $serverTask.UpdateState()
                }
                if ($serverTask.State -ne 'Success') {
                    Write-Error -Message "RemoveFailoverGroup returned with ErrorCode $($serverTask.ErrorCode). $($serverTask.ErrorText)" -TargetObject $serverTask
                }
            } catch {
                throw
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsFailoverGroup -ParameterName FailoverGroup -ScriptBlock {
    $values = (Get-VmsFailoverGroup).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

