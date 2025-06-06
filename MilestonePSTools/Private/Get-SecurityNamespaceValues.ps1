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

function Get-SecurityNamespaceValues {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Private function.')]
    param ()
    
    process {
        if (-not [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache.ContainsKey('SecurityNamespaceValues')) {
            [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespacesById'] = [Collections.Generic.Dictionary[[string], [string]]]::new()
            
            if (($r = (Get-VmsManagementServer).RoleFolder.Roles | Where-Object RoleType -EQ 'UserDefined' | Select-Object -First 1)) {
                $task = $r.ChangeOverallSecurityPermissions()
                [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespaceValues'] = $task.SecurityNamespaceValues
                $task.SecurityNamespaceValues.GetEnumerator() | ForEach-Object {
                    [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespacesById'][$_.Value] = $_.Key
                }
            } else {
                [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespaceValues'] = [Collections.Generic.Dictionary[[string], [string]]]::new()
            }
        }
        [pscustomobject]@{
            SecurityNamespacesByName = [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespaceValues']
            SecurityNamespacesById   = [MilestonePSTools.Connection.MilestoneConnection]::Instance.Cache['SecurityNamespacesById']
        }
    }
}
