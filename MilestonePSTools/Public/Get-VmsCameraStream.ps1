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
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([MilestonePSTools.VmsCameraStreamConfig])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Camera[]]
        $Camera,

        [Parameter(ParameterSetName = 'Name')]
        [SupportsWildcards()]
        [string]
        $Name = '*',

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
            :nextstream foreach ($stream in [MilestonePSTools.VmsCameraStreamConfig]::GetStreams($cam, $RawValues)) {
                switch ($PSCmdlet.ParameterSetName) {
                    'Name' {
                        if ($stream.Name -notlike $Name) {
                            continue nextstream
                        }
                    }
                    'Enabled' {
                        if ($stream.Enabled -ne $Enabled) {
                            continue nextstream
                        }
                    }
                    'LiveDefault' {
                        if ($stream.LiveDefault -ne $LiveDefault) {
                            continue nextstream
                        }
                    }
                    'PlaybackDefault' {
                        if ($stream.PlaybackDefault -ne $PlaybackDefault) {
                            continue nextstream
                        }
                    }
                    'Recorded' {
                        if ($stream.Recorded -ne $Recorded) {
                            continue nextstream
                        }
                    }
                    'RecordingTrack' {
                        if ($stream.RecordingTrackName -ne $RecordingTrack) {
                            continue nextstream
                        }
                    }
                    Default {
                        Write-Error "ParameterSetName '$_' not implemented."
                        return
                    }
                }
                $stream
            }
        }
    }
}
