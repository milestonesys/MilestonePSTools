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

function Get-CameraRecordingStats {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Command has already been published.')]
    param(
        # Specifies the Id's of cameras for which to retrieve recording statistics
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [guid[]]
        $Id,

        # Specifies the timestamp from which to start retrieving recording statistics. Default is 7 days prior to 12:00am of the current day.
        [Parameter()]
        [datetime]
        $StartTime = (Get-Date).Date.AddDays(-7),

        # Specifies the timestamp marking the end of the time period for which to retrieve recording statistics. The default is 12:00am of the current day.
        [Parameter()]
        [datetime]
        $EndTime = (Get-Date).Date,

        # Specifies the type of sequence to get statistics on. Default is RecordingSequence.
        [Parameter()]
        [ValidateSet('RecordingSequence', 'MotionSequence')]
        [string]
        $SequenceType = 'RecordingSequence',

        # Specifies that the output should be provided in a complete hashtable instead of one pscustomobject value at a time
        [Parameter()]
        [switch]
        $AsHashTable,

        # Specifies the runspacepool to use. If no runspacepool is provided, one will be created.
        [Parameter()]
        [System.Management.Automation.Runspaces.RunspacePool]
        $RunspacePool
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($EndTime -le $StartTime) {
            throw "EndTime must be greater than StartTime"
        }

        $disposeRunspacePool = $true
        if ($PSBoundParameters.ContainsKey('RunspacePool')) {
            $disposeRunspacePool = $false
        }
        $pool = $RunspacePool
        if ($null -eq $pool) {
            Write-Verbose "Creating a runspace pool"
            $pool = [runspacefactory]::CreateRunspacePool(1, ([int]$env:NUMBER_OF_PROCESSORS + 1))
            $pool.Open()
        }

        $scriptBlock = {
            param(
                [guid]$Id,
                [datetime]$StartTime,
                [datetime]$EndTime,
                [string]$SequenceType
            )

            $sequences = Get-SequenceData -Path "Camera[$Id]" -SequenceType $SequenceType -StartTime $StartTime -EndTime $EndTime -CropToTimeSpan
            $recordedMinutes = $sequences | Foreach-Object {
                ($_.EventSequence.EndDateTime - $_.EventSequence.StartDateTime).TotalMinutes
                } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            [pscustomobject]@{
                DeviceId = $Id
                StartTime = $StartTime
                EndTime = $EndTime
                SequenceCount = $sequences.Count
                TimeRecorded = [timespan]::FromMinutes($recordedMinutes)
                PercentRecorded = [math]::Round(($recordedMinutes / ($EndTime - $StartTime).TotalMinutes * 100), 1)
            }
        }

        try {
            $threads = New-Object System.Collections.Generic.List[pscustomobject]
            foreach ($cameraId in $Id) {
                $ps = [powershell]::Create()
                $ps.RunspacePool = $pool
                $asyncResult = $ps.AddScript($scriptBlock).AddParameters(@{
                    Id = $cameraId
                    StartTime = $StartTime
                    EndTime = $EndTime
                    SequenceType = $SequenceType
                }).BeginInvoke()
                $threads.Add([pscustomobject]@{
                    DeviceId = $cameraId
                    PowerShell = $ps
                    Result = $asyncResult
                })
            }

            if ($threads.Count -eq 0) {
                return
            }

            $hashTable = @{}
            $completedThreads = New-Object System.Collections.Generic.List[pscustomobject]
            while ($threads.Count -gt 0) {
                foreach ($thread in $threads) {
                    if ($thread.Result.IsCompleted) {
                        if ($AsHashTable) {
                            $hashTable.$($thread.DeviceId.ToString()) = $null
                        }
                        else {
                            $obj = [ordered]@{
                                DeviceId = $thread.DeviceId.ToString()
                                RecordingStats = $null
                            }
                        }
                        try {
                            $result = $thread.PowerShell.EndInvoke($thread.Result) | ForEach-Object { Write-Output $_ }
                            if ($AsHashTable) {
                                $hashTable.$($thread.DeviceId.ToString()) = $result
                            }
                            else {
                                $obj.RecordingStats = $result
                            }
                        }
                        catch {
                            Write-Error $_
                        }
                        finally {
                            $thread.PowerShell.Dispose()
                            $completedThreads.Add($thread)
                            if (!$AsHashTable) {
                                Write-Output ([pscustomobject]$obj)
                            }
                        }
                    }
                }
                $completedThreads | Foreach-Object { [void]$threads.Remove($_)}
                $completedThreads.Clear()
                if ($threads.Count -eq 0) {
                    break;
                }
                Start-Sleep -Milliseconds 250
            }
            if ($AsHashTable) {
                Write-Output $hashTable
            }
        }
        finally {
            if ($threads.Count -gt 0) {
                Write-Warning "Stopping $($threads.Count) running PowerShell instances. This may take a minute. . ."
                foreach ($thread in $threads) {
                    $thread.PowerShell.Dispose()
                }
            }
            if ($disposeRunspacePool) {
                Write-Verbose "Closing runspace pool in $($MyInvocation.MyCommand.Name)"
                $pool.Close()
                $pool.Dispose()
            }
        }
    }
}

