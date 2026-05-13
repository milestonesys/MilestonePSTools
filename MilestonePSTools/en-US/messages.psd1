
@{
    # This is a table of en-US messages used in the functions in this module. We should
    # work on getting ALL string literals in Write-* cmdlets moved into this file so that
    # we can localize this file along with Get-Help content, and automatically improve
    # the messaging for languages we end up offering localized support for.

    # Look for Import-LocalizedData in the module manifest where this file will be imported
    # into a script-scope variable. Functions can then use these messages by referencing
    # $script:Messages.ListingAllRecorders for example.

    MustBeAdminToReadPasswords          = 'You must be in the Administrators role to read hardware passwords.'
    ListingAllRecorders                 = 'Listing all recording servers'
    CallingGetItemState                 = 'Calling Get-ItemState'
    StartingFillChildrenThreadJob       = 'Starting FillChildren threadjob'
    CameraOnSiteWithIdNotFound          = 'Camera not found on site {0} with ID {1}.'
    NotConnectedToAManagementServer     = 'Not connected to a Milestone XProtect Management Server.'
    PrebufferSecondsExceedsMaximumValue = 'PrebufferSeconds exceeds the maximum of value for in-memory buffering. The value will be updated to 15 seconds.'
    ClientServiceValidateResult         = 'Validation error: Failed to set {0} to "{1}". Reason: {2}.'
    FalseNotAllowedForRecordedProperty  = 'Value cannot be false for Recorded. To stop recording this stream, assign Primary to another stream using "-RecordingTrack Primary".'
    VideoOSDeviceNotFound               = 'Device ''{0}'' not found. It may have been added or enabled after the last configuration refresh. Try again after running Clear-VmsCache or Connect-Vms.'
}
