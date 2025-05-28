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

function Get-DevicesByRecorder {
    <#
    .SYNOPSIS
        Gets all enabled cameras in a hashtable indexed by recording server id.
    .DESCRIPTION
        This cmdlet quickly returns a hashtable where the keys are recording
        server ID's and the values are lists of "VideoOS.Platform.Item" objects.

        The cmdlet will complete much quicker than if we were to use
        Get-RecordingServer | Get-VmsCamera, because it does not rely on the
        configuration API at all. Instead, it has the same functionality as
        XProtect Smart Client where the command "sees" only the devices that are enabled
        and loaded by the Recording Server.
    .EXAMPLE
        Get-CamerasByRecorder
        Name                           Value
        ----                           -----
        bb82b2cd-0bb9-4c88-9cb8-128... {Canon VB-M40 (192.168.101.64) - Camera 1}
        f9dc2bcd-faea-4138-bf5a-32c... {Axis P1375 (10.1.77.178) - Camera 1, Test Cam}

        This is what the output would look like on a small system.
    .OUTPUTS
        [hashtable]
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [guid[]]
        $RecordingServerId,

        [Parameter()]
        [Alias('Kind')]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', IgnoreCase = $false)]
        [string[]]
        $DeviceType = 'Camera'
    )

    process {
        $config = [videoos.platform.configuration]::Instance
        $serverKind = [VideoOS.Platform.Kind]::Server
        $selectedKinds = @(($DeviceType | ForEach-Object { [VideoOS.Platform.Kind]::$_ }))
        $systemHierarchy = [VideoOS.Platform.ItemHierarchy]::SystemDefined

        $stack = [Collections.Generic.Stack[VideoOS.Platform.Item]]::new()
        $rootItems = $config.GetItems($systemHierarchy)
        foreach ($mgmtSrv in $rootItems | Where-Object { $_.FQID.Kind -eq $serverKind }) {
            foreach ($recorder in $mgmtSrv.GetChildren()) {
                if ($recorder.FQID.Kind -eq $serverKind -and ($RecordingServerId.Count -eq 0 -or $recorder.FQID.ObjectId -in $RecordingServerId)) {
                    $stack.Push($recorder)
                }
            }
        }

        $result = @{}
        $lastServerId = $null
        while ($stack.Count -gt 0) {
            $item = $stack.Pop()
            if ($item.FQID.Kind -eq $serverKind) {
                $lastServerId = $item.FQID.ObjectId
                $result.$lastServerId = [Collections.Generic.List[VideoOS.Platform.Item]]::new()
            } elseif ($item.FQID.Kind -in $selectedKinds -and $item.FQID.FolderType -eq 'No') {
                $result.$lastServerId.Add($item)
                continue
            }

            if ($item.HasChildren -ne 'No' -and ($item.FQID.Kind -eq $serverKind -or $item.FQID.Kind -in $selectedKinds)) {
                foreach ($child in $item.GetChildren()) {
                    if ($child.FQID.Kind -in $selectedKinds) {
                        $stack.Push($child)
                    }
                }
            }
        }
        Write-Output $result
    }
}

