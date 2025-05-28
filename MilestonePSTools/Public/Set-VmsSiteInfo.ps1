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

function Set-VmsSiteInfo {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ ValidateSiteInfoTagName @args })]
        [string]
        $Property,

        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateLength(1, 256)]
        [string]
        $Value,

        [Parameter()]
        [switch]
        $Append
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $ownerPath = 'BasicOwnerInformation[{0}]' -f (Get-VmsManagementServer).Id
        $ownerInfo = Get-ConfigurationItem -Path $ownerPath

        $existingProperties = $ownerInfo.Properties.Key | Foreach-Object { $_ -split '/' | Select-Object -Last 1 }
        if ($Property -in $existingProperties -and -not $Append) {
            # Update existing entry instead of adding a new one
            if ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, "Change $Property entry value to '$Value' in site information")) {
                $p = $ownerInfo.Properties | Where-Object { $_.Key.EndsWith($Property) }
                if ($p.Count -gt 1) {
                    Write-Warning "Site information has multiple values for $Property. Only the first value can be updated with this command."
                    $p = $p[0]
                }
                $p.Value = $Value
                $invokeResult = $ownerInfo | Set-ConfigurationItem
                if (($invokeResult.Properties | Where-Object Key -eq 'State').Value -ne 'Success') {
                    Write-Error "Failed to update Site Information: $($invokeResult.Properties | Where-Object Key -eq 'ErrorText')"
                }
            }
        } elseif ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, "Add $Property entry with value '$Value' to site information")) {
            # Add new, or additional entry for the given property value
            $invokeInfo = $ownerInfo | Invoke-Method -MethodId AddBasicOwnerInfo
            foreach ($p in $invokeInfo.Properties) {
                switch ($p.Key) {
                    'TagType' { $p.Value = $Property }
                    'TagValue' { $p.Value = $Value }
                }
            }
            $invokeResult = $invokeInfo | Invoke-Method -MethodId AddBasicOwnerInfo
            if (($invokeResult.Properties | Where-Object Key -eq 'State').Value -ne 'Success') {
                Write-Error "Failed to update Site Information: $($invokeResult.Properties | Where-Object Key -eq 'ErrorText')"
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsSiteInfo -ParameterName Property -ScriptBlock { OwnerInfoPropertyCompleter @args }

