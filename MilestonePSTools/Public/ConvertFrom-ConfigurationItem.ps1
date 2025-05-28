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

function ConvertFrom-ConfigurationItem {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param(
        # Specifies the Milestone Configuration API 'Path' value of the configuration item. For example, 'Hardware[a6756a0e-886a-4050-a5a5-81317743c32a]' where the guid is the ID of an existing Hardware item.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Path,

        # Specifies the Milestone 'ItemType' value such as 'Camera', 'Hardware', or 'InputEvent'
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ItemType
    )

    begin {
        Assert-VmsRequirementsMet
        $assembly = [System.Reflection.Assembly]::GetAssembly([VideoOS.Platform.ConfigurationItems.Hardware])
        $serverId = (Get-VmsSite -ErrorAction Stop).FQID.ServerId
    }

    process {
        if ($Path -eq '/') {
            [VideoOS.Platform.ConfigurationItems.ManagementServer]::new($serverId)
        } else {
            $instance = $assembly.CreateInstance("VideoOS.Platform.ConfigurationItems.$ItemType", $false, [System.Reflection.BindingFlags]::Default, $null, (@($serverId, $Path)), $null, $null)
            Write-Output $instance
        }
    }
}

