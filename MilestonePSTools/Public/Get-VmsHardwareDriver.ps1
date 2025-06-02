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

function Get-VmsHardwareDriver {
    [CmdletBinding(DefaultParameterSetName = 'Hardware')]
    [OutputType([VideoOS.Platform.ConfigurationItems.HardwareDriver])]
    [Alias('Get-HardwareDriver')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RecordingServer')]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer[]]
        $RecordingServer,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Hardware')]
        [ArgumentCompleter([MipItemNameCompleter[Hardware]])]
        [MipItemTransformation([Hardware])]
        [Hardware[]]
        $Hardware
    )

    begin {
        Assert-VmsRequirementsMet
        Show-DeprecationWarning $MyInvocation
        $driversByRecorder = @{}
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'RecordingServer' {
                foreach ($rec in $RecordingServer) {
                    foreach ($driver in $rec.HardwareDriverFolder.HardwareDrivers | Sort-Object DriverType) {
                        $driver
                    }
                }
            }
            'Hardware' {
                foreach ($hw in $Hardware) {
                    if (-not $driversByRecorder.ContainsKey($hw.ParentItemPath)) {
                        $driversByRecorder[$hw.ParentItemPath] = @{}
                        $rec = [VideoOS.Platform.ConfigurationItems.RecordingServer]::new($hw.ServerId, $hw.ParentItemPath)
                        $rec.HardwareDriverFolder.HardwareDrivers | ForEach-Object {
                            $driversByRecorder[$hw.ParentItemPath][$_.Path] = $_
                        }
                    }
                    $driver = $driversByRecorder[$hw.ParentItemPath][$hw.HardwareDriverPath]
                    if ($null -eq $driver) {
                        Write-Error "HardwareDriver '$($hw.HardwareDriverPath)' for hardware '$($hw.Name)' not found on the parent recording server."
                        continue
                    }
                    $driver
                }
            }
            Default {
                throw "Support for ParameterSetName '$_' not implemented."
            }
        }
    }

    end {
        $driversByRecorder.Clear()
    }
}
