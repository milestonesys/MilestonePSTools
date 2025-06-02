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

function Remove-VmsFailoverRecorder {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[FailoverGroup]])]
        [MipItemTransformation([FailoverGroup])]
        [FailoverGroup]
        $FailoverGroup,

        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter([MipItemNameCompleter[FailoverRecorder]])]
        [MipItemTransformation([FailoverRecorder])]
        [FailoverRecorder]
        $FailoverRecorder
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if (-not $PSCmdlet.ShouldProcess("FailoverGroup $($FailoverGroup.Name)", "Remove $($FailoverRecorder)")) {
            return
        }

        try {
            $serverTask = (Get-VmsManagementServer).FailoverGroupFolder.MoveFailoverGroup($FailoverRecorder.Path, [string]::Empty, 0)
            while ($serverTask.Progress -lt 100) {
                Start-Sleep -Milliseconds 100
                $serverTask.UpdateState()
            }
            if ($serverTask.State -ne 'Success') {
                Write-Error -Message "MoveFailoverGroup returned with ErrorCode $($serverTask.ErrorCode). $($serverTask.ErrorText)" -TargetObject $serverTask
                return
            }
        } catch {
            throw
        } finally {
            $FailoverGroup.ClearChildrenCache()
        }
    }
}
