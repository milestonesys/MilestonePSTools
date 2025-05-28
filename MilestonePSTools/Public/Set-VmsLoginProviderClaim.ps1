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

function Set-VmsLoginProviderClaim {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.RegisteredClaim]
        $Claim,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $item = $Claim | Get-ConfigurationItem
        $nameProperty = $item.Properties | Where-Object Key -eq 'Name'
        $dirty = $false
        if ($MyInvocation.BoundParameters.ContainsKey('Name') -and $Name -cne $nameProperty.Value) {
            if ($nameProperty.Value -ceq $item.DisplayName) {
                $item.DisplayName = $Name
            }
            $nameProperty.Value = $Name
            $dirty = $true
        }
        if ($MyInvocation.BoundParameters.ContainsKey('DisplayName') -and $DisplayName -cne $item.DisplayName) {
            $item.DisplayName = $DisplayName
            $dirty = $true
        }
        if ($dirty -and $PSCmdlet.ShouldProcess("Registered claim '$($Claim.Name)'", "Update")) {
            $result = $item | Set-ConfigurationItem
        }
        if ($PassThru -and $result.ValidatedOk) {
            $loginProvider = (Get-VmsLoginProvider | Where-Object Path -eq $Claim.ParentItemPath)
            $loginProvider.ClearChildrenCache()
            $loginProvider | Get-VmsLoginProviderClaim -Name $nameProperty.Value
        }
    }
}

