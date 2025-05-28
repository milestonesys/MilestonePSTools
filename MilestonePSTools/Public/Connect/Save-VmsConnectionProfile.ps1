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

function Save-VmsConnectionProfile {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param(
        [Parameter(Position = 0)]
        [string]
        $Name = 'default',

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        $vmsProfiles = GetVmsConnectionProfile -All
        if ($vmsProfiles.ContainsKey($Name) -and -not $Force) {
            Write-Error "Connection profile '$Name' already exists. To overwrite it, use the -Force parameter."
            return
        }
        
        $vmsProfiles[$Name] = ExportVmsLoginSettings -ErrorAction Stop
        $vmsProfiles | Export-Clixml -Path (GetVmsConnectionProfilePath) -Force
    }
}
