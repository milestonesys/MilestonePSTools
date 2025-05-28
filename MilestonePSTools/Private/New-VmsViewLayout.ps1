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

function New-VmsViewLayout {
    [CmdletBinding(DefaultParameterSetName = 'Simple')]
    [OutputType([string])]
    param (
        [Parameter(ParameterSetName = 'Simple')]
        [ValidateRange(0, 100)]
        [int]
        $ViewItemCount = 1,

        [Parameter(ParameterSetName = 'Custom')]
        [ValidateRange(1, 100)]
        [int]
        $Columns,

        [Parameter(ParameterSetName = 'Custom')]
        [ValidateRange(1, 100)]
        [int]
        $Rows
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Simple' {
                $size = 1
                if ($ViewItemCount -gt 0) {
                    $sqrt = [math]::Sqrt($ViewItemCount)
                    $size = [math]::Floor($sqrt)
                    if ($sqrt % 1) {
                        $size++
                    }
                }
                $Columns = $Rows = $size
                $width = $height = [math]::Floor(1000 / $size)
            }

            'Custom' {
                $width = [math]::Floor(1000 / $Columns)
                $height = [math]::Floor(1000 / $Rows)
            }
        }

        $template = '<ViewItem><Position><X>{0}</X><Y>{1}</Y></Position><Size><Width>{2}</Width><Height>{3}</Height></Size></ViewItem>'
        $xmlBuilder = [text.stringbuilder]::new()
        $null = $xmlBuilder.Append("<ViewItems>")
        for ($posY = 0; $posY -lt $Rows; $posY++) {
            for ($posX = 0; $posX -lt $Columns; $posX++) {
                $x = $width  * $posX
                $y = $height * $posY
                $null = $xmlBuilder.Append(($template -f $x, $y, $width, $height))
            }
        }
        $null = $xmlBuilder.Append("</ViewItems>")
        Write-Output $xmlBuilder.ToString()
    }
}

