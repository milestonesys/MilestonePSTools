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

function Show-DeprecationWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo
    )

    process {
        $oldName = $InvocationInfo.InvocationName
        if ($script:Deprecations.ContainsKey($oldName)) {
            $newName = $script:deprecations[$oldName]
            Write-Warning "The '$oldName' cmdlet is deprecated. To minimize the risk of being impacted by a breaking change in the future, please use '$newName' instead."
            $script:Deprecations.Remove($oldName)
        }
    }
}

