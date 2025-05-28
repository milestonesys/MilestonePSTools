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

function ConvertFrom-GisPoint {
    [CmdletBinding()]
    [OutputType([system.device.location.geocoordinate])]
    [RequiresVmsConnection($false)]
    param (
        # Specifies the GisPoint value to convert to a GeoCoordinate. Milestone stores GisPoint data in the format "POINT ([longitude] [latitude])" or "POINT EMPTY".
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string]
        $GisPoint
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($GisPoint -eq 'POINT EMPTY') {
            Write-Output ([system.device.location.geocoordinate]::Unknown)
        }
        else {
            $temp = $GisPoint.Substring(7, $GisPoint.Length - 8)
            $long, $lat, $null = $temp -split ' '
            Write-Output ([system.device.location.geocoordinate]::new($lat, $long))
        }
    }
}

