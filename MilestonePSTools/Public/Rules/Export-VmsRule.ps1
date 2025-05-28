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

function Export-VmsRule {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline)]
        [RuleNameTransformAttribute()]
        [ValidateVmsItemType('Rule')]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem[]]
        $Rule,

        [Parameter(Position = 0)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
        if ($MyInvocation.BoundParameters.ContainsKey('Path')) {
            $resolvedPath = (Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable rpError).Path
            if ([string]::IsNullOrWhiteSpace($resolvedPath)) {
                $resolvedPath = $rpError.TargetObject
            }
            $Path = $resolvedPath
            $fileInfo = [io.fileinfo]$Path
            if (-not $fileInfo.Directory.Exists) {
                throw ([io.directorynotfoundexception]::new("Directory not found: $($fileInfo.Directory.FullName)"))
            }
            if ($fileInfo.Extension -ne '.json') {
                Write-Verbose "A .json file extension will be added to the file '$($fileInfo.Name)'"
                $Path += ".json"
            }
            if ((Test-Path -Path $Path) -and -not $Force) {
                throw ([System.IO.IOException]::new("The file '$Path' already exists. Include the -Force switch to overwrite an existing file."))
            }
        } elseif (-not $MyInvocation.BoundParameters.ContainsKey('PassThru') -or -not $PassThru.ToBool()) {
            throw "Either or both of Path, or PassThru parameters must be specified."
        }
        $rules = @{}
    }

    process {
        if ($Rule.Count -eq 0) {
            $Rule = Get-VmsRule
        }
        foreach ($currentRule in $Rule) {
            $obj = [pscustomobject]@{
                DisplayName = $currentRule.DisplayName
                Enabled     = $currentRule.EnableProperty.Enabled
                Id          = [guid]$currentRule.Path.Substring(5, 36)
                Properties  = [pscustomobject[]]@($currentRule.Properties | Foreach-Object {
                        $prop = $_
                        [pscustomobject]@{
                            DisplayName    = $prop.DisplayName
                            Key            = $prop.Key
                            Value          = $prop.Value
                            ValueType      = $prop.ValueType
                            ValueTypeInfos = [pscustomobject[]]@($prop.ValueTypeInfos | Select-Object @{Name = 'Key'; Expression = { $prop.Key } }, Name, Value)
                            IsSettable     = $prop.IsSettable
                        }
                    })
            }

            $duplicateCount = 0
            $baseName = $obj.DisplayName -replace ' DUPLICATE \d+$', ''
            while ($rules.ContainsKey($obj.DisplayName)) {
                $duplicateCount++
                $obj.DisplayName = $baseName + " DUPLICATE $duplicateCount"
                $obj.Properties | Where-Object Key -eq 'Name' | ForEach-Object { $_.Value = $obj.DisplayName }
            }
            $rules[$obj.DisplayName] = $obj
            if ($duplicateCount) {
                Write-Warning "There are multiple rules named '$baseName'. Duplicates will be renamed."
            }

            if ($PassThru) {
                $obj
            }
        }
    }

    end {
        if ($rules.Count -and $Path) {
            Write-Verbose "Saving $($rules.Count) exported rules in JSON format to $Path"
            [io.file]::WriteAllText($Path, (ConvertTo-Json -InputObject $rules.Values -Depth 10 -Compress), [system.text.encoding]::UTF8)
        }
    }
}

