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

function Get-VmsStorage {
    [CmdletBinding(DefaultParameterSetName = 'FromName')]
    [OutputType([VideoOS.Platform.ConfigurationItems.Storage])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'FromName')]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer[]]
        $RecordingServer,

        [Parameter(ParameterSetName = 'FromName')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPath')]
        [ValidateScript({
            if ($_ -match 'Storage\[.{36}\]') {
                $true
            }
            else {
                throw "Invalid storage item path. Expected format: Storage[$([guid]::NewGuid())]"
            }
        })]
        [Alias('RecordingStorage', 'Path')]
        [string]
        $ItemPath
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'FromName' {
                if ($null -eq $RecordingServer -or $RecordingServer.Count -eq 0) {
                    $RecordingServer = Get-VmsRecordingServer
                }
                $storagesMatched = 0
                $RecordingServer.StorageFolder.Storages | ForEach-Object {
                    if ($_.Name -like $Name) {
                        $storagesMatched++
                        Write-Output $_
                    }
                }

                if ($storagesMatched -eq 0 -and -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name)) {
                    Write-Error "No recording storages found matching the name '$Name'"
                }
            }
            'FromPath' {
                [VideoOS.Platform.ConfigurationItems.Storage]::new((Get-VmsManagementServer).ServerId, $ItemPath)
            }
            Default {
                throw "ParameterSetName $($PSCmdlet.ParameterSetName) not implemented"
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsStorage -ParameterName Name -ScriptBlock {
    $values = (Get-VmsRecordingServer | Get-VmsStorage).Name | Select-Object -Unique | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}
