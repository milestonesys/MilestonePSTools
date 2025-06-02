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

function Add-VmsStorage {
    [CmdletBinding(DefaultParameterSetName = 'WithoutEncryption', SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.Storage])]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'WithoutEncryption')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'WithEncryption')]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer]
        $RecordingServer,

        [Parameter(Mandatory, ParameterSetName = 'WithoutEncryption')]
        [Parameter(Mandatory, ParameterSetName = 'WithEncryption')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'WithoutEncryption')]
        [Parameter(ParameterSetName = 'WithEncryption')]
        [string]
        $Description,

        [Parameter(Mandatory, ParameterSetName = 'WithoutEncryption')]
        [Parameter(Mandatory, ParameterSetName = 'WithEncryption')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'WithoutEncryption')]
        [Parameter(ParameterSetName = 'WithEncryption')]
        [ValidateTimeSpanRange('00:01:00', '365000.00:00:00')]
        [timespan]
        $Retention,

        [Parameter(Mandatory, ParameterSetName = 'WithoutEncryption')]
        [Parameter(Mandatory, ParameterSetName = 'WithEncryption')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $MaximumSizeMB,

        [Parameter(ParameterSetName = 'WithoutEncryption')]
        [Parameter(ParameterSetName = 'WithEncryption')]
        [switch]
        $Default,

        [Parameter(ParameterSetName = 'WithoutEncryption')]
        [Parameter(ParameterSetName = 'WithEncryption')]
        [switch]
        $EnableSigning,

        [Parameter(Mandatory, ParameterSetName = 'WithEncryption')]
        [ValidateSet('Light', 'Strong', IgnoreCase = $false)]
        [string]
        $EncryptionMethod,

        [Parameter(Mandatory, ParameterSetName = 'WithEncryption')]
        [securestring]
        $Password
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $storageFolder = $RecordingServer.StorageFolder
        if ($PSCmdlet.ShouldProcess("Recording Server '$($RecordingServer.Name)' at $($RecordingServer.HostName)", "Add new storage named '$($Name)' with retention of $($Retention.TotalHours) hours and a maximum size of $($MaximumSizeMB) MB")) {
            try {
                $taskInfo = $storageFolder.AddStorage($Name, $Description, $Path, $EnableSigning, $Retention.TotalMinutes, $MaximumSizeMB)
                if ($taskInfo.State -ne [videoos.platform.configurationitems.stateenum]::Success) {
                    Write-Error -Message $taskInfo.ErrorText
                    return
                }
                $storageFolder.ClearChildrenCache()
            }
            catch {
                Write-Error $_
                return
            }

            $storage = [VideoOS.Platform.ConfigurationItems.Storage]::new((Get-VmsManagementServer).ServerId, $taskInfo.Path)
        }

        if ($PSCmdlet.ParameterSetName -eq 'WithEncryption' -and $PSCmdlet.ShouldProcess("Recording Storage '$Name'", "Enable '$EncryptionMethod' Encryption")) {
            try {
                $invokeResult = $storage.EnableEncryption($Password, $EncryptionMethod)
                if ($invokeResult.State -ne [videoos.platform.configurationitems.stateenum]::Success) {
                    throw $invokeResult.ErrorText
                }

                $storage = [VideoOS.Platform.ConfigurationItems.Storage]::new((Get-VmsManagementServer).ServerId, $taskInfo.Path)
            }
            catch {
                [void]$storageFolder.RemoveStorage($taskInfo.Path)
                Write-Error $_
                return
            }
        }

        if ($Default -and $PSCmdlet.ShouldProcess("Recording Storage '$Name'", "Set as default storage configuration")) {
            try {
                $invokeResult = $storage.SetStorageAsDefault()
                if ($invokeResult.State -ne [videoos.platform.configurationitems.stateenum]::Success) {
                    throw $invokeResult.ErrorText
                }

                $storage = [VideoOS.Platform.ConfigurationItems.Storage]::new((Get-VmsManagementServer).ServerId, $taskInfo.Path)
            }
            catch {
                [void]$storageFolder.RemoveStorage($taskInfo.Path)
                Write-Error $_
                return
            }
        }

        if (!$PSBoundParameters.ContainsKey('WhatIf')) {
            Write-Output $storage
        }
    }
}
