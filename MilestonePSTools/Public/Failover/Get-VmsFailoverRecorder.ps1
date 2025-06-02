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

function Get-VmsFailoverRecorder {
    [CmdletBinding(DefaultParameterSetName = 'FailoverGroup')]
    [OutputType([VideoOS.Platform.ConfigurationItems.FailoverRecorder])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'FailoverGroup')]
        [ArgumentCompleter([MipItemNameCompleter[FailoverGroup]])]
        [MipItemTransformation([FailoverGroup])]
        [FailoverGroup]
        $FailoverGroup,

        [Parameter(ParameterSetName = 'FailoverGroup')]
        [switch]
        $Recurse,

        [Parameter(Mandatory, ParameterSetName = 'HotStandby')]
        [switch]
        $HotStandby,

        [Parameter(Mandatory, ParameterSetName = 'Unassigned')]
        [switch]
        $Unassigned,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
        if ($HotStandby -or $Unassigned) {
            $failovers = (Get-VmsManagementServer).FailoverGroupFolder.FailoverRecorders
            $hotFailovers = Get-VmsRecordingServer | Foreach-Object {
                $_.RecordingServerFailoverFolder.RecordingServerFailovers[0].HotStandby
            } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'FailoverGroup' {
                if ($FailoverGroup) {
                    $FailoverGroup.FailoverRecorderFolder.FailoverRecorders
                } else {
                    (Get-VmsManagementServer).FailoverGroupFolder.FailoverRecorders
                    if ($Recurse) {
                        Get-VmsFailoverGroup | Get-VmsFailoverRecorder
                    }
                }
            }
            'HotStandby' {
                if ($failovers.Count -eq 0) {
                    return
                }
                $failovers | Where-Object Path -in $hotFailovers
            }
            'Unassigned' {
                if ($failovers.Count -eq 0) {
                    return
                }
                $failovers | Where-Object Path -notin $hotFailovers
            }
            'Id' {
                try {
                    $serverId = (Get-VmsManagementServer).ServerId
                    $path = 'FailoverRecorder[{0}]' -f $Id
                    [VideoOS.Platform.ConfigurationItems.FailoverRecorder]::new($serverId, $path)
                } catch {
                    throw
                }
            }
            Default {
                throw "ParameterSetName '$_' not implemented."
            }
        }
    }
}
