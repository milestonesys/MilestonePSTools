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

function Resize-Image {
    [CmdletBinding()]
    [OutputType([System.Drawing.Image])]
    [RequiresVmsConnection($false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Drawing.Image]
        $Image,

        [Parameter(Mandatory)]
        [int]
        $Height,

        [Parameter()]
        [long]
        $Quality = 95,

        [Parameter()]
        [ValidateSet('BMP', 'JPEG', 'GIF', 'TIFF', 'PNG')]
        [string]
        $OutputFormat,

        [Parameter()]
        [switch]
        $DisposeSource
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($null -eq $Image -or $Image.Width -le 0 -or $Image.Height -le 0) {
            Write-Error 'Cannot resize an invalid image object.'
            return
        }

        [int]$width = $image.Width / $image.Height * $Height
        $bmp = [system.drawing.bitmap]::new($width, $Height)
        $graphics = [system.drawing.graphics]::FromImage($bmp)
        $graphics.InterpolationMode = [system.drawing.drawing2d.interpolationmode]::HighQualityBicubic
        $graphics.DrawImage($Image, 0, 0, $width, $Height)
        $graphics.Dispose()

        try {
            $formatId = if ([string]::IsNullOrWhiteSpace($OutputFormat)) {
                    $Image.RawFormat.Guid
                }
                else {
                    ([system.drawing.imaging.imagecodecinfo]::GetImageEncoders() | Where-Object FormatDescription -eq $OutputFormat).FormatID
                }
            $encoder = [system.drawing.imaging.imagecodecinfo]::GetImageEncoders() | Where-Object FormatID -eq $formatId
            $encoderParameters = [system.drawing.imaging.encoderparameters]::new(1)
            $qualityParameter = [system.drawing.imaging.encoderparameter]::new([system.drawing.imaging.encoder]::Quality, $Quality)
            $encoderParameters.Param[0] = $qualityParameter
            Write-Verbose "Saving resized image as $($encoder.FormatDescription) with $Quality% quality"
            $ms = [io.memorystream]::new()
            $bmp.Save($ms, $encoder, $encoderParameters)
            $resizedImage = [system.drawing.image]::FromStream($ms)
            Write-Output ($resizedImage)
        }
        finally {
            $qualityParameter.Dispose()
            $encoderParameters.Dispose()
            $bmp.Dispose()
            if ($DisposeSource) {
                $Image.Dispose()
            }
        }

    }
}

