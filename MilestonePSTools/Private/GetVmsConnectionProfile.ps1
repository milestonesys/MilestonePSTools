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

function GetVmsConnectionProfile {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $Name = 'default',

        [Parameter(ParameterSetName = 'All')]
        [switch]
        $All
    )

    begin {
        if (-not (Test-Path -Path (GetVmsConnectionProfilePath))) {
            @{} | Export-Clixml -Path (GetVmsConnectionProfilePath)
        }
        $vmsProfiles = (Import-Clixml -Path (GetVmsConnectionProfilePath)) -as [hashtable]
    }

    process {
        if ($All) {
            $vmsProfiles
        } elseif ($vmsProfiles.ContainsKey($Name)) {
            $vmsProfiles[$Name]
        }
    }
}
