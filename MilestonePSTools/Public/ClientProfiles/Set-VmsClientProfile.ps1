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

function Set-VmsClientProfile {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClientProfile])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[ClientProfile]])]
        [MipItemTransformation([ClientProfile])]
        [ClientProfile]
        $ClientProfile,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Priority,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        if ($MyInvocation.BoundParameters.ContainsKey('Priority')) {
            (Get-VmsManagementServer -ErrorAction Stop).ClientProfileFolder.ClearChildrenCache()
            $clientProfiles = Get-VmsClientProfile
        }
    }

    process {
        try {
            $dirty = $false
            if (-not [string]::IsNullOrWhiteSpace($Name) -and $Name -cne $ClientProfile.Name) {
                $dirty = $true
            } else {
                $Name = $ClientProfile.Name
            }
            if ($MyInvocation.BoundParameters.ContainsKey('Description') -and $Description -cne $ClientProfile.Description) {
                $dirty = $true
            } else {
                $Description = $ClientProfile.Description
            }

            $priorityDifference = 0
            if ($MyInvocation.BoundParameters.ContainsKey('Priority')) {
                $currentPriority = 1..($clientProfiles.Count) | Where-Object { $ClientProfile.Path -eq $clientProfiles[$_ - 1].Path }
                $priorityDifference = $Priority - $currentPriority
                if ($priorityDifference) {
                    $dirty = $true
                }
            }

            if ($dirty -and $PSCmdlet.ShouldProcess("ClientProfile '$($ClientProfile.Name)'", "Update")) {
                if ($MyInvocation.BoundParameters.ContainsKey('Name') -or $MyInvocation.BoundParameters.ContainsKey('Description')) {
                    $ClientProfile.Name = $Name
                    $ClientProfile.Description = $Description
                    $ClientProfile.Save()
                }

                if ($priorityDifference -lt 0) {
                    do {
                        $null = $ClientProfile.ClientProfileUpPriority()
                    } while ((++$priorityDifference))
                } elseif ($priorityDifference -gt 0) {
                    $priorityDifference = [math]::Min($priorityDifference, $clientProfiles.Count)
                    do {
                        $null = $ClientProfile.ClientProfileDownPriority()
                    } while ((--$priorityDifference))
                }
            }

            if ($PassThru) {
                $ClientProfile
            }
        } catch {
            Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $ClientProfile
        }
    }

    end {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
    }
}

