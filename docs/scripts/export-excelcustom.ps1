function Export-ExcelCustom {
    <#
    .SYNOPSIS
        Exports a collection of data to an Excel document with support for images.
    .DESCRIPTION
        This cmdlet produces a styled Excel spreadsheet where the data may
        contain System.Drawing.Image objects.

        If any images are present, the rows will all be resized to a uniform
        height matching the tallest image available.

        Each column will be resized to match the widest image in that column.
    .EXAMPLE
        Export-ExcelCustom -Path .\report.xlsx -InputObject (Get-VmsCameraReport -IncludeSnapshots) -Show

        Exports the results of Get-VmsCameraReport with images to an Excel document.
    .INPUTS
        [object]
    #>
    [CmdletBinding()]
    param(
        # Specifies a collection of data to export to Excel.
        [Parameter(Mandatory)]
        [object[]]
        $InputObject,

        # Specifies the path to save the Excel document including the file name.
        [Parameter(Mandatory)]
        [string]
        $Path,

        # Specifies an optional title.
        [Parameter()]
        [string]
        $Title,

        # Specifies a [TableStyles] value. Default is 'Medium9' and valid
        # options can be found by checking the TableStyle parameter help info
        # from the Export-Excel cmdlet.
        [Parameter()]
        [string]
        $TableStyle = 'Medium9',

        # Specifies that the resulting Excel document should be displayed, if
        # possible, after the file has been saved.
        [Parameter()]
        [switch]
        $Show
    )

    process {
        $exportParams = @{
            Path       = $Path
            PassThru   = $true
            TableName  = 'CustomReport'
            TableStyle = $TableStyle
            AutoSize   = $true
        }
        if (-not [string]::IsNullOrWhiteSpace($Title)) {
            $exportParams.Title = $Title
        }

        # Find out if any of the rows contain an image, and find the maximum
        # height so we can make the row heights uniform.
        $imageHeight = -1
        $hasImages = $false
        $keys = $InputObject[0].psobject.properties | Select-Object -ExpandProperty Name
        foreach ($obj in $InputObject) {
            foreach ($key in $keys) {
                if ($obj.$key -is [System.Drawing.Image]) {
                    $imageHeight = [math]::Max($imageHeight, $obj.$key.Height)
                    $hasImages = $true
                }
            }
        }

        try {
            $pkg = $InputObject | Export-Excel @exportParams
            if ($hasImages) {
                # The rest of this function is only necessary if there are any images.
                $rowOffset = 2
                if ($exportParams.ContainsKey('Title')) { $rowOffset++ }
                for ($i = 0; $i -lt $InputObject.Count; $i++) {
                    $row = $i + $rowOffset
                    if ($imageHeight -gt 0) {
                        $pkg.Sheet1.Row($row).Height = (3 / 4) * ($imageHeight + 1)
                    }

                    $col = 1
                    foreach ($key in $keys) {
                        # Each column of each row is checked to see if the value
                        # is of type "Image". If so, remove the text from the cell
                        # and add the image using Add-ExcelImage.
                        if ($InputObject[$i].$key -is [System.Drawing.Image]) {
                            $pkg.Sheet1.SetValue($row, $col, '')
                            $imageParams = @{
                                WorkSheet  = $pkg.Sheet1
                                Image      = $InputObject[$i].$key
                                Row        = $row
                                Column     = $col
                                ResizeCell = $true
                            }
                            Add-ExcelImage @imageParams
                        }
                        $col++
                    }
                }
            }
        } finally {
            $pkg | Close-ExcelPackage -Show:$Show
        }
    }
}
