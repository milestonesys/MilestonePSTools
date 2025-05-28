function Get-VmsSequenceInfo {
    <#
    .SYNOPSIS
    Get information about recording or motion sequences for a camera.
    
    .DESCRIPTION
    The `Get-VmsSequenceInfo` cmdlet gets information about recording or motion sequences for a camera using the
    `Get-SequenceData` cmdlet which uses the VideoOS.Platform.Data.SequenceDataSource MIP SDK class.
    
    The `Get-SequenceData` cmdlet gets the collection of sequences defining the beginning and end of a segment of
    recorded video or detected motion.

    This command uses this information to produce some simple statistics about the provided time range to help you
    understand how much of that time period includes recordings, or motion.
    
    .PARAMETER Camera
    A camera object as returned by `Get-VmsCamera`.
    
    .PARAMETER StartTime
    A `DateTime` value representing the beginning of the time period of interest.
    
    .PARAMETER EndTime
    A `DateTime` value representing the end of the time period of interest.
    
    .PARAMETER SequenceType
    The type of sequences to return statistics about. The default type is "RecordingSequence".
    
    .PARAMETER AllowedMargin
    A gap of under 100ms at the beginning and end of the specified time range is common due to the time between recorded
    images (33-66ms for 15-30 fps) and are ignored by default.
    
    .EXAMPLE
    $end = Get-Date
    $start = $end.AddDays(-31)
    $cameras = Get-VmsCamera | Out-GridView -OutputMode Multiple
    $cameras | Get-VmsSequenceInfo -StartTime $start -EndTime $end
    
    This example will prompt for a selection of one or more enabled cameras, and then retrieve the recording sequence
    statistics for that camera for the past 31 days.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Camera]
        $Camera,

        [Parameter(Mandatory)]
        [datetime]
        $StartTime,

        [Parameter(Mandatory)]
        [datetime]
        $EndTime,

        [Parameter()]
        [ValidateSet('MotionSequence', 'RecordingSequence', 'RecordingWithTriggerSequence')]
        [string]
        $SequenceType = 'RecordingSequence',

        [Parameter()]
        [timespan]
        $AllowedMargin = [timespan]::FromMilliseconds(100)
    )
    
    process {
        $StartTime = $StartTime.ToUniversalTime()
        $EndTime = $EndTime.ToUniversalTime()
        $splat = @{
            StartTime    = $StartTime
            EndTime      = $EndTime
            SequenceType = $SequenceType
        }
        $sequences = $Camera | Get-SequenceData @splat | ForEach-Object EventSequence
        
        $totalCoverage = [timespan]::Zero
        $gapSequences = [system.collections.generic.list[timespan]]::new()
        $lastSequenceEndTime = $StartTime.ToUniversalTime()
        
        $isFirstSequence = $true
        foreach ($sequence in $sequences) {
            $seqStart = $sequence.StartDateTime
            $seqEnd = $sequence.EndDateTime

            # Clamp the sequence timestamps to the user-defined StartTime and EndTime values
            if ($seqStart -lt $StartTime) {
                $seqStart = $StartTime
            }
            if ($seqEnd -gt $EndTime) {
                $seqEnd = $EndTime
            }
            
            $totalCoverage += $seqEnd - $seqStart
            
            $gap = $seqStart - $lastSequenceEndTime
            if (!$isFirstSequence -or $gap -gt $AllowedMargin) {
                # Don't record a gap between StartTime and the first sequence if it's less than the allowed margin
                $gapSequences.Add($gap)
            }
            
            $lastSequenceEndTime = $seqEnd
            $isFirstSequence = $false
        }

        $gap = $EndTime - $lastSequenceEndTime
        if ($gap -gt $AllowedMargin) {
            # Don't record a gap between the last sequence and EndTime if it's less than the allowed margin
            $gapSequences.Add($gap)
        }
        
        $gapStats = $gapSequences | Measure-Object TotalMilliseconds -Minimum -Maximum -Average

        [PSCustomObject]@{
            Camera          = $Camera

            TimeSpan        = $EndTime - $StartTime
            PercentCoverage = $totalCoverage.TotalMilliseconds / ($EndTime - $StartTime).TotalMilliseconds
            TotalCoverage   = $totalCoverage
            SequenceCount   = $sequences.Count
            
            MinimumGap      = [timespan]::FromMilliseconds($gapStats.Minimum)
            MaximumGap      = [timespan]::FromMilliseconds($gapStats.Maximum)
            AverageGap      = [timespan]::FromMilliseconds($gapStats.Average)
            GapCount        = $gapStats.Count
        }
    }
}
