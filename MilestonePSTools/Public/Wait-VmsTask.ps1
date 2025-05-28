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

function Wait-VmsTask {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateVmsItemType('Task')]
        [string[]]
        $Path,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [switch]
        $Cleanup
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $tasks = New-Object 'System.Collections.Generic.Queue[VideoOS.ConfigurationApi.ClientService.ConfigurationItem]'
        $Path | Foreach-Object {
            $item = $null
            $errorCount = 0
            while ($null -eq $item) {
                try {
                    $item = Get-ConfigurationItem -Path $_
                }
                catch {
                    $errorCount++
                    if ($errorCount -ge 5) {
                        throw
                    }
                    else {
                        Write-Verbose 'Wait-VmsTask received an error when communicating with Configuration API. The communication channel will be re-established and the connection will be attempted up to 5 times.'
                        Start-Sleep -Seconds 2
                        Get-VmsSite | Select-VmsSite
                    }
                }
            }

            if ($item.ItemType -ne 'Task') {
                Write-Error "Configuration Item with path '$($item.Path)' is incompatible with Wait-VmsTask. Expected an ItemType of 'Task' and received a '$($item.ItemType)'."
            }
            else {
                $tasks.Enqueue($item)
            }
        }
        $completedStates = 'Error', 'Success', 'Completed'
        $totalTasks = $tasks.Count
        $progressParams = @{
            Activity = if ([string]::IsNullOrWhiteSpace($Title)) { 'Waiting for VMS Task(s) to complete' } else { $Title }
            PercentComplete = 0
            Status = 'Processing'
        }
        try {
            Write-Progress @progressParams
            $stopwatch = [diagnostics.stopwatch]::StartNew()
            while ($tasks.Count -gt 0) {
                Start-Sleep -Milliseconds 500
                $taskInfo = $tasks.Dequeue()
                $completedTaskCount = $totalTasks - ($tasks.Count + 1)
                $tasksRemaining = $totalTasks - $completedTaskCount
                $percentComplete = [int]($taskInfo.Properties | Where-Object Key -eq 'Progress' | Select-Object -ExpandProperty Value)

                if ($completedTaskCount -gt 0) {
                    $timePerTask = $stopwatch.ElapsedMilliseconds / $completedTaskCount
                    $remainingTime = [timespan]::FromMilliseconds($tasksRemaining * $timePerTask)
                    $progressParams.SecondsRemaining = [int]$remainingTime.TotalSeconds
                }
                elseif ($percentComplete -gt 0){
                    $pointsRemaining = 100 - $percentComplete
                    $timePerPoint = $stopwatch.ElapsedMilliseconds / $percentComplete
                    $remainingTime = [timespan]::FromMilliseconds($pointsRemaining * $timePerPoint)
                    $progressParams.SecondsRemaining = [int]$remainingTime.TotalSeconds
                }

                if ($tasks.Count -eq 0) {
                    $progressParams.Status = "$($taskInfo.Path) - $($taskInfo.DisplayName)."
                    $progressParams.PercentComplete = $percentComplete
                    Write-Progress @progressParams
                }
                else {
                    $progressParams.Status = "Completed $completedTaskCount of $totalTasks tasks. Remaining tasks: $tasksRemaining"
                    $progressParams.PercentComplete = [int]($completedTaskCount / $totalTasks * 100)
                    Write-Progress @progressParams
                }
                $errorCount = 0
                while ($null -eq $taskInfo) {
                    try {
                        $taskInfo = $taskInfo | Get-ConfigurationItem
                        break
                    }
                    catch {
                        $errorCount++
                        if ($errorCount -ge 5) {
                            throw
                        }
                        else {
                            Write-Verbose 'Wait-VmsTask received an error when communicating with Configuration API. The communication channel will be re-established and the connection will be attempted up to 5 times.'
                            Start-Sleep -Seconds 2
                            Get-VmsSite | Select-VmsSite
                        }
                    }
                }
                $taskInfo = $taskInfo | Get-ConfigurationItem
                if (($taskInfo | Get-ConfigurationItemProperty -Key State) -notin $completedStates) {
                    $tasks.Enqueue($taskInfo)
                    continue
                }
                Write-Output $taskInfo
                if ($Cleanup -and $taskInfo.MethodIds -contains 'TaskCleanup') {
                    $null = $taskInfo | Invoke-Method -MethodId 'TaskCleanup'
                }
            }
        }
        finally {
            $progressParams.Completed = $true
            Write-Progress @progressParams
        }
    }
}

