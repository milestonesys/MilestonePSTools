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

function Get-VmsDeviceStatus {
    [CmdletBinding()]
    [OutputType([VmsStreamDeviceStatus])]
    [RequiresVmsConnection()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [guid[]]
        $RecordingServerId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', IgnoreCase = $false)]
        [string[]]
        $DeviceType = 'Camera'
    )

    begin {
        Assert-VmsRequirementsMet
        $scriptBlock = {
            param([guid]$RecorderId, [VideoOS.Platform.Item[]]$Devices, [type]$VmsStreamDeviceStatusClass)
            $recorderItem = [VideoOS.Platform.Configuration]::Instance.GetItem($RecorderId, [VideoOS.Platform.Kind]::Server)
            $svc = [VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2]::new($recorderItem.FQID.ServerId.Uri)
            $status = @{}
            $currentStatus = $svc.GetCurrentDeviceStatus((Get-VmsToken), $Devices.FQID.ObjectId)
            foreach ($kind in 'Camera', 'Microphone', 'Speaker', 'Metadata') {
                foreach ($entry in $currentStatus."$($kind)DeviceStatusArray") {
                    $status[$entry.DeviceId] = $entry
                }
            }
            foreach ($item in $Devices) {
                $obj = $VmsStreamDeviceStatusClass::new($status[$item.FQID.ObjectId])
                $obj.DeviceName = $item.Name
                $obj.DeviceType = [VideoOS.Platform.Kind]::DefaultTypeToNameTable[$item.FQID.Kind]
                $obj.RecorderName = $recorderItem.Name
                $obj.RecorderId = $RecorderItem.FQID.ObjectId
                Write-Output $obj
            }
        }
    }

    process {
        <# TODO: Once a decision is made on how to handle the PoshRSJob
           dependency, uncomment the bits below and remove the line right
           after the opening foreach curly brace as it's already handled
           in the else block.
        #>
        $recorderCameraMap = Get-DevicesByRecorder -Id $RecordingServerId -DeviceType $DeviceType
        # $jobs = [system.collections.generic.list[RSJob]]::new()
        foreach ($recorderId in $recorderCameraMap.Keys) {
            $scriptBlock.Invoke($recorderId, $recorderCameraMap.$recorderId, ([VmsStreamDeviceStatus]))
            # if ($Parallel -and $RecordingServerId.Count -gt 1) {
            #     $job = Start-RSJob -ScriptBlock $scriptBlock -ArgumentList $recorderId, $recorderCameraMap.$recorderId, ([VmsStreamDeviceStatus])
            #     $jobs.Add($job)
            # } else {
            #     $scriptBlock.Invoke($recorderId, $recorderCameraMap.$recorderId, ([VmsStreamDeviceStatus]))
            # }
        }
        # if ($jobs.Count -gt 0) {
        #     $jobs | Wait-RSJob -ShowProgress:($ProgressPreference -eq 'Continue') | Receive-RSJob
        #     $jobs | Remove-RSJob
        # }
    }
}

