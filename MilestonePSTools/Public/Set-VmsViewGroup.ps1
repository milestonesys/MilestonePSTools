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

function Set-VmsViewGroup {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $ViewGroup,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($key in 'Name', 'Description') {
            if ($MyInvocation.BoundParameters.ContainsKey($key)) {
                $value = $MyInvocation.BoundParameters[$key]
                if ($ViewGroup.$key -ceq $value) { continue }
                if ($PSCmdlet.ShouldProcess($ViewGroup.DisplayName, "Changing $key from $($ViewGroup.$key) to $value")) {
                    $ViewGroup.$key = $value
                    $ViewGroup.Save()
                }
            }
        }
        if ($PassThru) {
            Write-Output $ViewGroup
        }
    }
}

