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

function Stop-VmsRestrictedLiveMode {
    [CmdletBinding()]
    [Alias('Stop-VmsRm')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.2')]
    [RequiresVmsFeature('RestrictedMedia')]
    [OutputType([VideoOS.Common.Proxy.Server.WCF.RestrictedMedia])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [guid[]]
        $DeviceId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [datetime]
        $StartTime,

        [Parameter()]
        [datetime]
        $EndTime = (Get-Date).AddMinutes(-1),

        [Parameter(Mandatory)]
        [string]
        $Header,

        [Parameter()]
        [string]
        $Description
    )

    begin {
        Assert-VmsRequirementsMet
        $deviceIds = [collections.generic.list[guid]]::new()
        $startTimeValue = [datetime]::MinValue
    }
    
    process {
        $deviceIds.AddRange($DeviceId)
        $startTimeValue = $StartTime
    }

    end {
        $result = { (Get-IServerCommandService).RestrictedMediaLiveModeExit(
            (New-Guid),
            $deviceIds,
            $Header,
            $Description,
            $startTimeValue.ToUniversalTime(),
            $EndTime.ToUniversalTime()
        ) } | ExecuteWithRetry -ClearVmsCache
        foreach ($fault in $result.FaultDevices) {
            Write-Error -Message "$($fault.Message) DeviceId = '$($fault.DeviceId)'." -ErrorId 'RestrictedMediaLive.Fault' -Category InvalidResult
        }
        foreach ($warning in $result.WarningDevices) {
            Write-Warning -Message "$($warning.Message) DeviceId = '$($warning.DeviceId)'."
        }
        foreach ($restrictedMedia in $result.RestrictedMedia) {
            $restrictedMedia
        }
    }
}

