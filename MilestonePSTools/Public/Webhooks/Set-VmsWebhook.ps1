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

function Set-VmsWebhook {
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess)]
    [OutputType([MilestonePSTools.Webhook])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.1')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Name', Position = 0)]
        [Alias('DisplayName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [string]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $NewName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [uri]
        $Address,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Token,

        [Parameter()]
        [switch]
        $PassThru,

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
                Write-Error -Message "Multiple webhooks found with name '$Name'. Use 'Get-VmsWebhook' to find the one to update, and pipe it to Set-VmsWebhook instead to use the Path parameter rather than the Name." -TargetObject $Name
                return
            }
            $Path = $valueTypeInfo.Value
        }

        $webhook = Get-ConfigurationItem -Path $Path -ErrorAction Stop
        $dirty = $false
        'NewName', 'Address', 'Token' | ForEach-Object {
            if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey($_)) {
                return
            }
            $key = $_ -replace 'New', ''
            $property = $webhook.Properties | Where-Object Key -EQ $key
            if ($null -eq $property) {
                $dirty = $false
                throw "Property with key '$key' not found."
            }
            $currentValue = $property.Value
            $newValue = (Get-Variable -Name $_).Value
            if ($currentValue -cne $newValue) {
                Write-Verbose "Changing $key from '$currentValue' to '$newValue' on webhook '$($webhook.DisplayName)'"
                $dirty = $true
                $property.Value = $newValue
            }
        }

        $action = 'Update webhook {0}' -f $webhook.DisplayName
        if ($dirty -and $PSCmdlet.ShouldProcess((Get-VmsSite).Name, $action)) {
            $null = $webhook | Set-ConfigurationItem -ErrorAction Stop
        }
        if ($PassThru) {
            $webhook | Get-VmsWebhook
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsWebhook -ParameterName Name -ScriptBlock {
    $values = (Get-VmsWebhook).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

