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

function New-VmsWebhook {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([MilestonePSTools.Webhook])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.1')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('DisplayName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [uri]
        $Address,

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Token,

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
        $invokeInfo = $folder | Invoke-Method -MethodId AddMIPItem
        'ApiVersion', 'Address', 'Token' | ForEach-Object {
            $invokeInfo.Properties += [VideoOS.ConfigurationApi.ClientService.Property]@{
                Key         = $_
                DisplayName = $_
                ValueType   = 'String'
                IsSettable  = $true
            }
        }
        $action = 'Create webhook {0}' -f $Name
        if ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, $action)) {
            $invokeInfo | Set-ConfigurationItemProperty -Key Name -Value $Name
            $invokeInfo | Set-ConfigurationItemProperty -Key Address -Value $Address
            $invokeInfo | Set-ConfigurationItemProperty -Key ApiVersion -Value 'v1.0'
            if (-not [string]::IsNullOrWhiteSpace($Token)) {
                $invokeInfo | Set-ConfigurationItemProperty -Key Token -Value $Token
            }
            $invokeInfo | Invoke-Method -MethodId AddMIPItem | Get-ConfigurationItem | ConvertTo-Webhook
        }
    }
}

