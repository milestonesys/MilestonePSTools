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

function Remove-VmsRestrictedMedia {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-VmsRm')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.2')]
    [RequiresVmsFeature('RestrictedMedia')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RestrictedMedia')]
        [VideoOS.Common.Proxy.Server.WCF.RestrictedMedia]
        $RestrictedMedia,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RestrictedMediaLive')]
        [VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive]
        $RestrictedMediaLive,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceId')]
        [Alias('Id')]
        [guid[]]
        $DeviceId
    )

    begin {
        Assert-VmsRequirementsMet
        $ids = [collections.generic.list[guid]]::new()
        $idToNameMap = @{}
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'RestrictedMedia' {
                $ids.Add($RestrictedMedia.Id)
                $idToNameMap[$RestrictedMedia.Id] = $RestrictedMedia.Header
                break
            }

            'DeviceId' {
                $ids.AddRange($DeviceId)
                break
            }

            'RestrictedMediaLive' {
                $ids.Add($RestrictedMediaLive.DeviceId)
                break
            }
        }
    }

    end {
        $results = [collections.generic.list[object]]::new()
        switch ($PSCmdlet.ParameterSetName) {
            'RestrictedMedia' {
                foreach ($id in $ids) {
                    if ($PSCmdlet.ShouldProcess($idToNameMap[$id], "Remove recorded media restriction")) {
                        $results.Add(({ (Get-IServerCommandService).RestrictedMediaDelete($id) } | ExecuteWithRetry -ClearVmsCache))
                    }
                }
            }

            { $_ -in @('RestrictedMediaLive', 'DeviceId') } {
                if ($PSCmdlet.ShouldProcess("$($ids.Count) devices", "Remove live media restriction")) {
                    $results.Add(({ (Get-IServerCommandService).RestrictedMediaLiveDelete($ids) } | ExecuteWithRetry -ClearVmsCache))
                }
            }
        }
        foreach ($result in $results) {
            Write-Verbose "Removed $($result.RestrictedMedia.Count) $($result.GetType().Name) records."
            foreach ($fault in $result.FaultDevices) {
                Write-Error -Message "$($fault.Message) DeviceId = '$($fault.DeviceId)'." -ErrorId 'RestrictedMediaLive.Fault' -Category InvalidResult
            }
            foreach ($warning in $result.WarningDevices) {
                Write-Warning -Message "$($warning.Message) DeviceId = '$($warning.DeviceId)'."
            }
        }
    }
}

