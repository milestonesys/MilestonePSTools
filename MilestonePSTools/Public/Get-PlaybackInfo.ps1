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

function Get-PlaybackInfo {
    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    [RequiresVmsConnection()]
    param (
        # Accepts a Milestone Configuration Item path string like Camera[A64740CF-5511-4957-9356-2922A25FF752]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPath')]
        [ValidateScript( {
                if ($_ -notmatch '^(?<ItemType>\w+)\[(?<Id>[a-fA-F0-9\-]{36})\]$') {
                    throw "$_ does not a valid Milestone Configuration API Item path"
                }
                if ($Matches.ItemType -notin @('Camera', 'Microphone', 'Speaker', 'Metadata')) {
                    throw "$_ represents an item of type '$($Matches.ItemType)'. Only camera, microphone, speaker, or metadata item types are allowed."
                }
                return $true
            })]
        [string[]]
        $Path,

        # Accepts a Camera, Microphone, Speaker, or Metadata object
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromDevice')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem[]]
        $Device,

        [Parameter()]
        [ValidateSet('MotionSequence', 'RecordingSequence', 'TimelineMotionDetected', 'TimelineRecording')]
        [string]
        $SequenceType = 'RecordingSequence',

        [Parameter()]
        [switch]
        $Parallel,

        [Parameter(ParameterSetName = 'DeprecatedParameterSet')]
        [VideoOS.Platform.ConfigurationItems.Camera]
        $Camera,

        [Parameter(ParameterSetName = 'DeprecatedParameterSet')]
        [guid]
        $CameraId,

        [Parameter(ParameterSetName = 'DeprecatedParameterSet')]
        [switch]
        $UseLocalTime
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'DeprecatedParameterSet') {
            Write-Warning 'The Camera, CameraId, and UseLocalTime parameters are deprecated. See "Get-Help Get-PlaybackInfo -Full" for more information.'
            if ($null -ne $Camera) {
                $Path = $Camera.Path
            }
            else{
                $Path = "Camera[$CameraId]"
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'FromDevice') {
            $Path = $Device.Path
        }
        if ($Path.Count -le 60 -and $Parallel) {
            Write-Warning "Ignoring the Parallel switch since there are only $($Path.Count) devices to query."
            $Parallel = $false
        }

        if ($Parallel) {
            $jobRunner = [LocalJobRunner]::new()
        }


        $script = {
            param([string]$Path, [string]$SequenceType)
            if ($Path -notmatch '^(?<ItemType>\w+)\[(?<Id>[a-fA-F0-9\-]{36})\]$') {
                Write-Error "Path '$Path' is not a valid Milestone Configuration API item path."
                return
            }
            try {
                $site = Get-VmsSite
                $epoch = [datetime]::SpecifyKind([datetimeoffset]::FromUnixTimeSeconds(0).DateTime, [datetimekind]::utc)
                $item = [videoos.platform.Configuration]::Instance.GetItem($site.FQID.ServerId, $Matches.Id, [VideoOS.Platform.Kind]::($Matches.ItemType))
                if ($null -eq $item) {
                    Write-Error "Camera not available. It may be disabled, or it may not belong to a camera group."
                    return
                }
                $sds = [VideoOS.Platform.Data.SequenceDataSource]::new($item)
                $sequenceTypeGuid = [VideoOS.Platform.Data.DataType+SequenceTypeGuids]::$SequenceType
                $first = $sds.GetData($epoch, [timespan]::zero, 0, ([datetime]::utcnow - $epoch), 1, $sequenceTypeGuid) | Select-Object -First 1
                $last = $sds.GetData([datetime]::utcnow, ([datetime]::utcnow - $epoch), 1, [timespan]::zero, 0, $sequenceTypeGuid) | Select-Object -First 1
                if ($first.EventSequence -and $last.EventSequence) {
                    [PSCustomObject]@{
                        Begin = $first.EventSequence.StartDateTime
                        End   = $last.EventSequence.EndDateTime
                        Retention = $last.EventSequence.EndDateTime - $first.EventSequence.StartDateTime
                        Path = $Path
                    }
                }
                else {
                    Write-Warning "No sequences of type '$SequenceType' found for $(($Matches.ItemType).ToLower()) $($item.Name) ($($item.FQID.ObjectId))"
                }
            } finally {
                if ($sds) {
                    $sds.Close()
                }
            }
        }

        try {
            foreach ($p in $Path) {
                if ($Parallel) {
                    $null = $jobRunner.AddJob($script, @{Path = $p; SequenceType = $SequenceType})
                }
                else {
                    $script.Invoke($p, $SequenceType) | Foreach-Object {
                        if ($UseLocalTime) {
                            $_.Begin = $_.Begin.ToLocalTime()
                            $_.End = $_.End.ToLocalTime()
                        }
                        $_
                    }
                }
            }

            if ($Parallel) {
                while ($jobRunner.HasPendingJobs()) {
                    $jobRunner.ReceiveJobs() | Foreach-Object {
                        if ($_.Output) {
                            if ($UseLocalTime) {
                                $_.Output.Begin = $_.Output.Begin.ToLocalTime()
                                $_.Output.End = $_.Output.End.ToLocalTime()
                            }
                            Write-Output $_.Output
                        }
                        if ($_.Errors) {
                            $_.Errors | Foreach-Object {
                                Write-Error $_
                            }
                        }
                    }
                    Start-Sleep -Milliseconds 200
                }
            }
        }
        finally {
            if ($jobRunner) {
                $jobRunner.Dispose()
            }
        }
    }
}

