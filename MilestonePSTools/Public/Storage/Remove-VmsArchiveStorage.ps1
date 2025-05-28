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

function Remove-VmsArchiveStorage {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByName')]
        [VideoOS.Platform.ConfigurationItems.Storage]
        $Storage,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByStorage')]
        [VideoOS.Platform.ConfigurationItems.ArchiveStorage]
        $ArchiveStorage
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                foreach ($archiveStorage in $Storage | Get-VmsArchiveStorage -Name $Name) {
                    $archiveStorage | Remove-VmsArchiveStorage
                }
            }

            'ByStorage' {
                $recorder = [VideoOS.Platform.ConfigurationItems.RecordingServer]::new((Get-VmsManagementServer).ServerId, $Storage.ParentItemPath)
                $storage = [VideoOS.Platform.ConfigurationItems.Storage]::new((Get-VmsManagementServer).ServerId, $ArchiveStorage.ParentItemPath)
                if ($PSCmdlet.ShouldProcess("Recording server $($recorder.Name)", "Delete archive $($ArchiveStorage.Name) from $($storage.Name)")) {
                    $folder = [VideoOS.Platform.ConfigurationItems.ArchiveStorageFolder]::new((Get-VmsManagementServer).ServerId, $ArchiveStorage.ParentPath)
                    [void]$folder.RemoveArchiveStorage($ArchiveStorage.Path)
                }
            }
            Default {
                throw 'Unknown parameter set'
            }
        }
    }
}

