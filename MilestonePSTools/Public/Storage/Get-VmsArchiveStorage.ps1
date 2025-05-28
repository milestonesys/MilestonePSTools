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

function Get-VmsArchiveStorage {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.ArchiveStorage])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Storage]
        $Storage,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $Name = '*'
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $storagesMatched = 0
        $Storage.ArchiveStorageFolder.ArchiveStorages | ForEach-Object {
            if ($_.Name -like $Name) {
                $storagesMatched++
                Write-Output $_
            }
        }

        if ($storagesMatched -eq 0 -and -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name)) {
            Write-Error "No recording storages found matching the name '$Name'"
        }
    }
}

