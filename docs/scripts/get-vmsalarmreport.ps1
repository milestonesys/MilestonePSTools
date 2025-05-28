function Get-VmsAlarmReport {
    <#
    .SYNOPSIS
        Gets a list of alarms matching the specified criteria.
    .DESCRIPTION
        Uses Get-AlarmLine with conditions specified using New-AlarmCondition
        to retrieve a list of alarms within the specified time frame and
        matching optional State and Priority criteria.

        The AlarmUpdateHistory is queried for each alarm to retrieve the
        reason for closing and closing comments, if available.

        Optionally, snapshots can be requested for each alarm. If requested,
        these snapshots will be from only one "related camera". Alarms may have
        multiple related cameras, but the AlarmClient will only retrieve a snapshot
        from one of them. The snapshot will be resized to the specified height
        and returned as a System.Drawing.Image object.

    .EXAMPLE
        Connect-Vms -ShowDialog -AcceptEula
        Get-VmsAlarmReport -StartTime (Get-Date).AddDays(-1) -State Closed -UseLastModified

        Gets a report of all alarms last modified in the last 24 hour period, with
        a current state of "Closed".
    #>
    [CmdletBinding()]
    param(
        # Specifies the start time to filter for alarms created on or after
        # StartTime, or last modified on or after StartTime when used with the
        # UseLastModified switch.
        [Parameter()]
        [datetime]
        $StartTime = (Get-Date).AddHours(-1),

        # Specifies the end time to filter for alarms created on or before
        # EndTime, or last modified on or before EndTime when used with the
        # UseLastModified switch.
        [Parameter()]
        [datetime]
        $EndTime = (Get-Date),

        # Specifies an optional state name with which to filter alarms. Common
        # states are New, In progress, On hold, and Closed. Custom alarm states
        # may be defined for your environment in Management Client.
        [Parameter()]
        [string]
        $State,

        # Specifies an optional priority name with which to filter alarms.
        # Common priorities are High, Medium, and Low. Custom priorities may
        # be defined for your environment in Management Client.
        [Parameter()]
        [string]
        $Priority,

        # Specifies that the StartTime and EndTime filters apply to the
        # "Modified" property of the alarm instead of the "Timestamp" property.
        [Parameter()]
        [switch]
        $UseLastModified,

        # Specifies that the timestamps returned with the report should be
        # converted from UTC time to the local time based on the region settings
        # of the current PowerShell session.
        [Parameter()]
        [switch]
        $UseLocalTime,

        # Specifies that a snapshot should be retrieved for each alarm having
        # a related camera. The snapshot will be returned as a System.Drawing.Image
        # object.
        [Parameter()]
        [switch]
        $IncludeSnapshots,

        # Specifies the desired snapshot height in pixels. The snapshots will
        # be resized accordingly.
        [Parameter()]
        [ValidateRange(50, [int]::MaxValue)]
        [int]
        $SnapshotHeight = 200
    )

    begin {
        $mgr = [VideoOS.Platform.Proxy.AlarmClient.AlarmClientManager]::new()
        $alarmClient = $mgr.GetAlarmClient((Get-VmsSite).FQID.ServerId)
    }

    process {
        $target = if ($UseLastModified) { 'Modified' } else { 'Timestamp' }
        $conditions = [System.Collections.Generic.List[VideoOS.Platform.Proxy.Alarm.Condition]]::new()
        $conditions.Add((New-AlarmCondition -Target $target -Operator GreaterThan -Value $StartTime.ToUniversalTime()))
        $conditions.Add((New-AlarmCondition -Target $target -Operator LessThan -Value $EndTime.ToUniversalTime()))

        if ($MyInvocation.BoundParameters.ContainsKey('State')) {
            $conditions.Add((New-AlarmCondition -Target StateName -Operator Equals -Value $State))
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Priority')) {
            $conditions.Add((New-AlarmCondition -Target PriorityName -Operator Equals -Value $Priority))
        }

        $sortOrders = New-AlarmOrder -Order Ascending -Target $target

        Get-AlarmLine -Conditions $conditions -SortOrders $sortOrders | ForEach-Object {
            $alarm = $_
            $history = $alarmClient.GetAlarmUpdateHistory($alarm.Id) | Sort-Object Time
            $openedAt = if ($UseLocalTime) { $alarm.Timestamp.ToLocalTime() } else { $alarm.Timestamp }

            $closingUpdate = $history | Where-Object Key -eq 'ReasonCode' | Select-Object -Last 1
            $closingReason = $closingUpdate.Value
            $closingUser = $closingUpdate.Author
            $closedAt = if ($UseLocalTime -and $null -ne $closingUpdate.Time) { $closingUpdate.Time.ToLocalTime() } else { $closingUpdate.Time }
            $closingComment = ($history | Where-Object { $_.Key -eq 'Comment' -and $_.Time -eq $closingUpdate.Time }).Value

            $operator = if ([string]::IsNullOrWhiteSpace($closingUser)) { $alarm.AssignedTo } else { $closingUser }

            $obj = [ordered]@{
                CreatedAt = $openedAt
                Alarm = $alarm.Name
                Message = $alarm.Message
                Source = $alarm.SourceName
                ClosedAt = $closedAt
                ReasonCode = $closingReason
                Notes = $closingComment
                Operator = $operator
            }
            if ($IncludeSnapshots) {
                $obj.Snapshot = $null
                if ($alarm.CameraId -eq [guid]::empty) {
                    $obj.Snapshot = 'No camera associated with alarm'
                } else {
                    $cameraItem = [VideoOS.Platform.Configuration]::Instance.GetItem($alarm.CameraId, ([VideoOS.Platform.Kind]::Camera))
                    if ($null -ne $cameraItem) {
                        $snapshot = $null
                        $snapshot = Get-Snapshot -CameraId $alarm.CameraId -Timestamp $openedAt -Behavior GetNearest -Quality 100
                        if ($null -ne $snapshot) {
                            $obj.Snapshot = ConvertFrom-Snapshot -Content $snapshot.Bytes | Resize-Image -Height $SnapshotHeight -Quality 100 -OutputFormat PNG -DisposeSource
                        } else {
                            $obj.Snapshot = 'Image not available'
                        }
                    } else {
                        $obj.Snapshot = 'Camera not found'
                    }
                }
            }
            Write-Output ([pscustomobject]$obj)
        }
    }

    end {
        $alarmClient.CloseClient()
    }
}
