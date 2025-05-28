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

function Get-VmsWebhook {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([MilestonePSTools.Webhook])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.1')]
    param (
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name', Position = 0)]
        [SupportsWildcards()]
        [Alias('DisplayName')]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralName')]
        [string]
        $LiteralName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [string]
        $Path,

        # Any unrecognized parameters and their values will be ignored when splatting a hashtable with keys that do not match a parameter name.
        [Parameter(ValueFromRemainingArguments, DontShow)]
        [object[]]
        $ExtraParams
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $folderPath = 'MIPKind[b9a5bc9c-e9a5-4a15-8453-ffa41f2815ac]/MIPItemFolder'

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            if ([string]::IsNullOrWhiteSpace($Path)) {
                Get-ConfigurationItem -Path $folderPath -ChildItems | ConvertTo-Webhook
            } else {
                Get-ConfigurationItem -Path $Path -ErrorAction Stop | ConvertTo-Webhook
            }
            return
        }

        $notFound = $true
        Get-ConfigurationItem -Path $folderPath -ChildItems -PipelineVariable webhook | ForEach-Object {
            switch ($PSCmdlet.ParameterSetName) {
                'Name' {
                    if ($webhook.DisplayName -like $Name) {
                        $notFound = $false
                        $webhook | ConvertTo-Webhook
                    }
                }

                'LiteralName' {
                    if ($webhook.DisplayName -eq $LiteralName) {
                        $notFound = $false
                        $webhook | ConvertTo-Webhook
                    }
                }
            }
        }
        if ($notFound -and ($PSCmdlet.ParameterSetName -eq 'LiteralName' -or -not [Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name))) {
            $Name = if ($PSCmdlet.ParameterSetName -eq 'Name') { $Name } else { $LiteralName }
            Write-Error -Message "Webhook with name matching '$Name' not found." -TargetObject $Name
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsWebhook -ParameterName Name -ScriptBlock {
    $values = (Get-VmsWebhook).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Get-VmsWebhook -ParameterName LiteralName -ScriptBlock {
    $values = (Get-VmsWebhook).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

