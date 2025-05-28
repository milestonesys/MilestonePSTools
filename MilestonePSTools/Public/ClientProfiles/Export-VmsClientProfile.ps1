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

function Export-VmsClientProfile {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param (
        [Parameter(ValueFromPipeline)]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.ClientProfile]])]
        [ClientProfileTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.ClientProfile[]]
        $ClientProfile,

        [Parameter(Mandatory, Position = 0)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $ValueTypeInfo
    )

    begin {
        Assert-VmsRequirementsMet

        $resolvedPath = (Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable rpError).Path
        if ([string]::IsNullOrWhiteSpace($resolvedPath)) {
            $resolvedPath = $rpError.TargetObject
        }
        $Path = $resolvedPath
        $fileInfo = [io.fileinfo]$Path
        if (-not $fileInfo.Directory.Exists) {
            throw ([io.directorynotfoundexception]::new("Directory not found: $($fileInfo.Directory.FullName)"))
        }
        if (($fi = [io.fileinfo]$Path).Extension -ne '.json') {
            Write-Verbose "A .json file extension will be added to the file '$($fi.Name)'"
            $Path += ".json"
        }
        $results = [system.collections.generic.list[pscustomobject]]::new()
    }

    process {
        if ($ClientProfile.Count -eq 0) {
            $ClientProfile = Get-VmsClientProfile
        }
        foreach ($p in $ClientProfile) {
            $results.Add([pscustomobject]@{
                Name        = $p.Name
                Description = $p.Description
                Attributes  = $p | Get-VmsClientProfileAttributes -ValueTypeInfo:$ValueTypeInfo
            })
        }
    }

    end {
        $json = ConvertTo-Json -InputObject $results -Depth 10 -Compress
        [io.file]::WriteAllText($Path, $json, [text.encoding]::UTF8)
    }
}

