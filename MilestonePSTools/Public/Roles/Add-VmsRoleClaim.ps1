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

function Add-VmsRoleClaim {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('RoleName')]
        [ValidateNotNull()]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [VideoOS.Platform.ConfigurationItems.LoginProvider]
        $LoginProvider,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2)]
        [string]
        $ClaimName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 3)]
        [string]
        $ClaimValue
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($r in $Role) {
            if ($PSCmdlet.ShouldProcess("$($Role.Name)", "Add claim '$ClaimName' with value '$ClaimValue'")) {
                $null = $r.ClaimFolder.AddRoleClaim($LoginProvider.Id, $ClaimName, $ClaimValue)
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Add-VmsRoleClaim -ParameterName ClaimName -ScriptBlock {
    $values = (Get-VmsLoginProvider | Get-VmsLoginProviderClaim).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

