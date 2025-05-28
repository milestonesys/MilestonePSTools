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

function HandleValidateResultException {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [Parameter()]
        [object]
        $TargetObject,

        [Parameter()]
        [string]
        $ItemName = 'Not set'
    )

    process {
        # This function makes it easier to understand the reason for the validation error, but it hides the original
        # ScriptStackTrace so the error looks like it originates in the original "catch" block instead of the line
        # inside the "try" block triggering the exception. Writing the original stacktrace out to the debug stream
        # is a compromise for being unable to throw the original exception and stacktrace with a better exception
        # message.
        Write-Debug -Message "Original ScriptStackTrace:`n$($ErrorRecord.ScriptStackTrace)"

        $lastCommand = (Get-PSCallStack)[1]
        $origin = $lastCommand.Command
        $exception = $ErrorRecord.Exception
        $validateResult = $exception.ValidateResult
        if (-not $MyInvocation.BoundParameters.ContainsKey('ItemName') -and -not [string]::IsNullOrWhiteSpace($validateResult.ResultItem.DisplayName)) {
            $ItemName = $validateResult.ResultItem.DisplayName
        }
        foreach ($errorResult in $validateResult.ErrorResults) {
            $errorParams = @{
                Message           = '{0}: Invalid value for property "{1}" on {2}. ErrorText = "{3}". Origin = {4}' -f $errorResult.ErrorTextId, $errorResult.ErrorProperty, $ItemName, $errorResult.ErrorText, $origin
                Exception         = $Exception
                Category          = 'InvalidData'
                RecommendedAction = 'Review the invalid property value and try again.'
            }
            if ($TargetObject) {
                $errorParams.TargetObject = $TargetObject
            }
            Write-Error @errorParams
        }
    }
}

