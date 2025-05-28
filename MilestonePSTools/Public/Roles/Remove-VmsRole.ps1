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

function Remove-VmsRole {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByName')]
    [Alias('Remove-Role')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.Role]])]
        [Alias('RoleName', 'Name')]
        [RoleNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Role]
        $Role,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ById')]
        [Alias('RoleId')]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($null -eq $Role) {
            $Role = Get-VmsRole -Id $Id -ErrorAction Stop
        }
        if (-not $PSCmdlet.ShouldProcess("Role: $($Role.Name)", "Delete")) {
            return
        }
        try {
            $folder = (Get-VmsManagementServer).RoleFolder
            $invokeResult = $folder.RemoveRole($Role.Path)
            if ($invokeResult.State -ne 'Success') {
                throw "Error removing role '$($Role.Name)'. $($invokeResult.GetProperty('ErrorText'))"
            }
        }
        catch {
            Write-Error -ErrorRecord $_
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsRole -ParameterName Id -ScriptBlock {
    $values = (Get-VmsRole | Sort-Object Name).Id
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

