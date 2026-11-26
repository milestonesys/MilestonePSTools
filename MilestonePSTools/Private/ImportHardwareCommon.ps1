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

function New-ImportHardwareCredentialList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [AllowNull()]
        [object]
        $Credential,

        [Parameter()]
        [string]
        $UserName,

        [Parameter()]
        [string]
        $Password
    )

    process {
        $credentialList = [collections.generic.list[pscredential]]::new()
        if (-not [string]::IsNullOrWhiteSpace($UserName) -and -not [string]::IsNullOrWhiteSpace($Password)) {
            $credentialList.Add([pscredential]::new($UserName, ($Password | ConvertTo-SecureString -AsPlainText -Force)))
        }

        if ($null -eq $Credential) {
            return $credentialList
        }

        if ($Credential -is [pscredential]) {
            $credentialList.Add($Credential)
            return $credentialList
        }

        foreach ($item in $Credential) {
            if ($item -is [pscredential] -and $null -ne $item) {
                $credentialList.Add($item)
            }
        }

        return $credentialList
    }
}

function Set-ImportHardwareScanCredentialParameters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]
        $ScanParameters,

        [Parameter()]
        [AllowNull()]
        [object]
        $Credential
    )

    process {
        $scanCredentials = New-ImportHardwareCredentialList -Credential $Credential
        if ($scanCredentials.Count -gt 0) {
            $ScanParameters.Credential = $scanCredentials
            if ($ScanParameters.ContainsKey('UseDefaultCredentials')) {
                $ScanParameters.Remove('UseDefaultCredentials')
            }
        } else {
            $ScanParameters.UseDefaultCredentials = $true
            if ($ScanParameters.ContainsKey('Credential')) {
                $ScanParameters.Remove('Credential')
            }
        }

        return $ScanParameters
    }
}

function Invoke-ImportHardwareCredentialAttempts {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter()]
        [AllowNull()]
        [object]
        $Credential,

        [Parameter(Mandatory)]
        [scriptblock]
        $AttemptScript,

        [Parameter()]
        [scriptblock]
        $OnAttemptFailure,

        [Parameter()]
        [switch]
        $RethrowOnException
    )

    process {
        $credentials = New-ImportHardwareCredentialList -Credential $Credential
        for ($credIndex = 0; $credIndex -lt $credentials.Count; $credIndex++) {
            $cred = $credentials[$credIndex]
            $isLastAttempt = $credIndex -ge $credentials.Count - 1
            $attemptResult = $null
            $errorRecord = $null

            try {
                $attemptResult = & $AttemptScript $cred $credIndex $isLastAttempt
            } catch {
                if ($RethrowOnException) {
                    throw
                }
                $errorRecord = $_
            }

            $success = $null -ne $attemptResult
            $value = $attemptResult
            if ($attemptResult -is [hashtable]) {
                if ($attemptResult.ContainsKey('Success')) {
                    $success = [bool]$attemptResult.Success
                }
                if ($attemptResult.ContainsKey('Value')) {
                    $value = $attemptResult.Value
                }
                if ($null -eq $errorRecord -and $attemptResult.ContainsKey('ErrorRecord')) {
                    $errorRecord = $attemptResult.ErrorRecord
                }
            } elseif ($attemptResult -is [pscustomobject]) {
                if ($attemptResult.PSObject.Properties.Name -contains 'Success') {
                    $success = [bool]$attemptResult.Success
                }
                if ($attemptResult.PSObject.Properties.Name -contains 'Value') {
                    $value = $attemptResult.Value
                }
                if ($null -eq $errorRecord -and $attemptResult.PSObject.Properties.Name -contains 'ErrorRecord') {
                    $errorRecord = $attemptResult.ErrorRecord
                }
            }

            if ($success) {
                return $value
            }

            if ($OnAttemptFailure) {
                & $OnAttemptFailure ([pscustomobject]@{
                        Credential   = $cred
                        AttemptIndex = $credIndex
                        IsLastAttempt = $isLastAttempt
                        AttemptResult = $attemptResult
                        ErrorRecord  = $errorRecord
                    })
            } elseif ($null -ne $errorRecord) {
                Write-Error -ErrorRecord $errorRecord
            }
        }

        return $null
    }
}
