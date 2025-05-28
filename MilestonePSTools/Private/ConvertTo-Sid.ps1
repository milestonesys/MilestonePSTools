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

function ConvertTo-Sid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $AccountName,

        [Parameter()]
        [string]
        $Domain
    )

    process {
        try {
            if ($AccountName -match '^\[BASIC\]\\(?<username>.+)$') {
                $sid = (Get-VmsManagementServer).BasicUserFolder.BasicUsers | Where-Object Name -eq $Matches.username | Select-Object -ExpandProperty Sid
                if ($sid) {
                    $sid
                } else {
                    throw "No basic user found matching '$AccountName'"
                }
            } else {
                [System.Security.Principal.NTAccount]::new($Domain, $AccountName).Translate([System.Security.Principal.SecurityIdentifier]).Value
            }
        } catch [System.Security.Principal.IdentityNotMappedException] {
            Write-Error -ErrorRecord $_
        }
    }
}

