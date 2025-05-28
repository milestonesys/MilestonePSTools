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

function Clear-VmsSiteInfo {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    param (
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $ownerInfoFolder = (Get-VmsManagementServer).BasicOwnerInformationFolder
        $ownerInfoFolder.ClearChildrenCache()
        $ownerInfo = $ownerInfoFolder.BasicOwnerInformations[0]
        foreach ($key in $ownerInfo.Properties.KeysFullName) {
            if ($key -match '^\[(?<id>[a-fA-F0-9\-]{36})\]/(?<tagtype>[\w\.]+)$') {
                if ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, "Remove $($Matches.tagtype) entry with value '$($ownerInfo.Properties.GetValue($key))' in site information")) {
                    $invokeResult = $ownerInfo.RemoveBasicOwnerInfo($Matches.id)
                    if ($invokeResult.State -ne 'Success') {
                        Write-Error "An error occurred while removing a site information property: $($invokeResult.ErrorText)"
                    }
                }
            } else {
                Write-Warning "Site information property key format unrecognized: $key"
            }
        }
    }
}

