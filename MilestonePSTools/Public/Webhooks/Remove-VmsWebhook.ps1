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

function Remove-VmsWebhook {
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess)]
    [RequiresVmsVersion('23.1')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Name', Position = 0)]
        [Alias('DisplayName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
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
        $folder = Get-ConfigurationItem -Path 'MIPKind[b9a5bc9c-e9a5-4a15-8453-ffa41f2815ac]/MIPItemFolder'
        $invokeInfo = $folder | Invoke-Method -MethodId RemoveMIPItem
        if ([string]::IsNullOrWhiteSpace($Path)) {
            $valueTypeInfo = $invokeInfo.Properties[0].ValueTypeInfos | Where-Object Name -EQ $Name
            if ($null -eq $valueTypeInfo) {
                Write-Error -Message "Webhook with name '$Name' not found." -TargetObject $Name
                return
            }
            if ($valueTypeInfo.Count -gt 1) {
                Write-Error -Message "Multiple webhooks found with name '$Name'. To remove a specific webhook, use 'Get-VmsWebhook -Name ''$Name'' | Remove-VmsWebhook'." -TargetObject $Name
                return
            }
            $Path = $valueTypeInfo.Value
        } else {
            $Name = ($invokeInfo.Properties[0].ValueTypeInfos | Where-Object Value -EQ $Path).Name
        }
        
        $action = 'Remove webhook {0}' -f $Name
        if ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, $action)) {
            $invokeInfo | Set-ConfigurationItemProperty -Key ItemSelection -Value $Path
            $null = $invokeInfo | Invoke-Method -MethodId RemoveMIPItem
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsWebhook -ParameterName Name -ScriptBlock {
    $values = (Get-VmsWebhook).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

