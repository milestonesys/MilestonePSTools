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

function Get-VmsRecordingServer {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [Alias('Get-RecordingServer')]
    [OutputType([VideoOS.Platform.ConfigurationItems.RecordingServer])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.RecordingServer]])]
        [string]
        $Name = '*',

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ById')]
        [guid]
        $Id,

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByHostname')]
        [Alias('ComputerName')]
        [string]
        $HostName = '*'
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $matchFound = $false
                foreach ($rec in (Get-VmsManagementServer).RecordingServerFolder.RecordingServers | Where-Object Name -like $Name) {
                    $matchFound = $true
                    $rec
                }
                if (-not $matchFound -and -not [system.management.automation.wildcardpattern]::ContainsWildcardCharacters($Name)) {
                    Write-Error "No item found with name matching '$Name'"
                }
            }
            'ById' {
                try {
                    [VideoOS.Platform.ConfigurationItems.RecordingServer]::new((Get-VmsManagementServer).ServerId, "RecordingServer[$Id]")
                }
                catch [VideoOS.Platform.PathNotFoundMIPException] {
                    Write-Error -Message "No item found with id matching '$Id'" -Exception $_.Exception
                }
            }
            'ByHostname' {
                $matchFound = $false
                foreach ($rec in (Get-VmsManagementServer).RecordingServerFolder.RecordingServers | Where-Object HostName -like $HostName) {
                    $matchFound = $true
                    $rec
                }
                if (-not $matchFound -and -not [system.management.automation.wildcardpattern]::ContainsWildcardCharacters($HostName)) {
                    Write-Error "No item found with hostname matching '$HostName'"
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsRecordingServer -ParameterName HostName -ScriptBlock {
    $values = (Get-VmsRecordingServer).HostName | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Get-VmsRecordingServer -ParameterName Id -ScriptBlock {
    $values = (Get-VmsRecordingServer | Sort-Object Name).Id
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

