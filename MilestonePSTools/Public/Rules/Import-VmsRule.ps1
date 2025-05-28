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

function Import-VmsRule {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.ConfigurationApi.ClientService.ConfigurationItem])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromObject')]
        [ValidateScript({
                $members = $_ | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                foreach ($member in @('DisplayName', 'Enabled', 'Id', 'Properties')) {
                    if ($member -notin $members) {
                        throw "InputObject is missing member named '$member'"
                    }
                }
                $true
            })]
        [object[]]
        $InputObject,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'FromFile')]
        [string]
        $Path
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $progressParams = @{
                Activity        = 'Importing rules'
                PercentComplete = 0
            }
            Write-Progress @progressParams
            if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
                $Path = (Resolve-Path -Path $Path -ErrorAction Stop).Path
                $InputObject = [io.file]::ReadAllText($Path, [text.encoding]::UTF8) | ConvertFrom-Json
            }
            $total = $InputObject.Count
            $processed = 0
            foreach ($exportedRule in $InputObject) {
                try {
                    $progressParams.CurrentOperation = "Importing rule '$($exportedRule.DisplayName)'"
                    $progressParams.PercentComplete = $processed / $total * 100
                    $progressParams.Status = ($progressParams.PercentComplete / 100).ToString('p0')
                    Write-Progress @progressParams

                    if ($PSCmdlet.ShouldProcess($exportedRule.DisplayName, "Create rule")) {
                        $newRule = $exportedRule | New-VmsRule -ErrorAction Stop
                        $newRule
                    }
                } catch {
                    Write-Error -ErrorRecord $_
                } finally {
                    $processed++
                }
            }
        } finally {
            $progressParams.Completed = $true
            $progressParams.PercentComplete = 100
            Write-Progress @progressParams
        }
    }
}

