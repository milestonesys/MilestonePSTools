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

function Get-ProcessOutput
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,
        [Parameter()]
        [string[]]
        $ArgumentList
    )
    
    process {
        try {
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.RedirectStandardOutput = $true
            $process.StartInfo.RedirectStandardError = $true
            $process.StartInfo.FileName = $FilePath
            $process.StartInfo.CreateNoWindow = $true

            if($ArgumentList) { $process.StartInfo.Arguments = $ArgumentList }
            Write-Verbose "Executing $($FilePath) with the following arguments: $([string]::Join(' ', $ArgumentList))"
            $null = $process.Start()
    
            [pscustomobject]@{
                StandardOutput = $process.StandardOutput.ReadToEnd()
                StandardError = $process.StandardError.ReadToEnd()
                ExitCode = $process.ExitCode
            }
        }
        finally {
            $process.Dispose()
        }
        
    }
}
