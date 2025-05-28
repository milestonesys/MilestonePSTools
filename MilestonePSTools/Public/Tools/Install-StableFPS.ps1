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

function Install-StableFPS {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    [RequiresElevation()]
    param (
        [Parameter()]
        [string]
        $Source = "C:\Program Files\Milestone\MIPSDK\Tools\StableFPS",
        [Parameter()]
        [int]
        [ValidateRange(1, 200)]
        $Cameras = 32,
        [Parameter()]
        [int]
        [ValidateRange(1, 5)]
        $Streams = 1,
        [Parameter()]
        [string]
        $DevicePackPath
    )

    begin {
        Assert-VmsRequirementsMet
        if (!(Test-Path (Join-Path $Source "StableFPS_DATA"))) {
            throw "Path not found: $((Join-Path $Source "StableFPS_DATA"))"
        }
        if (!(Test-Path (Join-Path $Source "vLatest"))) {
            throw "Path not found: $((Join-Path $Source "vLatest"))"
        }
    }

    process {
        $serviceStopped = $false
        try {
            $dpPath = if ([string]::IsNullOrWhiteSpace($DevicePackPath)) { (Get-RecorderConfig).DevicePackPath } else { $DevicePackPath }
            if (!(Test-Path $dpPath)) {
                throw "DevicePackPath not valid"
            }
            if ([string]::IsNullOrWhiteSpace($DevicePackPath)) {
                $service = Get-Service "Milestone XProtect Recording Server"
                if ($service.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) {
                    $service | Stop-Service -Force
                    $serviceStopped = $true
                }
            }

            $srcData = Join-Path $Source "StableFPS_Data"
            $srcDriver = Join-Path $Source "vLatest"
            Copy-Item $srcData -Destination $dpPath -Container -Recurse -Force
            Copy-Item "$srcDriver\*" -Destination $dpPath -Recurse -Force

            $tempXml = Join-Path $dpPath "resources\StableFPS_TEMP.xml"
            $newXml = Join-Path $dpPath "resources\StableFPS.xml"
            $content = Get-Content $tempXml -Raw
            $content = $content.Replace("{CAM_NUM_REQUESTED}", $Cameras)
            $content = $content.Replace("{STREAM_NUM_REQUESTED}", $Streams)
            $content | Set-Content $newXml
            Remove-Item $tempXml
        }
        catch {
            throw
        }
        finally {
            if ($serviceStopped -and $null -ne $service) {
                $service.Refresh()
                $service.Start()
            }
        }
    }
}

