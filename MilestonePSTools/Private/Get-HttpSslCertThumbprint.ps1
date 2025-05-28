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

function Get-HttpSslCertThumbprint {
    <#
    .SYNOPSIS
        Gets the certificate thumbprint from the sslcert binding information put by netsh http show sslcert ipport=$IPPort
    .DESCRIPTION
        Gets the certificate thumbprint from the sslcert binding information put by netsh http show sslcert ipport=$IPPort.
        Returns $null if no binding is present for the given ip:port value.
    .PARAMETER IPPort
        The ip:port string representing the binding to retrieve the thumbprint from.
    .EXAMPLE
        Get-HttpSslCertThumbprint 0.0.0.0:8082
        Gets the sslcert thumbprint for the binding found matching 0.0.0.0:8082 which is the default HTTPS IP and Port for
        XProtect Mobile Server. The value '0.0.0.0' represents 'all interfaces' and 8082 is the default https port.
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]
        $IPPort
    )
    process {
        $netshOutput = [string](netsh.exe http show sslcert ipport=$IPPort)

        if (!$netshOutput.Contains('Certificate Hash')) {
            Write-Error "No SSL certificate binding found for $ipPort"
            return
        }

        if ($netshOutput -match "Certificate Hash\s+:\s+(\w+)\s+") {
            $Matches[1]
        } else {
            Write-Error "Certificate Hash not found for $ipPort"
        }
    }
}
