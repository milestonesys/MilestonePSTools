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

function Export-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion(21.1)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[ViewGroup]])]
        [MipItemTransformation([ViewGroup])]
        [ViewGroup]
        $ViewGroup,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        [environment]::CurrentDirectory = Get-Location
        $Path = [io.path]::GetFullPath($Path)
        $fileInfo = [io.fileinfo]::new($Path)

        if (-not $fileInfo.Directory.Exists) {
            if ($Force) {
                $null = New-Item -Path $fileInfo.Directory.FullName -ItemType Directory -Force
            } else {
                throw [io.DirectoryNotfoundexception]::new("Directory does not exist: $($fileInfo.Directory.FullName). Create the directory manually, or use the -Force switch.")
            }
        }

        if ($fileInfo.Exists -and -not $Force) {
            throw [invalidoperationexception]::new("File already exists. Use -Force to overwrite the existing file.")
        }
        $item = $ViewGroup | Get-ConfigurationItem -Recurse
        $json = $item | ConvertTo-Json -Depth 100 -Compress
        [io.file]::WriteAllText($Path, $json)
    }
}

