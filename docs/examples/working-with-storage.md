# Working with Storage

A video management system has a habit of consuming a *lot* of storage. As the
administrator for a VMS, it's important to be able to understand the state of
your servers and storage, and draw useful insights about your past and future
usage.

The Management Client and XProtect Smart Client offer some of these insights through the
System Monitor. However, you may need a more specific view of your environment
or the ability to push data into external tools such as Grafana, Power BI, and
so on.

## What data is available to you?

The MIP SDK offers access to a lot of information about your storage
configuration and devices, but there are some gaps. Here's a simplistic
breakdown of what data you can, and can't read through the MIP SDK or
MilestonePSTools.

!!! success "Possible"

    - Read total used bytes per camera
    - Read total used bytes per storage or archive

!!! failure "Not possible"

    - Read total used bytes per camera, per storage

You may have noticed that the Management Client offers a view of how much data
a camera has sitting in each storage or archive location. You'll find this on
the **Record** tab of a camera, microphone, speaker, or metadata device.

As it stands today, this table is populated by an internal API call which is
not available through MIP SDK. If you discover otherwise, please let us know
and we'll update this guide!

## Accessing Storage and ArchiveStorage Information

There is a method on the Storage class in MIP SDK called `ReadStorageInformation()`
but it's not immediately obvious how to use the resulting `ServerTask` object. It
appears to provide you with only a **State** value indicating whether the
request succeeded, and a **Path** like
`StorageInformation[444b824b-1ec4-4c4b-9a5a-c3932b664096]` along with a couple
other properties.

However, there are a few useful methods on the `ServerTask` object including
`GetPropertyKeys()` and `GetProperty([string])`. The following table was
produced by a script which uses `ReadStorageInformation()` and the similar
`ReadArchiveStorageInformation()` methods to retrieve the total used disk
space, in bytes, for each storage and child archive-storage.

|RecordingServer|Name         |Path                                                  |MaxSize      |UsedSpace|LockedUsedSpace|
|---------------|-------------|------------------------------------------------------|-------------|---------|---------------|
|EC2AMAZ-4JLP3R3|Local default|C:\MediaDatabase\444B824B-1EC4-4C4B-9A5A-C3932B664096\|1073741824000|98566144 |0              |
|EC2AMAZ-4JLP3R3|Archive 1    |C:\mediadatabase\81F9AAB4-F8C3-4954-A31A-F0021D0450CA\|1073741824000|0        |0              |

### :material-powershell: Example

The function below demonstrates how you can use MilestonePSTools to generate
this report. To use it, add it to the top of your script and call it
using `Get-VmsStorageInfo`.

!!! note

    Make sure to install MilestonePSTools first, and to
    connect to the management server using `Connect-Vms`.

```powershell linenums="1" title="Get-VmsStorageInfo.ps1"
function Get-VmsStorageInfo {
    <#
    .SYNOPSIS
    Gets information about used disk space for each storage and archive

    .DESCRIPTION
    Each storage and archive object in a Milestone VMS is able to return a
    UsedSpace property and depending on your VMS version, a LockedUsedSpace
    property indicating how much overall storage space is used by that
    storage area, and how much data is "Evidence Locked", respectively.

    .PARAMETER RecordingServer
    Specifies one or more RecordingServer objects as returned by Get-VmsRecordingServer.

    Omit this property and data will be returned for all recording servers.

    .EXAMPLE
    PS C:\> Get-VmsStorageInfo | Export-Csv -Path ~\Desktop\StorageReport.csv -NoTypeInformation

    Returns a collection of properties for each storage and archive storage on
    the recording server named 'MyRecorder'. The properties returned include

    - RecordingServer - the display name of the recording server
    - Storage - the name of the storage configuration with recording and optional archive paths
    - IsDefault - True if the default storage for the recording server
    - Name - "Recording" for the live recording path and the display name of archives if present
    - Path - disk path, relative to the recording server
    - MaxSizeGB - the maximum size in bytes configured for the storage area in gigabytes
    - UsedSpace - the total used space, in gigabytes
    - LockedUsedSpace - the amount of data "locked" by evidence locks in gigabytes

    The results are piped to Export-Csv so that they can be easily reviewed
    and manipulated in your office suite of choice.

    Note: You must have MilestonePSTools installed, and you must connect to
    a management server using Connect-Vms before calling this
    function.

    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.RecordingServer[]]
        $RecordingServer
    )

    process {
        if ($null -eq $RecordingServer -or $RecordingServer.Count -eq 0) {
            $RecordingServer = Get-VmsRecordingServer
        }
        foreach ($recorder in $RecordingServer) {
            foreach ($storage in $recorder | Get-VmsStorage) {
                $info = $storage.ReadStorageInformation()
                $usedSpace = $info.GetProperty('UsedSpace') -as [double]
                $lockedUsedSpace = 0
                if ($info.GetPropertyKeys() -contains 'LockedUsedSpace') {
                    $lockedUsedSpace = $info.GetProperty('LockedUsedSpace') -as [double]
                }

                [pscustomobject]@{
                    RecordingServer = $recorder.Name
                    Storage         = $storage.Name
                    IsDefault       = $storage.IsDefault
                    Name            = 'Recording'
                    Path            = [io.path]::Combine($storage.DiskPath, $storage.Id)
                    MaxSizeGB       = $storage.MaxSize / 1024
                    UsedSpaceGB     = $usedSpace / 1024
                    LockedUsedSpaceGB = $lockedUsedSpace / 1024
                }
                Remove-Variable info, usedSpace, lockedUsedSpace

                foreach ($archive in $storage | Get-VmsArchiveStorage) {
                    $info = $archive.ReadArchiveStorageInformation()
                    $usedSpace = $info.GetProperty('UsedSpace') -as [double]
                    $lockedUsedSpace = 0
                    if ($info.GetPropertyKeys() -contains 'LockedUsedSpace') {
                        $lockedUsedSpace = $info.GetProperty('LockedUsedSpace') -as [double]
                    }

                    [pscustomobject]@{
                        RecordingServer = $recorder.Name
                        Storage         = $storage.Name
                        IsDefault       = $storage.IsDefault
                        Name            = $archive.Name
                        Path            = [io.path]::Combine($archive.DiskPath, $archive.Id)
                        MaxSizeGB       = $archive.MaxSize / 1024
                        UsedSpaceGB       = $usedSpace / 1024
                        LockedUsedSpaceGB = $lockedUsedSpace / 1024
                    }
                }
            }
        }
    }
}
```

## Accessing Per-Camera Information

To access the amount of disk space used for each camera, we need to use the
RecorderStatusService2 interface to ask the recording server(s) directly.
Specifically, we can use the `GetVideoDeviceStatistics()` method which accepts
a Milestone "token" like `TOKEN#526b9610-0541-44e2-b50d-1aea51a45ed5#ec2amaz-4jlp3r3//ServerConnector#`
and an array of `[guid]` objects representing the ID's of one or more cameras.

In the sample function below, we also use the `Get-IServerCommandService`
cmdlet to access a simplified view of the VMS configuration. This isn't
necessary - we could get all the camera ID's by using `($recorder | Get-VmsHardware | Get-VmsCamera).Id`
but on a larger system this can take longer than necessary to complete due to
the large number of Configuration API requests made to retrieve all the
properties of the hardware objects in addition to the camera objects.

By using the `IServerCommandService` interface, we make a single configuration
request which gives us enough information to know which cameras are on which
recording servers.

With these tools available to us, we can produce a report like you see in the
table below.

|RecordingServer|CameraName   |CameraId                                              |UsedSpaceInBytes|
|---------------|-------------|------------------------------------------------------|----------------|
|EC2AMAZ-4JLP3R3|Big Buck Bunny Demo - Camera 1|50277b73-9fd8-4aca-bde4-752a479e833c                  |161445304       |


### :material-powershell: Example

As with the previous example, you can add this function to your script and call
it using `Get-VmsCameraStorageInfo`. See the examples in the comment-based help
and again - make sure you have MilestonePSTools installed, and you are
connected to a management server by using `Connect-Vms`.

```powershell linenums="1" title="Get-VmsCameraStorageInfo.ps1"
function Get-VmsCameraStorageInfo {
    <#
    .SYNOPSIS
    Gets information about total used disk space for each camera

    .DESCRIPTION
    The RecorderStatusService2 interface allows you to retrieve basic
    camera statistics including used disk space and stream information. This
    function uses the interface to produce a table of cameras and the total
    used disk space in bytes for each of them.

    .PARAMETER RecordingServer
    Specifies one or more RecordingServer objects as returned by Get-VmsRecordingServer.

    Omit this property and data will be returned for all recording servers.

    .EXAMPLE
    PS C:\> Get-VmsCameraStorageInfo | Export-Csv -Path ~\Desktop\CameraStorageReport.csv -NoTypeInformation

    Returns a collection of properties for each camera on each recording server
    including:

    - RecordingServer - the display name of the recording server
    - CameraName - the display name of the camera
    - CameraId - a GUID identifier for the camera
    - UsedSpaceInBytes - the total used space in bytes across all storage and archive paths

    Note: You must have MilestonePSTools installed, and you must connect to
    a management server using Connect-Vms before calling this
    function.

    .EXAMPLE
    PS C:\> Get-VmsCameraStorageInfo | Out-GridView

    Presents the same data as in the first example, except in an interactive
    GridView interface which can be sorted and filtered.

    .EXAMPLE
    PS C:\> Get-VmsRecordingServer -Name 'MyRecorder' | Get-VmsCameraStorageInfo | Out-GridView

    Presents all cameras from the recording server named 'MyRecorder' in a
    GridView.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.RecordingServer[]]
        $RecordingServer
    )

    begin {
        try {
            $config = (Get-IServerCommandService -ErrorAction Stop).GetConfiguration((Get-VmsToken))
        }
        catch {
            throw
        }
    }

    process {
        if ($null -eq $RecordingServer -or $RecordingServer.Count -eq 0) {
            $RecordingServer = Get-VmsRecordingServer
        }

        foreach ($recorder in $RecordingServer) {
            $cameraMap = @{}
            ($config.Recorders | Where-Object RecorderId -eq ([guid]$recorder.Id)).Cameras | Foreach-Object {
                $cameraMap[$_.DeviceId] = $_
            }
            $deviceIds = ($config.Recorders | Where-Object RecorderId -eq ([guid]$recorder.Id)).Cameras.DeviceId
            try {
                $svc = $recorder | Get-RecorderStatusService2
                $svc.GetVideoDeviceStatistics((Get-VmsToken), $deviceIds) | Foreach-Object {
                    [pscustomobject]@{
                        RecordingServer = $recorder.Name
                        CameraName = $cameraMap[$_.DeviceId].Name
                        CameraId = $_.DeviceId
                        UsedSpaceInBytes = $_.UsedSpaceInBytes
                    }
                }
            }
            finally {
                if ($svc) {
                    $svc.Dispose()
                    $svc = $null
                }
            }
        }
    }
}
```

--8<-- "abbreviations.md"

