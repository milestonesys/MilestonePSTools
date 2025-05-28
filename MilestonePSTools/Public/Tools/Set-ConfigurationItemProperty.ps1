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

function Set-ConfigurationItemProperty {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        [Parameter(Mandatory)]
        [string]
        [ValidateNotNullOrEmpty()]
        $Key,
        [Parameter(Mandatory)]
        [string]
        [ValidateNotNullOrEmpty()]
        $Value,
        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $property = $InputObject.Properties | Where-Object Key -eq $Key
        if ($null -eq $property) {
            Write-Error -Message "Key '$Key' not found on configuration item $($InputObject.Path)" -TargetObject $InputObject -Category InvalidArgument
            return
        }
        $property.Value = $Value
        if ($PassThru) {
            $InputObject
        }
    }
}

