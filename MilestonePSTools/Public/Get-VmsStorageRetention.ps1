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

function Get-VmsStorageRetention {
    [CmdletBinding()]
    [OutputType([timespan])]
    [RequiresVmsConnection()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [StorageNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Storage[]]
        $Storage
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($Storage.Count -lt 1) {
            $Storage = Get-VmsStorage
        }
        foreach ($s in $Storage) {
            $retention = [int]$s.RetainMinutes
            foreach ($archive in $s.ArchiveStorageFolder.ArchiveStorages) {
                if ($archive.RetainMinutes -gt $retention) {
                    $retention = $archive.RetainMinutes
                }
            }
            [timespan]::FromMinutes($retention)
        }
    }
}


Register-ArgumentCompleter -CommandName Get-VmsStorageRetention -ParameterName Storage -ScriptBlock {
    $values = (Get-VmsRecordingServer | Get-VmsStorage).Name | Select-Object -Unique | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

