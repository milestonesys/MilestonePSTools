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

function Import-VmsHardware {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [string[]]
        $Path,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [string[]]
        $LiteralPath,

        [Parameter()]
        [VideoOS.Platform.ConfigurationItems.RecordingServer]
        $RecordingServer,

        [Parameter()]
        [pscredential[]]
        $Credential,

        [Parameter()]
        [switch]
        $UpdateExisting,

        [Parameter()]
        [char]
        $Delimiter = ','
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $validExtensions = '.csv', '.xlsx'
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath = $Path | ForEach-Object {
                $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($_)
            } | ForEach-Object {
                $fileInfo = [io.fileinfo](Split-Path $_.Path -Leaf)
                if ($fileInfo.Extension -notin $validExtensions) {
                    throw "Invalid file extension $($fileInfo.Extension). Valid extensions include $($validExtensions -join ', ')"
                }
                $_.Path
            }
        }

        
        foreach ($filePath in $LiteralPath) {
            $splat = @{
                Path           = $filePath
                UpdateExisting = $UpdateExisting
            }
            if ($Credential.Count -gt 0) {
                $splat.Credential = $Credential
            }
            if ($null -ne $RecordingServer) {
                $splat.RecordingServer = $RecordingServer
            }
            $fileInfo = [io.fileinfo](Split-Path $filePath -Leaf)
            switch ($fileInfo.Extension) {
                '.csv' {
                    $splat.Delimiter = $Delimiter
                    ImportHardwareCsv @splat
                }

                '.xlsx' {
                    if ($null -eq (Get-Module ImportExcel)) {
                        if (Get-module ImportExcel -ListAvailable) {
                            Import-Module ImportExcel
                        } else {
                            Import-Module "$PSScriptRoot\modules\ImportExcel\7.8.9\ImportExcel.psd1"
                        }
                    }
                    Import-VmsHardwareExcel @splat
                }

                default {
                    throw "Support for file extension $_ not implemented."
                }
            }
        }
    }
}
