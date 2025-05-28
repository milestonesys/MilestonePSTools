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

function Get-VmsCameraStream {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [OutputType([VmsCameraStreamConfig])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Camera[]]
        $Camera,

        [Parameter(ParameterSetName = 'ByName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'Enabled')]
        [switch]
        $Enabled,

        [Parameter(Mandatory, ParameterSetName = 'LiveDefault')]
        [switch]
        $LiveDefault,

        [Parameter(ParameterSetName = 'PlaybackDefault')]
        [switch]
        $PlaybackDefault,

        [Parameter(Mandatory, ParameterSetName = 'Recorded')]
        [switch]
        $Recorded,

        [Parameter(ParameterSetName = 'RecordingTrack')]
        [ValidateSet('Primary', 'Secondary', 'None')]
        [string]
        $RecordingTrack,

        [Parameter()]
        [switch]
        $RawValues
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($cam in $Camera) {
            $streamUsages = ($cam.StreamFolder.Streams | Select-Object -First 1).StreamUsageChildItems
            if ($null -eq $streamUsages) {
                $message = 'Camera "{0}" does not support simultaneous use of multiple streams. The following properties should be ignored for streams on this camera: DisplayName, Enabled, LiveMode, LiveDefault, Recorded.' -f $cam.Name
                Write-Warning $message
            }
            $deviceDriverSettings = $cam.DeviceDriverSettingsFolder.DeviceDriverSettings
            if ($null -eq $deviceDriverSettings -or $deviceDriverSettings.Count -eq 0 -or $deviceDriverSettings[0].StreamChildItems.Count -eq 0) {
                # Added this due to a situation where a camera/driver is in a weird state where maybe a replace hardware
                # is needed to bring it online and until then there are no stream settings listed in the settings tab
                # for the camera. This block allows us to return _something_ even though there are no stream settings available.
                $message = 'Camera "{0}" has no device driver settings available.' -f $cam.Name
                Write-Warning $message
                foreach ($streamUsage in $streamUsages) {
                    if ($LiveDefault -and -not $streamUsage.LiveDefault) {
                        continue
                    }
                    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Recorded') -and $Recorded -ne $streamUsage.Record) {
                        continue
                    }
                    [VmsCameraStreamConfig]@{
                        Name              = $streamUsage.Name
                        DisplayName       = $streamUsage.Name
                        Enabled           = $true
                        LiveDefault       = $streamUsage.LiveDefault
                        LiveMode          = $streamUsage.LiveMode
                        Recorded          = $streamUsage.Record
                        Settings          = @{}
                        ValueTypeInfo     = @{}
                        Camera            = $cam
                        StreamReferenceId = $streamUsage.StreamReferenceId
                    }
                }

                continue
            }

            foreach ($stream in $deviceDriverSettings[0].StreamChildItems) {
                $streamUsage = if ($streamUsages) { $streamUsages | Where-Object { $_.StreamReferenceId -eq $_.StreamReferenceIdValues[$stream.DisplayName] } }

                if ($LiveDefault -and -not $streamUsage.LiveDefault) {
                    continue
                }
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Recorded') -and $Recorded -ne $streamUsage.Record) {
                    continue
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RecordingTrack')) {
                    if ($RecordingTrack -eq 'Primary' -and -not $streamUsage.Record) {
                        continue
                    } elseif ($RecordingTrack -eq 'Secondary' -and $streamUsage.RecordTo -ne '84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0') {
                        continue
                    } elseif ($RecordingTrack -eq 'None' -and ($streamUsage.Record -or -not [string]::IsNullOrEmpty($streamUsage.RecordTo))) {
                        continue
                    }
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('PlaybackDefault') -and (($streamUsage.RecordToValues.Count -eq 0 -and $streamUsage.Record -ne $PlaybackDefault) -or ($streamUsage.RecordToValues.Count -gt 0 -and $streamUsage.DefaultPlayback -ne $PlaybackDefault))) {
                    continue
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Enabled') -and $streamUsages -and $Enabled -eq ($null -eq $streamUsage)) {
                    continue
                }

                if ($MyInvocation.BoundParameters.ContainsKey('Name') -and $stream.DisplayName -notlike $Name) {
                    continue
                }

                $streamConfig = [VmsCameraStreamConfig]@{
                    Name         = $stream.DisplayName
                    Camera       = $cam
                    UseRawValues = $RawValues
                }
                $streamConfig.Update()
                $streamConfig
            }
        }
    }
}

