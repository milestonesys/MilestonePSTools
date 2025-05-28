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

function Add-VmsArchiveStorage {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.ArchiveStorage])]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Storage]
        $Storage,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter()]
        [ValidateTimeSpanRange('00:01:00', '365000.00:00:00')]
        [timespan]
        $Retention,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $MaximumSizeMB,

        [Parameter()]
        [switch]
        $ReduceFramerate,

        [Parameter()]
        [ValidateRange(0.00028, 100)]
        [double]
        $TargetFramerate = 5
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $archiveFolder = $Storage.ArchiveStorageFolder
        if ($PSCmdlet.ShouldProcess("Recording storage '$($Storage.Name)'", "Add new archive storage named '$($Name)' with retention of $($Retention.TotalHours) hours and a maximum size of $($MaximumSizeMB) MB")) {
            try {
                $taskInfo = $archiveFolder.AddArchiveStorage($Name, $Description, $Path, $TargetFrameRate, $Retention.TotalMinutes, $MaximumSizeMB)
                if ($taskInfo.State -ne [videoos.platform.configurationitems.stateenum]::Success) {
                    Write-Error -Message $taskInfo.ErrorText
                    return
                }

                $archive = [VideoOS.Platform.ConfigurationItems.ArchiveStorage]::new((Get-VmsManagementServer).ServerId, $taskInfo.Path)

                if ($ReduceFramerate) {
                    $invokeInfo = $archive.SetFramerateReductionArchiveStorage()
                    $invokeInfo.SetProperty('FramerateReductionEnabled', 'True')
                    [void]$invokeInfo.ExecuteDefault()
                }

                $storage.ClearChildrenCache()
                Write-Output $archive
            }
            catch {
                Write-Error $_
                return
            }
        }
    }
}

