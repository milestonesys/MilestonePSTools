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

function ConvertTo-GisPoint {
    [CmdletBinding()]
    [OutputType([string])]
    [RequiresVmsConnection($false)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromGeoCoordinate')]
        [system.device.location.geocoordinate]
        $Coordinate,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromValues')]
        [double]
        $Latitude,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromValues')]
        [double]
        $Longitude,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'FromValues')]
        [double]
        $Altitude = [double]::NaN,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromString')]
        [string]
        $Coordinates
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {

        switch ($PsCmdlet.ParameterSetName) {
            'FromValues' {
                break
            }

            'FromGeoCoordinate' {
                $Latitude = $Coordinate.Latitude
                $Longitude = $Coordinate.Longitude
                $Altitude = $Coordinate.Altitude
                break
            }

            'FromString' {
                $values = $Coordinates -split ',' | Foreach-Object {
                    [double]$_.Trim()
                }
                if ($values.Count -lt 2 -or $values.Count -gt 3) {
                    Write-Error "Failed to parse coordinates into latitude, longitude and optional altitude."
                    return
                }
                $Latitude = $values[0]
                $Longitude = $values[1]
                if ($values.Count -gt 2) {
                    $Altitude = $values[2]
                }
                break
            }
        }

        if ([double]::IsNan($Altitude)) {
            Write-Output ('POINT ({0} {1})' -f $Longitude, $Latitude)
        }
        else {
            Write-Output ('POINT ({0} {1} {2})' -f $Longitude, $Latitude, $Altitude)
        }
    }
}

