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

function New-VmsFailoverGroup {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.FailoverGroup])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if (-not $PSCmdlet.ShouldProcess("FailoverGroup $Name", "Create")) {
            return
        }
        try {
            $serverTask = (Get-VmsManagementServer).FailoverGroupFolder.AddFailoverGroup($Name, $Description)
            while ($serverTask.Progress -lt 100) {
                Start-Sleep -Milliseconds 100
                $serverTask.UpdateState()
            }
            if ($serverTask.State -ne 'Success') {
                Write-Error -Message "AddFailoverGroup returned with ErrorCode $($serverTask.ErrorCode). $($serverTask.ErrorText)" -TargetObject $serverTask
                return
            }
            $id = $serverTask.Path -replace 'FailoverGroup\[(.+)\]', '$1'
            Get-VmsFailoverGroup -Id $id
        } catch {
            throw
        }
    }
}

