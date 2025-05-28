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

function Get-VmsFailoverGroup {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([VideoOS.Platform.ConfigurationItems.FailoverGroup])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [guid]
        $Id,

        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [string]
        $Name = '*'
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Id' {
                try {
                    $serverId = (Get-VmsManagementServer).ServerId
                    $path = 'FailoverGroup[{0}]' -f $Id
                    [VideoOS.Platform.ConfigurationItems.FailoverGroup]::new($serverId, $path)
                } catch {
                    throw
                }
            }
            'Name' {
                foreach ($group in (Get-VmsManagementServer).FailoverGroupFolder.FailoverGroups | Where-Object Name -like $Name) {
                    $group
                }
            }
            Default {
                throw "ParameterSetName '$_' not implemented."
            }
        }
    }
}


Register-ArgumentCompleter -CommandName Get-VmsFailoverGroup -ParameterName Name -ScriptBlock {
    $values = (Get-VmsFailoverGroup).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

