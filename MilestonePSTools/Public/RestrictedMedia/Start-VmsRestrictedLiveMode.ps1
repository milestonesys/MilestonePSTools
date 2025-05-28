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

function Start-VmsRestrictedLiveMode {
    [CmdletBinding()]
    [Alias('Start-VmsRm')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.2')]
    [RequiresVmsFeature('RestrictedMedia')]
    [OutputType([VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [guid[]]
        $DeviceId,

        [Parameter()]
        [datetime]
        $StartTime = (Get-Date).AddMinutes(-1),

        [Parameter()]
        [switch]
        $IgnoreRelatedDevices
    )
    
    begin {
        Assert-VmsRequirementsMet
        $deviceIds = [collections.generic.list[guid]]::new()
    }

    process {
        foreach ($id in $DeviceId) {
            $deviceIds.Add($id)

            if ($IgnoreRelatedDevices) {
                continue
            }

            if ($null -eq ($item = Find-VmsVideoOSItem -SearchText $id.ToString().ToLower())) {
                continue
            }

            foreach ($relatedItem in $item.GetRelated()) {
                $deviceIds.Add($relatedItem.FQID.ObjectId)
            }
        }
    }

    end {
        $result = {
            (Get-IServerCommandService).RestrictedMediaLiveModeEnter(
                $deviceIds,
                $StartTime.ToUniversalTime()
            )
        } | ExecuteWithRetry -ClearVmsCache
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

