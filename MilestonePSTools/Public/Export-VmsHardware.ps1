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

function Export-VmsHardware {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNull()]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Path')]
        [string]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
        [string]
        $LiteralPath,

        [Parameter()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output')]
        [string[]]
        $DeviceType = @('Camera'),

        [Parameter()]
        [ValidateSet('All', 'Enabled', 'Disabled')]
        [string]
        $EnableFilter = 'Enabled',

        [Parameter()]
        [char]
        $Delimiter = ','
    )

    begin {
        Assert-VmsRequirementsMet
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        }
        $records = [collections.generic.list[VideoOS.Platform.ConfigurationItems.Hardware]]::new()
    }
    
    process {
        if ($Hardware.Count -eq 0) {
            $Hardware = Get-VmsHardware
        }
        
        foreach ($hw in $Hardware) {
            $records.Add($hw)
        }
    }
    
    end {
        if ($LiteralPath -match '\.csv$') {
            $splat = @{
                Hardware     = $records
                EnableFilter = $EnableFilter
                DeviceType   = $DeviceType
            }
            ExportHardwareCsv @splat | Export-Csv -LiteralPath $LiteralPath -Delimiter $Delimiter -NoTypeInformation
        } elseif ($LiteralPath -match '\.xlsx$') {
            if ($null -eq (Get-Module ImportExcel)) {
                if (Get-module ImportExcel -ListAvailable) {
                    Import-Module ImportExcel
                } else {
                    Import-Module "$PSScriptRoot\modules\ImportExcel\7.8.9\ImportExcel.psd1"
                }
            }
            $splat = @{
                Path            = $LiteralPath
                Hardware        = $records
                EnableFilter    = $EnableFilter
                IncludedDevices = $DeviceType
            }
            Export-VmsHardwareExcel @splat
        } else {
            Write-Error -Message 'Invalid file extension. Please specify a file path with either a .CSV or .XLSX extension.' -ErrorId 'InvalidExtension' -Category InvalidArgument
        }
    }
}

