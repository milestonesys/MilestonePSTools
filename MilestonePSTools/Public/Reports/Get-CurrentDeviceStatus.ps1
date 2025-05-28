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

function Get-CurrentDeviceStatus {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [MilestonePSTools.RequiresVmsConnection()]
    param (
        # Specifies one or more Recording Server ID's to which the results will be limited. Omit this parameter if you want device status from all Recording Servers
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [guid[]]
        $RecordingServerId,

        # Specifies the type of devices to include in the results. By default only cameras will be included and you can expand this to include all device types
        [Parameter()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input event', 'Output', 'Event', 'Hardware', 'All')]
        [string[]]
        $DeviceType = 'Camera',

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
        if ($DeviceType -contains 'All') {
            $DeviceType = @('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input event', 'Output', 'Event', 'Hardware')
        }
        $includedDeviceTypes = $DeviceType | ForEach-Object { [videoos.platform.kind]::$_ }

        $disposeRunspacePool = $true
        if ($PSBoundParameters.ContainsKey('RunspacePool')) {
            $disposeRunspacePool = $false
        }
        $pool = $RunspacePool
        if ($null -eq $pool) {
            Write-Verbose 'Creating a runspace pool'
            $iss = [initialsessionstate]::CreateDefault()
            $moduleManifest = (Get-Module MilestonePSTools).Path -replace 'psm1$', 'psd1'
            $iss.ImportPSModule($moduleManifest)
            $pool = [runspacefactory]::CreateRunspacePool(1, ([int]$env:NUMBER_OF_PROCESSORS + 1), $iss, (Get-Host))
            $pool.Open()
        }

        $scriptBlock = {
            param(
                [uri]$Uri,
                [guid[]]$DeviceIds
            )
            try {
                $client = [VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2]::new($Uri)
                $client.GetCurrentDeviceStatus((Get-VmsToken), $deviceIds)
            } catch {
                throw
            }
        }

        Write-Verbose 'Retrieving recording server information'
        $managementServer = [videoos.platform.configuration]::Instance.GetItems([videoos.platform.itemhierarchy]::SystemDefined) | Where-Object { $_.FQID.Kind -eq [videoos.platform.kind]::Server -and $_.FQID.ObjectId -eq (Get-VmsManagementServer).Id }
        $recorders = $managementServer.GetChildren() | Where-Object { $_.FQID.ServerId.ServerType -eq 'XPCORS' -and ($null -eq $RecordingServerId -or $_.FQID.ObjectId -in $RecordingServerId) }
        Write-Verbose "Retrieving video device statistics from $($recorders.Count) recording servers"
        try {
            $threads = New-Object System.Collections.Generic.List[pscustomobject]
            foreach ($recorder in $recorders) {
                Write-Verbose "Requesting device status from $($recorder.Name) at $($recorder.FQID.ServerId.Uri)"
                $folders = $recorder.GetChildren() | Where-Object { $_.FQID.Kind -in $includedDeviceTypes -and $_.FQID.FolderType -eq [videoos.platform.foldertype]::SystemDefined }
                $deviceIds = [guid[]]($folders | ForEach-Object {
                        $children = $_.GetChildren()
                        if ($null -ne $children -and $children.Count -gt 0) {
                            $children.FQID.ObjectId
                        }
                    })

                $ps = [powershell]::Create()
                $ps.RunspacePool = $pool
                $asyncResult = $ps.AddScript($scriptBlock).AddParameters(@{
                        Uri       = $recorder.FQID.ServerId.Uri
                        DeviceIds = $deviceIds
                    }).BeginInvoke()
                $threads.Add([pscustomobject]@{
                        RecordingServerId   = $recorder.FQID.ObjectId
                        RecordingServerName = $recorder.Name
                        PowerShell          = $ps
                        Result              = $asyncResult
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
                        Write-Verbose "Receiving results from recording server $($thread.RecordingServerName)"
                        if ($AsHashTable) {
                            $hashTable.$($thread.RecordingServerId.ToString()) = $null
                        } else {
                            $obj = @{
                                RecordingServerId   = $thread.RecordingServerId.ToString()
                                CurrentDeviceStatus = $null
                            }
                        }
                        try {
                            $result = $thread.PowerShell.EndInvoke($thread.Result) | ForEach-Object { Write-Output $_ }
                            if ($AsHashTable) {
                                $hashTable.$($thread.RecordingServerId.ToString()) = $result
                            } else {
                                $obj.CurrentDeviceStatus = $result
                            }
                        } catch {
                            throw
                        } finally {
                            $thread.PowerShell.Dispose()
                            $completedThreads.Add($thread)
                            if (!$AsHashTable) {
                                Write-Output ([pscustomobject]$obj)
                            }
                        }
                    }
                }
                $completedThreads | ForEach-Object { [void]$threads.Remove($_) }
                $completedThreads.Clear()
                if ($threads.Count -eq 0) {
                    break
                }
                Start-Sleep -Milliseconds 250
            }
            if ($AsHashTable) {
                Write-Output $hashTable
            }
        } finally {
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

