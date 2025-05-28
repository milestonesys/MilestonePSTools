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

function Get-BankTable {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    param (
        [Parameter()]
        [string]
        $Path,
        [Parameter()]
        [string[]]
        $DeviceId,
        [Parameter()]
        [DateTime]
        $StartTime = [DateTime]::MinValue,
        [Parameter()]
        [DateTime]
        $EndTime = [DateTime]::MaxValue.AddHours(-1)
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $di = [IO.DirectoryInfo]$Path
        foreach ($table in $di.EnumerateDirectories()) {
            if ($table.Name -match "^(?<id>[0-9a-fA-F\-]{36})(_(?<tag>\w+)_(?<endTime>\d\d\d\d-\d\d-\d\d_\d\d-\d\d-\d\d).*)?") {
                $tableTimestamp = if ($null -eq $Matches["endTime"]) { (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") } else { $Matches["endTime"] }
                $timestamp = [DateTime]::ParseExact($tableTimestamp, "yyyy-MM-dd_HH-mm-ss", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeLocal)
                if ($timestamp -lt $StartTime -or $timestamp -gt $EndTime.AddHours(1)) {
                    # Timestamp of table is outside the requested timespan
                    continue
                }
                if ($null -ne $DeviceId -and [cultureinfo]::InvariantCulture.CompareInfo.IndexOf($DeviceId, $Matches["id"], [System.Globalization.CompareOptions]::IgnoreCase) -eq -1) {
                    # Device ID for table is not requested
                    continue
                }
                [pscustomobject]@{
                    DeviceId = [Guid]$Matches["id"]
                    EndTime = $timestamp
                    Tag = $Matches["tag"]
                    IsLiveTable = $null -eq $Matches["endTime"]
                    Path = $table.FullName
                }
            }
        }
    }
}

