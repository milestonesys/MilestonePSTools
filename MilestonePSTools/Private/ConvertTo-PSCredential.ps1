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

function ConvertTo-PSCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [System.Net.NetworkCredential]
        $NetworkCredential
    )
        
    process {
        if ([string]::IsNullOrWhiteSpace($NetworkCredential.UserName)) {
            Write-Error 'NetworkCredential username is empty. This usually means the credential is the default network credential and this cannot be converted to a pscredential.'
            return
        }
        $sb = [text.stringbuilder]::new()
        if (-not [string]::IsNullOrWhiteSpace($NetworkCredential.Domain)) {
            [void]$sb.Append("$($NetworkCredential.Domain)\")
        }
        [void]$sb.Append($NetworkCredential.UserName)
        [pscredential]::new($sb.ToString(), $NetworkCredential.SecurePassword)
    }
}
