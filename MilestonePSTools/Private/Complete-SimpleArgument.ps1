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

function Complete-SimpleArgument {
    <#
    .SYNOPSIS
    Implements a simple argument-completer.
    .DESCRIPTION
    This cmdlet is a helper function that implements a basic argument completer
    which matches the $wordToComplete against a set of values that can be
    supplied in the form of a string array, or produced by a scriptblock you
    provide to the function.
    .PARAMETER Arguments
    The original $args array passed from Register-ArgumentCompleter into the
    scriptblock.
    .PARAMETER ValueSet
    An array of strings representing the valid values for completion.
    .PARAMETER Completer
    A scriptblock which produces an array of strings representing the valid values for completion.
    .EXAMPLE
    Register-ArgumentCompleter -CommandName Get-VmsRole -ParameterName Name -ScriptBlock {
        Complete-SimpleArgument $args {(Get-VmsManagementServer).RoleFolder.Roles.Name}
    }
    Registers an argument completer for the Name parameter on the Get-VmsRole
    command. Complete-SimpleArgument cmdlet receives the $args array, and a
    simple scriptblock which returns the names of all roles in the VMS.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object[]]
        $Arguments,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ValuesFromArray')]
        [string[]]
        $ValueSet,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ValuesFromScriptBlock')]
        [scriptblock]
        $Completer
    )

    process {
        # Get ValueSet from scriptblock if provided, otherwise use $ValueSet.
        if ($PSCmdlet.ParameterSetName -eq 'ValuesFromScriptBlock') {
            $ValueSet = $Completer.Invoke($Arguments)
        }

        # Trim single/double quotes off of beginning of word if present. If no
        # characters have been provided, set the word to "*" for wildcard matching.
        if ([string]::IsNullOrWhiteSpace($Arguments[2])) {
            $wordToComplete = '*'
        } else {
            $wordToComplete = $Arguments[2].Trim('''').Trim('"')
        }

        # Return matching values from ValueSet.
        $ValueSet | Foreach-Object {
            if ($_ -like "$wordToComplete*") {
                if ($_ -like '* *') {
                    "'$_'"
                } else {
                    $_
                }
            }
        }
    }
}

