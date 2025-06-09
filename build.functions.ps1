using namespace System.Text
using namespace System.Text.RegularExpressions

function Get-VmsCommandRequirements {
    [CmdletBinding()]
    param()

    process {
        $requirements = [ordered]@{}
        Get-Command -Module MilestonePSTools -CommandType ([system.management.automation.CommandTypes]::Cmdlet -bor [system.management.automation.CommandTypes]::Function) | Sort-Object Name | ForEach-Object {
            $command = $_
            $commandReqs = switch ($command.CommandType) {
                'Function' {
                    $command.ScriptBlock.Attributes | Where-Object { $_ -is [MilestonePSTools.IVmsRequirementValidator] }
                }
                'Cmdlet' {
                    $command.ImplementingType.GetCustomAttributes($true) | Where-Object { $_ -is [MilestonePSTools.IVmsRequirementValidator] }
                }
            }

            $parameterProps = @(
                'Name',
                @{
                    Name       = 'Requirements'
                    Expression = {
                        $_.Attributes | Where-Object {
                            $_ -is [MilestonePSTools.IDescriptive]
                        }
                    }
                }
            )
            $parameterReqs = $command.Parameters.Values | Sort-Object Name | Select-Object $parameterProps
            
            $requirements[$command.Name] = [pscustomobject]@{
                CommandRequirements   = $commandReqs
                ParameterRequirements = $parameterReqs
            }
        }
        $requirements
    }
}
function Update-VmsDocs {
    [CmdletBinding()]
    param()

    process {
        $requirements = Get-VmsCommandRequirements
        foreach ($commandName in $requirements.Keys) {
            $commandRequirements = [system.collections.generic.list[MilestonePSTools.IVmsRequirementValidator]]::new()
            $requirements[$CommandName].CommandRequirements | ForEach-Object { $commandRequirements.Add($_) }
            
            $parameterRequirements = [system.collections.generic.list[pscustomobject]]::new()
            $requirements[$CommandName].ParameterRequirements | Where-Object { $_.Requirements.Count -gt 0 } | ForEach-Object {
                $parameterRequirements.Add($_)
            }
            
            foreach ($locale in Get-ChildItem -Path "$PSScriptRoot\docs\commands" -Directory) {
                $path = [io.path]::Combine($locale.FullName, "$commandName.md")
                if (-not (Test-Path -Path $path)) {
                    if ($locale.Name -eq 'en-US') {
                        throw "Markdown file for command '$commandName' not found at $path"
                    } else {
                        Write-Verbose "There is no $($locale.Name) translation for '$commandName'."
                        continue
                    }
                }
        
                $lines = Get-Content -Path $path -Encoding UTF8
                $sb = [text.stringbuilder]::new()
                $num = 0

                # Accept all lines until the description heading
                do {
                    $null = $sb.AppendLine($lines[$num])
                } while ($lines[$num++] -notmatch '^## DESCRIPTION')
        
                # Accept all lines of description until either the previous
                # REQUIREMENTS section is located, or the ## Examples heading is reached.
                $skipToEndOfSection = $false
                while ($lines[$num] -notmatch '^## EXAMPLES') {
                    if ($lines[$num] -match '^REQUIREMENTS') {
                        # If the previous requirements section is located, discard all lines until we get to the examples heading.
                        $skipToEndOfSection = $true
                    }
                    if (-not $skipToEndOfSection) {
                        $null = $sb.AppendLine($lines[$num])
                    }
                    $num += 1
                }
        
                # Add or replace the command requirements under description heading
                $null = $sb.AppendLine('REQUIREMENTS  ')
                $null = $sb.AppendLine('')
                if ($commandRequirements.Count -eq 0) {
                    $null = $sb.AppendLine('- None specified')    
                } else {
                    foreach ($requirement in $commandRequirements) {
                        $null = $sb.AppendLine("- $($requirement.Description)")
                    }
                }
                $null = $sb.AppendLine('')
        
                # Accept all lines until we reach the "## PARAMETERS" heading
                do {
                    $null = $sb.AppendLine($lines[$num])
                } while ($lines[$num++] -notmatch '^## PARAMETERS')

                # While the line isn't a new H2 heading, we're still processing parameters
                do {
                    $null = $sb.AppendLine($lines[$num])
                    
                    if ($lines[$num] -match '^### -(?<name>[^\s]+)') {
                        $parameterName = $Matches['name']
                        $attributes = ($parameterRequirements | Where-Object Name -EQ $parameterName).Requirements
                        $skipLines = $false
                        while ($lines[++$num] -notmatch '^```yaml') {
                            if ($lines[$num] -cmatch '^REQUIREMENTS\s*$') {
                                $skipLines = $true
                            }
                            if ($skipLines) {
                                continue
                            }
                            $null = $sb.AppendLine($lines[$num])
                        }

                        if ($attributes) {
                            # Add or replace the command requirements under description heading
                            $null = $sb.AppendLine('REQUIREMENTS  ')
                            $null = $sb.AppendLine('')
                            foreach ($attribute in $attributes) {
                                $null = $sb.AppendLine("- $($attribute.Description)")
                            }
                            $null = $sb.AppendLine('')
                        }
                            
                        do {
                            # Keep the rest of the lines which include the parameter's yaml codeblock.
                            $null = $sb.AppendLine($lines[$num++])
                        } while ($lines[$num + 1] -notmatch '^#+')
                        $null = $sb.AppendLine()
                    }
                } while ($lines[$num++] -notmatch '^## \w+')

                while ($num -lt $lines.Count) {
                    $null = $sb.AppendLine($lines[$num++])
                }
        
                Write-Verbose "Saving changes to $path"
                [io.file]::WriteAllText($path, $sb.ToString())
            }
        }
    }
}

class CommandHistory {
    [string]             $Module
    [string]             $Name
    [string]             $VersionAdded
    [nullable[datetime]] $DatePublished
    [string]             $VersionRemoved
    [nullable[datetime]] $DateRemoved
    [string[]]           $Aliases = @()
    [string]             $AliasedTo
}

class CommandHistoryReport {
    [datetime]         $Date
    [CommandHistory[]] $Commands
}

function Get-CommandHistory {
    [CmdletBinding()]
    [OutputType([CommandHistory])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [System.Management.Automation.PSModuleInfo]
        $ModuleInfo
    )

    process {
        $allVersions = Find-Module -Name $ModuleInfo.Name -AllVersions | Sort-Object { $_.Version -as [version] }
        $commands = @{}
        foreach ($module in $allVersions) {
            # Check whether a command from a previous version is no longer present.
            foreach ($commandName in $commands.Keys) {
                if ($commandName -notin $module.Includes.Command -and $null -eq $commands[$commandName].VersionRemoved) {
                    $commands[$commandName].DateRemoved = $module.PublishedDate
                    $commands[$commandName].VersionRemoved = $module.Version
                    if (($aliasedTo = $ModuleInfo.ExportedAliases[$commandName].ResolvedCommand.Name)) {
                        $commands[$commandName].AliasedTo = $aliasedTo
                    }
                }
            }
            foreach ($command in $module.Includes.Command) {
                if ($commands.ContainsKey($command)) {
                    if ($commands[$command].VersionRemoved) {
                        Write-Verbose "$command was removed in $($commands[$command].VersionRemoved) and re-appeared in $($module.Version)"
                        $commands[$command].VersionRemoved = $null
                        $commands[$command].DateRemoved = [datetime]::MinValue
                        $commands[$command].AliasedTo = $null
                    }
                } else {
                    $commands[$command] = [CommandHistory]@{
                        Module        = $ModuleInfo.Name
                        Name          = $command
                        VersionAdded  = $module.Version
                        DatePublished = $module.PublishedDate
                    }
                }
            }
        }

        foreach ($alias in $ModuleInfo.ExportedAliases.Keys) {
            $aliasInfo = $ModuleInfo.ExportedAliases[$alias]
            if ($commands[$aliasInfo.ResolvedCommand.Name]) {
                $commands[$aliasInfo.ResolvedCommand.Name].Aliases += $alias
            }
        }
        [CommandHistoryReport]@{
            Date     = (Get-Date).ToUniversalTime()
            Commands = $commands.Values
        }
    }
}

function ConvertTo-MarkdownTable {
    <#
    .SYNOPSIS
    Converts a collection of objects into a markdown-formatted table.

    .DESCRIPTION
    The `ConvertTo-MarkdownTable` function converts a collection of objects into a markdown-formatted table. The names
    of all properties on the first object are used as column names in the order they are defined. If subsequent objects
    define properties that were not present on the first item processed, those additional properties will be ignored
    and columns will not be created for them.

    Optionally, a maximum width can be specified for one, or all columns using MaxColumnWidth. However, if the length
    of the name column header is greater than the specified MaxColumnWidth, the MaxColumnWidth value used for that
    column will be the length of the column header. Rows with column values longer than MaxColumnWidth will be truncated
    and the Ellipsis string will be appended to the end with the length of the resulting string, plus ellipsis characters,
    equaling the MaxColumnWidth value for that column.

    By default, all columns will be padded with a space between any column header or value and the "|" characters on
    either side. Values shorter than the longest value in the column will be right-padded so that all "|" characters
    align vertically throughout the table.

    If the additional white space is not desired, use of the `Compress` switch will omit any unnecessary white space.

    .PARAMETER InputObject
    Specified the object, or a collection of objects to represent in the resulting markdown data table. All properties
    of InputObject will be used to define the resulting columns. Consider using `Select-Object` first to select which
    properties on the source object should be passed to this function.

    .PARAMETER MaxColumnWidth
    Specifies the maximum length of all columns if one value is provided, or the maximum length of each individual column
    if more than one value is provided. When providing more than one value, you must provide a value for every column. Columns
    with values longer than MaxColumnWidth will be truncated, and the Ellipsis characters will be appended. The length
    of the resulting string with ellipsis will match the MaxColumnWidth value.

    The default value is `[int]::MaxValue` so effectively no columns will be truncated. And the minimum value is the length
    of Ellipsis + 1, or 4 by default.

    .PARAMETER Ellipsis
    Specifies the characters to use as an ellipsis. By default, the ellipsis value is "...", but this can be overridden
    to be an empty string, or some other value. The minimum value for MaxColumnWidth is defined as 1 + the length of Ellipsis.

    .PARAMETER Compress
    Specifies that no extra padding should be added to make the "|" symbols align vertically.

    .EXAMPLE
    Get-Process | Select-Object Name, Id, VirtualMemorySize | ConvertTo-MarkdownTable -MaxColumnWidth 16

    Gets a list of processes, selects the Name, Id, and VirtualMemorySize properties, and returns a markdown-formatted
    table representing all properties with a maximum column width of 16 characters.

    .EXAMPLE
    Get-Service | Select-Object DisplayName, Name, Status | ConvertTo-MarkdownTable

    Generates a markdown-formatted table with the DisplayName, Name, and Status properties of all services.

    .EXAMPLE
    Get-Service | Select-Object DisplayName, Name, Status | ConvertTo-MarkdownTable -Compress

    Generates a markdown-formatted table with the DisplayName, Name, and Status properties of all services, without any
    unnecessary padding, resulting in a much shorter string for large sets of data.
    #>#
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [psobject[]]
        $InputObject,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]
        $MaxColumnWidth = ([int]::MaxValue),

        [Parameter()]
        [string]
        $Ellipsis = '...',

        [Parameter()]
        [switch]
        $Compress
    )

    begin {
        $MaxColumnWidth | ForEach-Object {
            if ($_ -le $Ellipsis.Length) {
                throw "MaxColumnWidth values must be greater than $($Ellipsis.Length) which is the length of the Ellipsis parameter. $_"
            }
        }
        $items = [system.collections.generic.list[object]]::new()
        $columns = [ordered]@{}
        $firstRecordProcessed = $false
    }

    process {
        foreach ($item in $InputObject) {
            $items.Add($item)
            $columnNumber = 0
            foreach ($property in $item.PSObject.Properties) {
                if ($MaxColumnWidth.Count -gt 1 -and $MaxColumnWidth.Count -lt ($columnNumber + 1)) {
                    throw "No MaxColumnWidth value defined for column $($columnNumber + 1). MaxColumnWidth must define a single value for all columns, or one value for each column."
                }

                $maxLength = $MaxColumnWidth[0]
                if ($MaxColumnWidth.Count -gt 1) {
                    $maxLength = $MaxColumnWidth[$columnNumber]
                }

                if (-not $columns.Contains($property.Name)) {
                    if ($firstRecordProcessed) {
                        Write-Warning "Ignoring property '$($property.Name)' on $item because the property was not present in the first item processed."
                        continue
                    } else {
                        $columns[$property.Name] = $property.Name.Length
                        if ($property.Name.Length -gt $maxLength) {
                            $maxLength = $property.Name.Length
                            Write-Warning "The header for column $columnNumber, '$($property.Name)', is longer than the MaxColumnWidth value provided. The MaxColumnWidth value for this column is now $maxLength."
                        }
                    }
                }

                $length = 0
                if ($null -ne $property.Value) {
                    $length = [math]::Min($maxLength, $property.Value.ToString().Length)
                }

                if ($columns[$property.Name] -lt $length) {
                    $columns[$property.Name] = $length
                }
                $columnNumber++
            }
            $firstRecordProcessed = $true
        }
    }

    end {
        function Shorten {
            param(
                [Parameter(ValueFromPipeline)]
                [string]
                $InputObject,

                [Parameter(Mandatory)]
                [ValidateRange(1, [int]::MaxValue)]
                [int]
                $MaxLength,

                [Parameter()]
                [string]
                $Ellipsis = '...'
            )

            process {
                if ($InputObject.Length -gt $MaxLength) {
                    '{0}{1}' -f $InputObject.Substring(0, ($MaxLength - $Ellipsis.Length)), $Ellipsis
                } else {
                    $InputObject
                }
            }
        }

        $sb = [text.stringbuilder]::new()

        # Header
        $paddedColumnNames = $columns.GetEnumerator() | ForEach-Object {
            $text = $_.Key | Shorten -MaxLength $_.Value -Ellipsis $Ellipsis
            if ($Compress) {
                ' {0} ' -f $text
            } else {
                ' {0} ' -f ($text.PadRight($_.Value))
            }
        }
        $null = $sb.AppendLine('|' + ($paddedColumnNames -join '|') + '|')
        $null = $sb.AppendLine('|' + (($paddedColumnNames | ForEach-Object { '-' * $_.Length } ) -join '|') + '|')

        foreach ($item in $items) {
            $paddedRowValues = $columns.GetEnumerator() | ForEach-Object {
                $text = [string]::Empty
                if ($null -ne $item.($_.Key)) {
                    $text = $item.($_.Key) | Shorten -MaxLength $_.Value -Ellipsis $Ellipsis
                }
                if ($Compress) {
                    ' {0} ' -f $text
                } else {
                    ' {0} ' -f $text.PadRight($_.Value)
                }
            }

            $null = $sb.AppendLine('|' + ($paddedRowValues -join '|') + '|')
        }
        $sb.ToString()
    }
}

function Export-CommandHistory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $ModuleName,

        [Parameter(Mandatory)]
        [string]
        $Path
    )

    process {
        $props = @(
            @{
                Name       = 'Command'
                Expression = {
                    '[{0}]({0}.md)' -f $_.Name
                }
            },

            @{
                Name       = 'From version'
                Expression = {
                    $version = $_.VersionAdded
                    '[{0}]({1}){{:target="_blank"}}' -f $version, "https://www.powershellgallery.com/packages/$ModuleName/$version"
                }
            },

            @{
                Name       = 'Date Published'
                Expression = {
                    $_.DatePublished.ToString('yyyy-MM-dd')
                }
            }
        )
        Get-CommandHistory -ModuleName $ModuleName | Select-Object $props | ConvertTo-MarkdownTable | Set-Content -Path $Path
    }
}

function Get-OutputModuleManifestPath {
    [CmdletBinding()]
    param ()

    process {
        try {
            $ErrorActionPreference = 'Stop'
            $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
            $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
            $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
            $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
            Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"
        } catch {
            throw
        }
    }
}

function Test-DocsRebuildRequired {
    <#
    .SYNOPSIS
    Tests whether files potentially affecting the content of generated help files have been changed since the last commit.
    
    .DESCRIPTION
    This function tests whether any files under MilestonePSTools/Public or src/ are new, removed, or have uncommitted
    changes. If no changes affecting the generated help files have been made, we can save build time by skipping the long
    process of running platyps to generate/update markdown files and convert those files into MAML.

    Add or remove files or folders to the $sourcePaths variable with relative paths if needed.

    .NOTES
    This test is intentionally case-insensitive since the updates made to the documentation can only be made from the
    case-insensitive Windows OS and PowerShell 5.1.
    #>
    [CmdletBinding()]
    param()
    
    process {
        $sourcePaths = 'MilestonePSTools/Public', 'src/' | ForEach-Object {
            (Resolve-Path -Path $_).Path
        }
        $rebuildRequired = $false
        $changes = [collections.generic.list[string]]::new()
        $gitDiff = git diff --name-only
        if ($LASTEXITCODE) {
            throw "Error executing git diff --name-only: $gitDiff"
        }
        $gitDiff | ForEach-Object {
            $changes.Add($_)
        }
        $gitStatus = git status -s
        if ($LASTEXITCODE) {
            throw "Error executing git status -s: $gitStatus"
        }
        $gitStatus | ForEach-Object {
            $change = $_ -split ' ', 2 | Select-Object -Last 1
            $changes.Add($change)
        }
        foreach ($file in $changes) {
            $rpe = $null
            $modifiedFile = (Resolve-Path -Path $file -ErrorAction SilentlyContinue -ErrorVariable rpe).Path
            if ($rpe) {
                $modifiedFile = $rpe.TargetObject
            }
            $diffInSourcePaths = $sourcePaths | ForEach-Object {
                if ($modifiedFile -match "^$([text.regularexpressions.regex]::Escape($_))") {
                    $true
                }
            }
            if ($diffInSourcePaths) {
                $rebuildRequired = $true
                break
            }
        }
        $rebuildRequired
    }
}

class FileChecksum {
    [string] $Algorithm = ''
    [string] $Hash = ''
    [string] $Path = ''

    FileChecksum() {}
    
    FileChecksum([string]$checksum) {
        if ($checksum -match '^([^:]+):([^\s]+)\s\s(.+)') {
            $this.Algorithm = $Matches[1]
            $this.Hash = $Matches[2]
            $this.Path = $this.GetUnresolvedPath($Matches[3])
        } else {
            throw "Unexpected checksum string format '$checksum'"
        }
    }

    FileChecksum([object]$fileHash) {
        $this.Algorithm = $fileHash.Algorithm
        $this.Hash = $fileHash.Hash
        $this.Path = $this.GetUnresolvedPath($fileHash.Path)
    }

    [string] GetUnresolvedPath([string]$path) {
        $rpe = $null
        $unresolvedPath = Resolve-Path -Path $path -ErrorAction SilentlyContinue -ErrorVariable rpe
        if ($rpe) {
            $unresolvedPath = $rpe.TargetObject
        }
        return $unresolvedPath
    }

    [bool] GetHasChanged() {
        $newHash = [FileChecksum]::Create($this.Path, $this.Algorithm)
        return ($this.ToString() -cne $newHash.ToString())
    }

    [string] ToString() {
        $pwdPattern = [text.regularexpressions.regex]::Escape($PWD.Path)
        $relative = $this.GetUnresolvedPath($this.Path) -replace "^$pwdPattern\\?", ''
        return '{0}:{1}  {2}' -f $this.Algorithm.ToLower(), $this.Hash.ToLower(), $relative
    }

    static [FileChecksum] Create([string]$path, [string]$algorithm) {
        try {
            $literalPath = (Resolve-Path -Path $path -ErrorAction Stop).Path
            return ([FileChecksum](Get-FileHash -LiteralPath $literalPath -Algorithm $algorithm))
        } catch {
            throw
        }
    }
}

function Get-FolderChecksum {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([FileChecksum])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                if (-not (Test-Path -Path $_ -PathType Container)) {
                    throw 'Path must exist and be a folder.'
                }
                $true
            })]
        [string[]]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                if (-not (Test-Path -LiteralPath $_ -PathType Container)) {
                    throw 'LiteralPath must exist and be a folder.'
                }
                $true
            })]
        [string[]]
        $LiteralPath,

        [Parameter()]
        [ValidateSet('MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
        [string]
        $Algorithm = 'SHA256',

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $Recurse,

        [Parameter()]
        [string[]]
        $Exclude,

        # If specified, only files that have changed compared to the checksum will be returned.
        [Parameter()]
        [string]
        $ChecksumFile,

        # If specified, only files that have changed compared to the checksum will be returned.
        [Parameter(DontShow)]
        [hashtable]
        $ChecksumHashtable
    )

    begin {
        $checksums = @{}
        if ($ChecksumHashtable.Count -gt 0) {
            $checksums = $ChecksumHashtable    
        } else {
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('ChecksumFile')) {
                Get-Content -Path $ChecksumFile | ForEach-Object {
                    $checksum = [FileChecksum]$_
                    $checksums[$checksum.Path] = $checksum
                }
            }
        }
    }
    
    process {
        $Exclude = $Exclude | ForEach-Object {
            if ($_) {
                $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_)
            }
        }
        $gciParams = @{
            ($PSCmdlet.ParameterSetName) = $PSCmdlet.MyInvocation.BoundParameters[$PSCmdlet.ParameterSetName]
            Force                        = $Force
        }
        foreach ($item in Get-ChildItem @gciParams) {
            if ($item.FullName -in $Exclude) {
                Write-Verbose 'Skipping excluded path'
                continue
            }
            if ($item.PSIsContainer) {
                if ($Recurse -and [string]::IsNullOrWhiteSpace((& git check-ignore $item.FullName))) {
                    Get-FolderChecksum -LiteralPath $item.FullName -Algorithm $Algorithm -Force:$Force -Recurse -Exclude $Exclude -ChecksumHashtable $checksums
                }
            } elseif ([string]::IsNullOrWhiteSpace((& git check-ignore $item.FullName))) {
                if ($checksums.ContainsKey($item.FullName)) {
                    if ($checksums[$item.FullName].GetHasChanged()) {
                        [FileChecksum]::Create($item.FullName, $Algorithm)    
                    }
                } else {
                    [FileChecksum]::Create($item.FullName, $Algorithm)
                }
            }
        }
    }
}


enum MdState {
    Undefined
    InCodeBlock
}

class CodeBlock {
    [string] $Source
    [string] $Language
    [string] $Attributes
    [string] $Content
    [int]    $LineNumber
    [int]    $Position
    [bool]   $Inline
    
    # Holds the string representing the opening/closing tags for the inline code or code fence.
    # Inline code can be wrapped with single backticks, or double backticks if your incline code contains a backtick
    # Code fences can
    hidden [string] $Tag = [string]::Empty

    # Holds an optional string representing the indentation level of the beginning of the code block. Some mkdocs plugins
    # support admonitions and tabbed/collapsible sections which can contain fenced code blocks, but those code blocks
    # have to be intentented.
    hidden [string] $Indent = [string]::Empty
    
    [string] ToString() {
        return '{0}:{1}:{2}' -f $this.Source, $this.LineNumber, $this.Position
    }
}

function Get-MdCodeBlock {
    <#
    .SYNOPSIS
    Gets code from inline code and fenced code blocks in markdown files.

    .DESCRIPTION
    Gets code from inline code and fenced code blocks in markdown files with
    support for simple PyMdown Snippets syntax, and the PyMdown InlineHilite
    extension which allows you to use a "shebang" like `#!powershell Get-ChildItem *.md -Recurse | Get-MdCodeBlock`.

    .PARAMETER Path
    Specifies the path to the markdown file from which to extract code blocks.

    .PARAMETER BasePath
    Specifies the base path to use when resolving relative file paths for the CodeBlock object's Source property.

    .PARAMETER Language
    Specifies that only the codeblocks with the named language shortcode should be returned.

    .EXAMPLE
    Get-ChildItem -Path .\*.md -Recurse | Get-MdCodeBlock

    Gets information about inline and fenced code from all .md files in the current directory and any subdirectories
    recursively.

    .EXAMPLE
    Get-MdCodeBlock -Path docs\*.md -BasePath docs\

    Gets information about inline and fenced code from all .md files in the "docs" subdirectory. The Source property
    on each CodeBlock object returned will be relative to the docs subdirectory.

    .EXAMPLE
    Get-MDCodeBlock -Path docs\*.md -BasePath docs\ -Language powershell | ForEach-Object {
        Invoke-ScriptAnalyzer -ScriptDefinition $_.Content
    }

    Gets all inline and fenced PowerShell code from all .md files in the docs\ directory, and runs each of them through
    PSScriptAnalyzer using `Invoke-ScriptAnalyzer`.

    .EXAMPLE
    Get-ChildItem -Path *.md -Recurse | Get-MdCodeBlock | Where-Object Language -eq 'powershell' | ForEach-Object {
        $tokens = $errors = $null
        $ast = [management.automation.language.parser]::ParseInput($_.Content, [ref]$tokens, [ref]$errors)
        [pscustomobject]@{
            CodeBlock = $_
            Tokens    = $tokens
            Errors    = $errors
            Ast       = $ast
        }
    }

    Gets all inline and fenced powershell code from all markdown files in the current directory and all subdirectories,
    and runs them through the PowerShell language parser to return a PSCustomObject with the original CodeBlock, and the
    tokens, errors, and Abstract Syntax Tree returned by the language parser. You might use this to locate errors in
    your documentation, or find very specific elements of PowerShell code.

    .NOTES
    [Pymdown Snippets extension](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/)
    [Pymdown InlineHilite extension](https://facelessuser.github.io/pymdown-extensions/extensions/inlinehilite/)
    #>
    [CmdletBinding()]
    [OutputType([CodeBlock])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]]
        [SupportsWildcards()]
        $Path,

        [Parameter()]
        [string]
        $BasePath = '.',

        [Parameter()]
        [string]
        $Language
    )

    process {
        foreach ($unresolved in $Path) {
            foreach ($file in (Resolve-Path -Path $unresolved).Path) {
                $file = (Resolve-Path -Path $file).Path
                $BasePath = (Resolve-Path -Path $BasePath).Path
                $escapedRoot = [regex]::Escape($BasePath)
                $relativePath = ($file -replace $escapedRoot, '').TrimStart('\', '/')

                # This section imports files referenced by PyMdown snippet syntax
                # Example: --8<-- "abbreviations.md"
                # Note: This function only supports very basic snippet syntax.
                # See https://facelessuser.github.io/pymdown-extensions/extensions/snippets/ for documentation on the Snippets PyMdown extension
                $lines = [io.file]::ReadAllLines($file, [encoding]::UTF8) | ForEach-Object {
                    if ($_ -match '--8<-- "(?<file>[^"]+)"') {
                        $snippetPath = Join-Path -Path $BasePath -ChildPath $Matches.file
                        if (Test-Path -Path $snippetPath) {
                            Get-Content -Path $snippetPath
                        } else {
                            Write-Error "Snippet not found: $snippetPath"
                        }
                    } else {
                        $_
                    }
                }

                $pattern = @{
                    # Inline code must start with either one, or two backticks,
                    # and end on the same line with the same number of
                    # backticks. Inline code wrapped with two backticks allows
                    # for nested backtick characters.
                    InlineCode     = '(?<!`)(`{1,2})(#!(?<lang>\w+) )?(?<code>.+?(?=\1))\1'
                    
                    # This function supports non-standard, indented code blocks
                    # that are nested inside an mkdocs material admonition, and
                    # it allows for either a 3, or 4 backtick code fence. The
                    # closing fence must match the intent, and code fence
                    # characters exactly.
                    # NOTE: This will NOT match code blocks that are indented
                    # without a backtick "fence". The opening and closing fences
                    # must exist on their own lines.
                    CodeBlockStart = '^(?<indent>\s*)(?<tag>`{3,4})((?<lang>\w+)?(\s+(?<attrib>.+))?)?$'
                    
                    # The pattern for the end of a code block is dynamic since
                    # this command supports non-standard code blocks are
                    # indented and nested inside an mkdocs material admonition.
                    # Also, code blocks might start with 3, or 4 backticks, so
                    # the closing fence pattern will be formatted like...
                    #
                    # Example: $pattern.CodeBlockEnd -f $code.Indent, $code.Tag
                    # where Indent is a hidden property containing the white
                    # space characters preceeding the opening backtick(s), and
                    # Tag is a hidden property containing the backtick
                    # characters that defined the start of the code.
                    CodeBlockEnd   = '^{0}{1}'
                }

                $lineNumber = 0
                $code = $null
                $state = [MdState]::Undefined
                $content = [stringbuilder]::new()

                foreach ($line in $lines) {
                    $lineNumber++
                    switch ($state) {
                        'Undefined' {
                            if ($line -match $pattern.CodeBlockStart -and ([string]::IsNullOrWhiteSpace($Language) -or $Matches.lang -eq $Language)) {
                                $state = [MdState]::InCodeBlock
                                $code = [CodeBlock]@{
                                    Source     = '{0}:{1}:{2}' -f $relativePath, $lineNumber, ($Matches.indent.Length + 1)
                                    Language   = $Matches.lang
                                    Attributes = $Matches.attrib
                                    LineNumber = $lineNumber
                                    Tag        = $Matches.tag
                                    Indent     = $Matches.indent
                                }
                            } elseif (($inlineMatches = [regex]::Matches($line, $pattern.InlineCode))) {
                                if (-not [string]::IsNullOrWhiteSpace($Language) -and $inlineMatch.Groups.lang -ne $Language) {
                                    continue
                                }
                                foreach ($inlineMatch in $inlineMatches) {
                                    [CodeBlock]@{
                                        Source     = '{0}:{1}:{2}' -f $relativePath, $lineNumber, ($inlineMatch.Index + 1)
                                        Language   = $inlineMatch.Groups['lang'].Value
                                        Content    = $inlineMatch.Groups['code'].Value
                                        LineNumber = $lineNumber
                                        Position   = $inlineMatch.Index
                                        Inline     = $true
                                        Tag        = $inlineMatch.Groups[1].Value
                                    }
                                }
                            }
                        }

                        'InCodeBlock' {
                            if ($line -match ($pattern.CodeBlockEnd -f $code.Indent, $code.Tag)) {
                                $state = [MdState]::Undefined
                                $code.Content = $content.ToString()
                                $code
                                $code = $null
                                $null = $content.Clear()
                            } else {
                                $null = $content.AppendLine($line)
                            }
                        }
                    }
                }
            }
        }
    }
}

function Get-MinSupportedVmsVersion {
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter()]
        [string]
        $PackageName = 'MilestoneSystems.VideoOS.Platform',

        # Specifies the package source by name or by URI
        [Parameter()]
        [string]
        $Source,

        # Parameter help description
        [Parameter()]
        [scriptblock]
        $SupportedVersionsFilter = { ($_.Metadata['published'] | Get-Date) -ge (Get-Date).AddYears(-3) }
    )

    process {
        if ([string]::IsNullOrWhiteSpace($Source)) {
            if ($PSVersionTable.PSVersion -ge '6.0') {
                $Source = 'https://api.nuget.org/v3/index.json'
            } else {
                $Source = 'https://www.nuget.org/api/v2'
            }
        }
        $packages = Find-Package -Source $source -Name $PackageName -AllVersions
        
        $minSupportedVersion = $packages | Where-Object $SupportedVersionsFilter | ForEach-Object {
            [version]$_.Version
        } | Sort-Object | Select-Object -First 1
        
        [version]::new($minSupportedVersion.Major, $minSupportedVersion.Minor)
    }
}

function Find-NugetPackage {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Name = 'MilestoneSystems.VideoOS.Platform',

        # Specifies the package source by name or by URI
        [Parameter()]
        [string]
        $Source
    )
    process {
        if ([string]::IsNullOrWhiteSpace($Source)) {
            if ($PSVersionTable.PSVersion -ge '6.0') {
                $Source = 'https://api.nuget.org/v3/index.json'
            } else {
                $Source = 'https://www.nuget.org/api/v2'
            }
        }
        Find-Package -Source $Source -Name $Name -AllVersions
    }
}

function Get-SupportedVmsTable {
    [CmdletBinding()]
    param(
        [Parameter()]
        [datetime]
        $NotBefore = (Get-Date).AddYears(-3)
    )

    process {
        # MilestonePSTools started releasing with versions based on the Major/Minor MIP SDK versions beginning with MIP SDK 20.3.0
        $modules = Find-Module MilestonePSTools -AllVersions | Sort-Object { [version]$_.Version } | Group-Object { ([version]$_.Version).ToString(2) } | ForEach-Object {
            [pscustomobject]@{
                BaseVersion          = [version]$_.Name
                BaseVersionPublished = $_.Group[0].PublishedDate
                PublishedDate        = $_.Group[-1].PublishedDate
                Version              = $_.Group[-1].Version
            }
        }
        Find-NugetPackage | Sort-Object Version -Descending | Group-Object { ([version]$_.Version).ToString(2) } | ForEach-Object {
            $baseVersionPublishDate = $_.Group[-1].Metadata['published'] | Get-Date
            if ($baseVersionPublishDate -lt $NotBefore) { return }

            $module = $modules | Where-Object BaseVersionPublished -LT $baseVersionPublishDate.AddYears(3).AddMonths(-1) | Select-Object -Last 1
            $uriProperty = @{ Name = 'Uri'; Expression = { [uri]('https://www.powershellgallery.com/packages/MilestonePSTools/{0}' -f $_.Version.ToString()) } }
            [pscustomobject]@{
                Vms       = [version]$_.Name
                Published = $baseVersionPublishDate
                Module    = $module | Select-Object Version, PublishedDate, $uriProperty
            }
        }
    }
}

function Invoke-AppInsightsQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Query,

        [Parameter()]
        [string]
        $AppId,

        [Parameter()]
        [string]
        $ApiKey
    )

    begin {
        Add-Type -AssemblyName System.Web.HttpUtility
    }

    process {
        $queryString = [web.httputility]::ParseQueryString('')
        $queryString.Add('query', $Query)
        $uriBuilder = [uribuilder]"https://api.applicationinsights.io/v1/apps/$AppId/query"
        $uriBuilder.Query = $queryString.ToString();
        $splat = @{
            Uri     = $uriBuilder.Uri
            Headers = @{
                'x-api-key' = $ApiKey
            }
        }
        $response = Invoke-RestMethod @splat
        foreach ($table in $response.tables) {
            foreach ($row in $table.rows) {
                $record = [ordered]@{}
                for ($index = 0; $index -lt $table.columns.length; $index++) {
                    $record.Add($table.columns[$index].name, $row[$index])
                }
                'customDimensions', 'customMeasurements' | ForEach-Object {
                    if (-not [string]::IsNullOrWhiteSpace($record[$_])) {
                        $record[$_] = $record[$_] | ConvertFrom-Json
                    }
                }
                [pscustomobject]$record
            }
        }
    }
}

function Invoke-AzWorkspaceQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Query,

        [Parameter()]
        [string]
        $WorkspaceId,

        [Parameter()]
        [string]
        $Token
    )

    begin {
        Add-Type -AssemblyName System.Web
    }

    process {
        $queryString = [web.httputility]::ParseQueryString('')
        $queryString.Add('query', $Query)
        $uriBuilder = [uribuilder]"https://api.loganalytics.azure.com/v1/workspaces/$WorkspaceId/query"
        $uriBuilder.Query = $queryString.ToString();
        $splat = @{
            Uri     = $uriBuilder.Uri
            Headers = @{
                Authorization = "Bearer $Token"
            }
        }
        $response = Invoke-RestMethod @splat
        foreach ($table in $response.tables) {
            foreach ($row in $table.rows) {
                $record = [ordered]@{}
                for ($index = 0; $index -lt $table.columns.length; $index++) {
                    $record.Add($table.columns[$index].name, $row[$index])
                }
                'Properties', 'Measurements' | ForEach-Object {
                    if (-not [string]::IsNullOrWhiteSpace($record[$_])) {
                        $record[$_] = $record[$_] | ConvertFrom-Json
                    }
                }
                [pscustomobject]$record
            }
        }
    }
}

function Get-LogAnalyticsToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $TenantId,

        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [securestring]
        $Secret
    )
    
    process {
        $cred = [pscredential]::new($ClientId, $Secret)
        $splat = @{
            Method      = 'Post'
            Uri         = "https://login.microsoftonline.com/$TenantId/oauth2/token"
            ContentType = 'application/x-www-form-urlencoded'
            Body        = @{
                'grant_type' = 'client_credentials'
                'client_id'  = $cred.UserName
                'resource'   = 'https://api.loganalytics.io'
                'client_secret' = $cred.GetNetworkCredential().Password
            }
        }
        Invoke-RestMethod @splat
    }
}

function Get-VmsAppInsights {
    [CmdletBinding()]
    param ()
    
    process {
        $ErrorActionPreference = 'Stop'
        $vault = 'SecretStore'
        $password = $env:VAULT_PASSWORD_DEFAULT | ConvertTo-SecureString -AsPlainText -Force
        Unlock-SecretVault -Name $vault -Password $password
        
        $credential = Get-Secret -Vault $vault -Name 'MilestonePSTools.AppInsights.Credential'
        $tenantId = Get-Secret -Vault $vault -Name 'MilestonePSTools.AppInsights.TenantId' -AsPlainText
        $workspaceId = Get-Secret -Vault $vault -Name 'MilestonePSTools.AppInsights.WorkspaceId' -AsPlainText

        $splat = @{
            TenantId = $tenantId
            ClientId = $credential.UserName
            Secret   = $credential.Password
        }
        $token = Get-LogAnalyticsToken @splat

        $splat = @{
            Query = 'AppEvents | where TimeGenerated > ago({0}) | sort by TimeGenerated asc' -f '30d'
            WorkspaceId = $workspaceId
            Token       = $token.access_token
        }
        $events = Invoke-AzWorkspaceQuery @splat | ForEach-Object {
            $_.TimeGenerated = [datetime]$_.TimeGenerated
            $_
        }
        $eventsByUserId = @{}
        $eventsBySessionId = @{}
        $eventsBySiteId = @{}
        $sites = @{}
        $events | Group-Object UserId | ForEach-Object {
            $eventsByUserId[$_.Name] = $_.Group
        }
        $events | Group-Object SessionId | ForEach-Object {
            $eventsBySessionId[$_.Name] = $_.Group
        }
        $events | Where-Object { $null -ne $_.Properties.SiteId } | ForEach-Object {
            $_ | Group-Object { $_.Properties.SiteId } | ForEach-Object {
                $eventsBySiteId[$_.Name] = $_.Group
            }
            if ($_.Name -eq 'NewVmsConnection') {
                $sites[$_.Properties.SiteId] = [pscustomobject]@{
                    TimeGenerated     = [datetime]$_.TimeGenerated
                    UserId            = $_.UserId
                    SessionId         = $_.SessionId
                    AppVersion        = $_.AppVersion
                    AssemblyVersion   = $_.Properties.AssemblyVersion
                    SiteId            = $_.Properties.SiteId
                    IsOAuthConnection = $_.Properties.IsOAuthConnection
                    UserType          = $_.Properties.UserType
                    EncryptionEnabled = $_.Properties.EncryptionEnabled
                    ProductVersion    = $_.Properties.ProductVersion
                    ProductName       = $_.Properties.ProductName
                    CameraCount       = $_.Measurements.CameraCount
                    ChildSites        = $_.Measurements.ChildSites
                    OutputCount       = $_.Measurements.OutputCount
                    MetadataCount     = $_.Measurements.MetadataCount
                    InputCount        = $_.Measurements.InputCount
                    SpeakerCount      = $_.Measurements.SpeakerCount
                    MicrophoneCount   = $_.Measurements.MicrophoneCount
                    HardwareCount     = $_.Measurements.HardwareCount
                    Recorders         = $_.Measurements.Recorders
                }
            }
        }
        

        [pscustomobject]@{
            AppEvents = [pscustomobject]@{
                All         = $events
                ByUserId    = $eventsByUserId
                BySessionId = $eventsBySessionId
                BySiteId    = $eventsBySiteId
            }
            Users = $eventsByUserId.GetEnumerator() | ForEach-Object {
                $group = $_.Value
                $userId = $_.Key
                $siteGroups = $group.GetEnumerator() | Where-Object Name -eq 'NewVmsConnection' | Group-Object { $_.Properties.SiteId }
                [pscustomobject]@{
                    UserId = $userId
                    Events = $group.Count
                    FirstEvent = $group[0].TimeGenerated
                    LastEvent = $group[-1].TimeGenerated
                    DaysActive = ($group[-1].TimeGenerated - $group[0].TimeGenerated).TotalDays
                    Sites = $siteGroups.Length
                    Cameras = [int]($siteGroups | ForEach-Object { $_.Group[-1].Measurements.CameraCount } | Measure-Object -Sum).Sum
                    Location = '{0}, {1}' -f $group[0].ClientStateOrProvince, $group[0].ClientCountryOrRegion
                }
            }
            Sites = $sites.Values | Select-Object
        }
    }
}

function Update-TelemetryData {
$template = @'
## In the last 30 days

<div class="grid" markdown>

:octicons-device-camera-video-24: __{0}__ cameras
{{ .card }}

:material-login: __{1}__ sessions
{{ .card }}

:octicons-globe-24: __{2}__ countries
{{ .card }}

:fontawesome-solid-user-group: __{3}__ active users
{{ .card }}

:material-download: __{4}__ downloads
{{ .card }}

</div>

_usage based on optional telemetry_
'@

    try {
        $insights = Get-VmsAppInsights -ErrorAction Stop
        $html = Invoke-WebRequest https://www.powershellgallery.com/packages/milestonePSTools -ErrorAction Stop | ConvertFrom-Html
        $cameras = ($insights.Sites | Measure-Object -Sum CameraCount).Sum
        $sessions = $insights.AppEvents.BySessionId.Count
        $countries = ($insights.AppEvents.All | Group-Object ClientCountryOrRegion).Count
        $users = ($insights.Users | Where-Object Sites -gt 0).Count
        $downloads = $html.SelectNodes('//li[@class="package-details-info-main"]')[0].InnerText -split "\s+" | Where-Object { $_ } | Select-Object -First 1
        ($template -f $cameras, $sessions, $countries, $users, $downloads) | Set-Content -Path ./docs/telemetry.md.template
    } catch {
        throw
    }
}

$script:AppInsightsQueries = @{

    TotalSessions = @'
AppEvents
| where TimeGenerated  > ago(30d)
| where Name == "NewVmsConnection"
| where not(tostring(Properties.ProductName) matches regex "(Test)$")
| distinct SessionId
| summarize TotalSessions = count()
'@

    TotalUsers = @'
AppEvents
| where TimeGenerated  > ago(30d)
| where Name == "NewVmsConnection"
| where not(tostring(Properties.ProductName) matches regex "(Test)$")
| distinct UserId
| summarize TotalUsers = count()
'@

    TotalCameras = @'
AppEvents
| where TimeGenerated > ago(30d)
| where Name == "NewVmsConnection"
| where not(tostring(Properties.ProductName) matches regex "(Test)$")
| extend CamerasOnSite = todouble(Measurements["CameraCount"]), SiteId = tostring(Properties["SiteId"])
| summarize arg_max(TimeGenerated, *) by SiteId
| summarize TotalCameras = sum(CamerasOnSite)
'@

    TotalCountries = @'
AppEvents
| where TimeGenerated > ago(30d)
| where Name == "NewVmsConnection"
| where not(tostring(Properties.ProductName) matches regex "(Test)$")
| summarize TotalCountries = dcount(ClientCountryOrRegion)
'@

    TotalSites = @'
AppEvents
| where TimeGenerated > ago(30d)
| where Name == "NewVmsConnection"
| where not(tostring(Properties.ProductName) matches regex "(Test)$")
| extend SiteId = tostring(Properties["SiteId"])
| summarize TotalSites = dcount(SiteId)
'@

    CommandUsage = @'
AppEvents
| where TimeGenerated > ago(30d)
| where Name == "InvokeCommand"
| extend Command = tostring(Properties.Command)
| summarize InvocationCount = count(), UserCount = dcount(UserId) by Command
| order by Command asc
'@
}