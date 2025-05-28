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

function Set-VmsConnectionString {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection($false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Component,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $ConnectionString,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($null -eq (Get-Item -Path HKLM:\SOFTWARE\VideoOS\Server\ConnectionString -ErrorAction Ignore)) {
            Write-Error "Could not find the registry key 'HKLM:\SOFTWARE\VideoOS\Server\ConnectionString'. This key was introduced in 2022 R3, and this cmdlet is only compatible with VMS versions 2022 R3 and later."
            return
        }

        $currentValue = Get-VmsConnectionString -Component $Component -ErrorAction SilentlyContinue
        if ($null -eq $currentValue) {
            if ($Force) {
                if ($PSCmdlet.ShouldProcess((hostname), "Create new connection string value for $Component")) {
                    $null = New-ItemProperty -Path HKLM:\SOFTWARE\VideoOS\Server\ConnectionString -Name $Component -Value $ConnectionString
                }
            } else {
                Write-Error "A connection string for $Component does not exist. Retry with the -Force switch to create one anyway."
            }
        } else {
            if ($PSCmdlet.ShouldProcess((hostname), "Change connection string value of $Component")) {
                Set-ItemProperty -Path HKLM:\SOFTWARE\VideoOS\Server\ConnectionString -Name $Component -Value $ConnectionString
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsConnectionString -ParameterName Component -ScriptBlock {
    $values = Get-Item HKLM:\SOFTWARE\videoos\Server\ConnectionString\ -ErrorAction Ignore | Select-Object -ExpandProperty Property
    if ($values) {
        Complete-SimpleArgument $args $values
    }
}

