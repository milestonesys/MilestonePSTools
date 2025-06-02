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

function Remove-VmsStorage {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByName')]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer]
        $RecordingServer,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ByStorage')]
        [VideoOS.Platform.ConfigurationItems.Storage]
        $Storage
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                foreach ($vmsStorage in $RecordingServer | Get-VmsStorage -Name $Name) {
                    $vmsStorage | Remove-VmsStorage
                }
            }

            'ByStorage' {
                $recorder = [VideoOS.Platform.ConfigurationItems.RecordingServer]::new((Get-VmsManagementServer).ServerId, $Storage.ParentItemPath)
                if ($PSCmdlet.ShouldProcess("Recording server $($recorder.Name)", "Delete $($Storage.Name) and all archives")) {
                    $folder = [VideoOS.Platform.ConfigurationItems.StorageFolder]::new((Get-VmsManagementServer).ServerId, $Storage.ParentPath)
                    [void]$folder.RemoveStorage($Storage.Path)
                }
            }
            Default {
                throw 'Unknown parameter set'
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsStorage -ParameterName Name -ScriptBlock {
    $values = (Get-VmsRecordingServer | Get-VmsStorage).Name | Select-Object -Unique | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}
