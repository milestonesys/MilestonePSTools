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

class VmsConfigChildItemSettings {
    [string]    $Name
    [hashtable] $Properties
    [hashtable] $ValueTypeInfo
}

function ConvertFrom-ConfigChildItem {
    [CmdletBinding()]
    [OutputType([VmsConfigChildItemSettings])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [VideoOS.Platform.ConfigurationItems.IConfigurationChildItem]
        $InputObject,

        [Parameter()]
        [switch]
        $RawValues
    )

    process {
        # When we look up display values for raw values, sometimes
        # the raw value matches the value of a valuetypeinfo property
        # like MinValue or MaxValue. We don't want to display "MinValue"
        # as the display value for a setting, so this list of valuetypeinfo
        # entry names should be ignored.
        $ignoredNames = 'MinValue', 'MaxValue', 'StepValue'
        $properties = @{}
        $valueTypeInfos = @{}
        foreach ($key in $InputObject.Properties.Keys) {
            # Sometimes the Keys are the same as KeyFullName and other times
            # they are short, easy to read names. So just in case, we'll test
            # the key by splitting it and seeing how many parts there are. A
            # KeysFullName value looks like 'device:0.0/RecorderMode/75f374ab-8dd2-4fd0-b8f5-155fa730702c'
            $keyParts = $key -split '/', 3
            $keyName = if ($keyParts.Count -gt 1) { $keyParts[1] } else { $key }

            $value = $InputObject.Properties.GetValue($key)
            $valueTypeInfo = $InputObject.Properties.GetValueTypeInfoCollection($key)

            if (-not $RawValues) {
                <#
                  Unless -RawValues was used, we'll check to see if there's a
                  display name available for the value for the current setting.
                  If a ValueTypeInfo entry has a Value matching the raw value,
                  and the Name of that value isn't one of the internal names we
                  want to ignore, we'll replace $value with the ValueTypeInfo
                  Name. Here's a reference ValueTypeInfo table for RecorderMode:

                  TranslationId                        Name       Value
                  -------------                        ----       -----
                  b9f5c797-ebbf-55ad-ccdd-8539a65a0241 Disabled   0
                  535863a8-2f16-3709-557e-59e2eb8139a7 Continuous 1
                  8226588f-03da-49b8-57e5-ddf8c508dd2d Motion     2

                  So if the raw value of RecorderMode is 0, we would return
                  "Disabled" unless the -RawValues switch is used.
                #>

                $friendlyValue = ($valueTypeInfo | Select-Object | Where-Object {
                        $_.Value -eq $value -and $_.Name -notin $ignoredNames
                    }).Name
                if (-not [string]::IsNullOrWhiteSpace($friendlyValue)) {
                    $value = $friendlyValue
                }
            }

            $properties[$keyName] = $value
            $valueTypeInfos[$keyName] = $valueTypeInfo
        }

        [VmsConfigChildItemSettings]@{
            Name          = $InputObject.DisplayName
            Properties    = $properties
            ValueTypeInfo = $valueTypeInfos
        }
    }
}

