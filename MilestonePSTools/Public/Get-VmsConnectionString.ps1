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

function Get-VmsConnectionString {
    [CmdletBinding()]
    [Alias('Get-ConnectionString')]
    [OutputType([string])]
    [RequiresVmsConnection($false)]
    param (
        [Parameter(Position = 0)]
        [string]
        $Component = 'ManagementServer'
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if (Get-Item -Path HKLM:\SOFTWARE\VideoOS\Server\ConnectionString -ErrorAction Ignore) {
            Get-ItemPropertyValue -Path HKLM:\SOFTWARE\VideoOS\Server\ConnectionString -Name $Component
        } else {
            if ($Component -ne 'ManagementServer') {
                Write-Warning "Specifying a component name is only allowed on a management server running version 2022 R3 (22.3) or greater."
            }
            Get-ItemPropertyValue -Path HKLM:\SOFTWARE\VideoOS\Server\Common -Name 'Connectionstring'
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsConnectionString -ParameterName Component -ScriptBlock {
    $values = Get-Item HKLM:\SOFTWARE\videoos\Server\ConnectionString\ -ErrorAction Ignore | Select-Object -ExpandProperty Property
    if ($values) {
        Complete-SimpleArgument $args $values
    }
}

