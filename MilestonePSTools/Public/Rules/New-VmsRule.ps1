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

function New-VmsRule {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.ConfigurationApi.ClientService.ConfigurationItem])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.1')]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('DisplayName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [PropertyCollectionTransformAttribute()]
        [hashtable]
        $Properties,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('EnableProperty')]
        [BooleanTransformAttribute()]
        [bool]
        $Enabled = $true
    )

    begin {
        Assert-VmsRequirementsMet
        $ruleFolder = Get-ConfigurationItem -Path /RuleFolder
    }

    process {
        if (-not $PSCmdlet.ShouldProcess($Name, "Create rule")) {
            return
        }
        $invokeInfo = $null
        try {
            $Properties['Name'] = $Name
            $invokeInfo = $ruleFolder | Invoke-Method -MethodId AddRule
            $lastPropertyCount = $invokeInfo.Properties.Count
            $iteration = 0
            $maxIterations = 20
            $filledProperties = @{ Id = $null }
            do {
                if ((++$iteration) -ge $maxIterations) {
                    $propertyDump = ($invokeInfo.Properties | Select-Object Key, Value, @{Name = 'ValueTypeInfos'; Expression = { $_.ValueTypeInfos.Value -join '|'}}) | Format-Table | Out-String
                    Write-Verbose "InvokeInfo Properties:`r`n$propertyDump"

                    $exception = [invalidoperationexception]::new("Maximum request/response iterations reached while creating rule. This can happen when the supplied properties hashtable is missing important key/value pairs or when a provided value is incorrect. Inspect the 'Properties' collection on the TargetObject property on this ErrorRecord.")
                    $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $exception.Message, [System.Management.Automation.ErrorCategory]::InvalidData, $invokeInfo)
                    throw $errorRecord
                }
                try {
                    foreach ($key in $invokeInfo.Properties.Key) {
                        # Skip key if already set in a previous iteration
                        if ($filledProperties.ContainsKey($key)) {
                            continue
                        } else {
                            $filledProperties[$key] = $null
                        }

                        # If imported rule definition doesn't have a property that the configuration api has,
                        # we might be able to finish creating the rule, or we might end up in a perpetual loop
                        # until we reach $maxIterations and fail.
                        if (-not $Properties.ContainsKey($key)) {
                            Write-Verbose "Property with key '$key' not provided in Properties hashtable for new rule '$($Name)'."
                            continue
                        }

                        # Protect against null or empty property values
                        if ([string]::IsNullOrWhiteSpace($Properties[$key])) {
                            continue
                        }
                        $newRuleProperty = $invokeInfo.Properties | Where-Object Key -eq $key
                        switch ($newRuleProperty.ValueType) {
                            'Enum' {
                                # Use the enum value with the same supplied value using case-insensitive comparison
                                $newValue = ($newRuleProperty.ValueTypeInfos | Where-Object Value -eq $Properties[$key]).Value
                                if ($null -eq $newValue) {
                                    # The user-supplied value doesn't match any enum values so compare against the enum value display names
                                    $newValue = ($newRuleProperty.ValueTypeInfos | Where-Object Name -eq $Properties[$key]).Value
                                    if ($null -eq $newValue) {
                                        Write-Warning "Value for user-supplied property '$key' does not match the available options: $($newRuleProperty.ValueTypeInfos.Value -join ', ')."
                                        $newValue = $Properties[$key]
                                    } else {
                                        Write-Verbose "Value for user-supplied property '$key' has been mapped from '$($Properties[$key])' to '$newValue'"
                                    }
                                }
                                $Properties[$key] = $newValue
                            }
                        }
                        $invokeInfo | Set-ConfigurationItemProperty -Key $key -Value $Properties[$key]
                    }

                    $response = $invokeInfo | Invoke-Method AddRule -ErrorAction Stop
                    $invokeInfo = $response
                    $newPropertyCount = $invokeInfo.Properties.Count
                    if ($lastPropertyCount -ge $newPropertyCount -and $null -eq ($invokeInfo | Get-ConfigurationItemProperty -Key 'State' -ErrorAction SilentlyContinue)) {
                        $exception = [invalidoperationexception]::new("Invalid rule definition. Inspect the properties of the InvokeInfo object in this error's TargetObject property. This is commonly a result of creating a rule using the ID of an object that does not exist.")
                        $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $exception.Message, [System.Management.Automation.ErrorCategory]::InvalidData, $invokeInfo)
                        throw $errorRecord
                    }
                    $lastPropertyCount = $newPropertyCount
                } catch {
                    throw
                }
            } while ($invokeInfo.ItemType -eq 'InvokeInfo')

            if (($invokeInfo | Get-ConfigurationItemProperty -Key State) -ne 'Success') {
                $exception = [invalidoperationexception]::new("Error in New-VmsRule: $($invokeInfo | Get-ConfigurationItemProperty -Key 'ErrorText' -ErrorAction SilentlyContinue)")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new($_.Exception, $_.Exception.Message, [System.Management.Automation.ErrorCategory]::InvalidData, $invokeInfo)
                throw $errorRecord
            }

            $newRuleId = ($invokeInfo | Get-ConfigurationItemProperty -Key Path) -replace 'Rule\[(.+)\]', '$1'
            $newRule = Get-VmsRule -Id $newRuleId -ErrorAction Stop

            if ($Enabled -ne $newRule.EnableProperty.Enabled) {
                $newRule.EnableProperty.Enabled = $Enabled
                $null = $newRule | Set-ConfigurationItem
            }

            $newRule
        } catch {
            $exception = [invalidoperationexception]::new("An error occurred while creating the rule: $($_.Exception.Message)", $_.Exception)
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, $exception.Message, [System.Management.Automation.ErrorCategory]::InvalidData, $invokeInfo)
            Write-Error -Message $exception.Message -Exception $exception -TargetObject $invokeInfo
        }
    }
}

