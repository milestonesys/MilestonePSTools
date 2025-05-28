# about_Get-VmsCameraReport

This topic is an extension to the Get-VmsCameraReport documentation

## SHORT DESCRIPTION

The Get-VmsCameraReport cmdlet provides an extensive number of columns of data
for each camera. While we try to provide a descriptive column name, the meaning
of values are not always clear. And sometimes values might not be what you
expect to see. This topic serves to document some of this information to answer
questions that may come up when this command is used in production.

## LONG DESCRIPTION

The columns from IsStarted to StatusTime come from the RecorderStatusService2
interface using the GetCurrentDeviceStatus method. These values can only be
provided if your PowerShell session is able to establish a connection to the
Recording Server on port 7563 (default).

The Model and Firmware columns may not perfectly reflect the current model and
firmware but they should hopefully accurately match what is displayed in the
Management Client. The firmware is specially troublesome as the value is only
updated when performing a "Replace Hardware" on the camera in Management
Client. There is currently no mechanism to perform Replace Hardware using MIP
SDK or MilestonePSTools.

The Configured*vs Current* stream information will *usually* match, but
sometimes the stream configuration properties aren't available - such as on the
universal camera driver. And sometimes even if both the configured, and current
stream properties are available, they might not match. That would be out of the
ordinary, but it has happened. For example, if a camera is being used by two
different VMS's, one may update the stream properties to be out of sync with
the other.

The Snapshot feature can be very useful, but you cannot export a jpeg snapshot
to a CSV file in a way that is universally understood by all applications. You
could, for example, base64 encode the image and include it in text format. But
to display the image, the consuming application would need to know what to do
with that encoded binary data. We will provide an example of how you might
process the snapshot column in a future sample.

## Summary of all potential columns

|Column                        |Description                                   |
|------------------------------|----------------------------------------------|
|Name                          |Name of the camera                            |
|Channel                       |The channel number, counting from 0           |
|Enabled                       |True if both hardware and camera are enabled  |
|State                         |The state according to Event Server           |
|LastModified                  |Timestamp of last Last configuration change   |
|Id                            |A GUID representing the camera ID in the VMS  |
|IsStarted                     |True if recording server has started device   |
|IsMotionDetected              |True if motion currently detected on camera   |
|IsRecording                   |True if recording is currently in progress    |
|IsInOverflow                  |True if storage cannot record quickly enough  |
|IsInDbRepair                  |True if recording server is repairing the DB  |
|ErrorWritingGOP               |True if recording server cannot write to DB   |
|ErrorNotLicensed              |True if device not licensed or grace expired  |
|ErrorNoConnection             |True if recording server cannot receive stream|
|StatusTime                    |Timestamp of status information from recorder |
|GpsCoordinates                |The LAT,LONG, or 'Unknown' if not specified   |
|HardwareName                  |Name of camera's parent hardware device       |
|HardwareId                    |The ID of the parent hardware device          |
|Model                         |Model of the parent hardware device           |
|Address                       |URI of parent hardware. Example: <http://mycam/>|
|Username                      |The username for the parent hardware device.  |
|Password                      |Requires -IncludePlainTextPassword            |
|HTTPSEnabled                  |True if HTTPS is enabled for hardware device  |
|MAC                           |MAC address for the parent hardware device    |
|Firmware                      |Last known firmware of parent hardware device |
|DriverFamily                  |Driver "GroupName" - example: Axis, Bosch     |
|Driver                        |Device driver name for the parent hardware    |
|DriverNumber                  |The driver number for the device pack driver  |
|DriverVersion                 |Device pack driver version string             |
|DriverRevision                |Driver revision value for the parent hardware |
|RecorderName                  |Display name of the parent recording server   |
|RecorderUri                   |Recording Server hostname and port as a URI   |
|RecorderId                    |The Recording Server ID                       |
|LiveStream                    |Internal name of video stream used for live   |
|LiveStreamDescription         |Optional custom name for the live stream      |
|LiveStreamMode                |Always/Never/WhenNeeded                       |
|ConfiguredLiveResolution      |Live stream resolution, if value is available |
|ConfiguredLiveCodec           |Live stream codec, if value is available      |
|ConfiguredLiveFPS             |Live stream FPS, if value is available        |
|CurrentLiveResolution         |Current live resolution according to recorder |
|CurrentLiveCodec              |Current live codec according to recorder      |
|CurrentLiveFPS                |Current live FPS according to recorder        |
|CurrentLiveBitrate            |Current live bitrate according to recorder    |
|RecordedStream                |Internal name of video stream used for record |
|RecordedStreamDescription     |Optional custom name for the recorded stream  |
|RecordedStreamMode            |Always/Never/WhenNeeded                       |
|ConfiguredRecordedResolution  |Recorded stream resolution, if available      |
|ConfiguredRecordedCodec       |Recorded stream codec, if available           |
|ConfiguredRecordedFPS         |Recorded stream FPS, if available             |
|CurrentRecordedResolution     |Current recorded resolution                   |
|CurrentRecordedCodec          |Current recorded codec according to recorder  |
|CurrentRecordedFPS            |Current recorded FPS according to recorder    |
|CurrentRecordedBitrate        |Current recorded bitrate according to recorder|
|RecordingEnabled              |True if recording is enabled for this camera  |
|RecordKeyframesOnly           |True if recording only keyframes              |
|RecordOnRelatedDevices        |True if recording on related devices enabled  |
|PrebufferEnabled              |True if prebuffer is enabled for the camera   |
|PrebufferSeconds              |Max number of seconds available in prebuffer  |
|PrebufferInMemory             |True if prebuffering to memory instead of disk|
|RecordingStorageName          |Display name of recording storage for camera  |
|RecordingPath                 |Disk path of recording storage on recorder    |
|ExpectedRetentionDays         |Expected minimum number of days to record     |
|PercentRecordedOneWeek        |Percent time recorded in previous 7 days      |
|MediaDatabaseBegin            |UTC timestamp of the first recorded image     |
|MediaDatabaseEnd              |UTC timestamp of the last recorded image      |
|UsedSpaceInGB                 |Disk space used by camera in GB               |
|ActualRetentionDays           |Days between now and the first recorded image |
|MeetsRetentionPolicy          |True if oldest image is <= MediaDatabaseBegin |
|MotionEnabled                 |True if server-side motion detection enabled  |
|MotionKeyframesOnly           |True if motion is detected on keyframes only  |
|MotionProcessTime             |Interval, in MS, between motion processing    |
|MotionManualSensitivityEnabled|True if motion sensitivity settings are manual|
|MotionManualSensitivity       |Current motion detection sensitivity value    |
|MotionMetadataEnabled         |True if capturing motion detection metadata   |
|MotionExcludeRegions          |True if a motion exclusion region is defined  |
|MotionHardwareAccelerationMode|Automatic/Off - hardware acceleration mode    |
|PrivacyMaskEnabled            |True if a privacy mask is enabled             |
|Snapshot                      |System.Drawing.Image from live snapshot JPEG  |

## KEYWORDS

- Get-CameraReport
- CameraReport
- Camera Report

