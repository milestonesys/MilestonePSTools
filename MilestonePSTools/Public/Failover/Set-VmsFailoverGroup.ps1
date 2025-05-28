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

function Set-VmsFailoverGroup {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.FailoverGroup])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [FailoverGroupNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.FailoverGroup]
        $FailoverGroup,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
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
        $dirty = $false
        if (-not [string]::IsNullOrWhiteSpace($Name) -and $Name -cne $FailoverGroup.Name -and $PSCmdlet.ShouldProcess($FailoverGroup.Name, "Rename to $Name")) {
            $FailoverGroup.Name = $Name
            $dirty = $true
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Description') -and $Description -cne $FailoverGroup.Description -and $PSCmdlet.ShouldProcess($FailoverGroup.Name, "Set Description to $Description")) {
            $FailoverGroup.Description = $Description
            $dirty = $true
        }
        if ($dirty) {
            try {
                $FailoverGroup.Save()
            } catch {
                throw
            }
        }
        if ($PassThru) {
            $FailoverGroup
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsFailoverGroup -ParameterName FailoverGroup -ScriptBlock {
    $values = (Get-VmsFailoverGroup).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

