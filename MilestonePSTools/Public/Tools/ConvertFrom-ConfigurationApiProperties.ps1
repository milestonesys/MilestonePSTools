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

function ConvertFrom-ConfigurationApiProperties {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Command has already been published.')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ConfigurationApiProperties]
        $Properties,

        [Parameter()]
        [switch]
        $UseDisplayNames
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $languageId = (Get-Culture).Name
        $result = @{}
        foreach ($key in $Properties.Keys) {
            if ($key -notmatch '^.+/(?<Key>.+)/(?:[0-9A-F\-]{36})$') {
                Write-Warning "Failed to parse property with key name '$key'"
                continue
            }
            $propertyInfo = $Properties.GetValueTypeInfoCollection($key)
            $propertyValue = $Properties.GetValue($key)

            if ($UseDisplayNames) {
                $valueTypeInfo = $propertyInfo | Where-Object Value -eq $propertyValue
                $displayName = $valueTypeInfo.Name
                if ($propertyInfo.Count -gt 0 -and $displayName -and $displayName -notin @('true', 'false', 'MinValue', 'MaxValue', 'StepValue')) {
                    if ($valueTypeInfo.TranslationId -and $languageId -and $languageId -ne 'en-US') {
                        $translatedName = (Get-Translations -LanguageId $languageId).($valueTypeInfo.TranslationId)
                        if (![string]::IsNullOrWhiteSpace($translatedName)) {
                            $displayName = $translatedName
                        }
                    }
                    $result[$Matches.Key] = $displayName
                }
                else {
                    $result[$Matches.Key] = $propertyValue
                }
            }
            else {
                $result[$Matches.Key] = $propertyValue
            }
        }

        Write-Output $result
    }
}

