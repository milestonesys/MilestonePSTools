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

function Import-VmsClientProfile {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClientProfile])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
        $Path = (Resolve-Path -Path $Path -ErrorAction Stop).Path
        (Get-VmsManagementServer -ErrorAction Stop).ClientProfileFolder.ClearChildrenCache()
        $existingProfiles = @{}
        Get-VmsClientProfile | Foreach-Object {
            $existingProfiles[$_.Name] = $_
        }
        $showVerbose = $VerbosePreference -eq 'Continue'
    }

    process {
        $definitions = [io.file]::ReadAllText($Path, [text.encoding]::UTF8) | ConvertFrom-Json
        foreach ($def in $definitions) {
            try {
                if ($existingProfiles.ContainsKey($def.Name)) {
                    if ($Force) {
                        $current = $existingProfiles[$def.Name]
                        $current | Set-VmsClientProfile -Description $def.Description -ErrorAction Stop -Verbose:$showVerbose
                    } else {
                        Write-Error "ClientProfile '$($def.Name)' already exists. To overwrite existing profiles, try including the -Force switch."
                        continue
                    }
                } else {
                    $current = New-VmsClientProfile -Name $def.Name -Description $def.Description -ErrorAction Stop
                    $existingProfiles[$current.Name] = $current
                }
                foreach ($psObj in $def.Attributes) {
                    $attributes = @{}
                    foreach ($memberName in ($psObj | Get-Member -MemberType NoteProperty).Name) {
                        $attributes[$memberName] = $psObj.$memberName
                    }
                    $current | Set-VmsClientProfileAttributes -Attributes $attributes -Verbose:$showVerbose
                }
                $current
            } catch {
                Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $def
            }
        }
    }
}

