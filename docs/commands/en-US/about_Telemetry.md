---
description: Describes the telemetry collected in MilestonePSTools and how to opt-out.
Locale: en-US
online version: https://www.milestonepstools.com/commands/en-US/about_Telemetry/
schema: 2.0.0
title: about Telemetry
---
# about_Telemetry

## Short description

Describes the telemetry collected in MilestonePSTools and how to opt-out.

## Long description

MilestonePSTools sends telemetry data to Milestone using the Microsoft Azure
Application Insights service. This data helps us to better understand how, and
how frequently the module is used and enables us to prioritize new features,
fixes, and performance improvements.

MilestonePSTools anonymizes the telemetry, and does not collect personally
identifiable information, or information that can be used to indirectly
associate telemetry data with an identifiable natural person.

The following information is sent at the start of a new "session" which is
created upon importing MilestonePSTools into a Windows PowerShell environment:

- The `ProductVersion` property for the __MilestonePSTools.dll__ assembly
- The Operating System version
- The .NET Framework version
- The total number of logical processors
- The value of `Process.GetCurrentProcess().PrivateMemorySize64`
- The geographic location of the host, based on the IP address
- A randomly generated GUID representing the session instance
- A randomly generated GUID representing the user running the instance

!!! note
    When telemetry is sent to Application Insights, the source IP address is
    used to identify the geographic location. The source IP address is then
    discarded. Milestone does not include any public or private IP address
    information in the telemetry reported by MilestonePSTools.

The following information is sent when connecting to an XProtect VMS with
MilestonePSTools:

- A randomly generated GUID representing the XProtect Management Server site ID
- The type of user used to connect to the XProtect VMS (Basic, Windows, OAuth)
- Whether or not the connection to the XProtect VMS was established as an OAuth connection
- Whether or not the connection to the XProtect VMS was established over HTTPS
- The total number of child sites, recording servers, hardware, and enabled child devices including cameras, microphones, speakers, metadata channels, inputs, and outputs

The following information is sent when an XProtect VMS connection is closed
gracefully using `Disconnect-Vms`:

- The duration of the XProtect VMS connection session
- The value of `Process.GetCurrentProcess().PrivateMemorySize64`

To opt-out of this telemetry, set the environment variable
`$env:VMS_ApplicationInsights__Enabled` to `false`. For this environment
variable to have any effect, it must be set before importing the
MilestonePSTools module.

Alternatively, you can run the command `Set-VmsModuleConfig -EnableTelemetry $false`
and it will take effect immediately. Module configuration values are persisted
to disk under the current user profile at `~\AppData\Local\Milestone\MilestonePSTools\appsettings.user.json`.

!!! note
    If you connect to an XProtect VMS where the option **Enable usage data collection for XProtect Smart Client** is
    unchecked, telemetry will be immediately disabled for the current session, and for all future sessions for the
    current Windows user.
    ![Screenshot of "Tools/Options/Privacy Settings" dialog from Management Client](../../assets/images/privacy-settings.png)

For more information about Milestone's privacy policy, see [Privacy Policy](https://www.milestonesys.com/privacy-policy/).

## How are UserId and SiteId values anonymized?

MilestonePSTools follows the model set by the [PowerShell](https://github.com/PowerShell/PowerShell)
repository and checks for a file in the current user's local AppData directory
at `~\AppData\Local\Milestone\MilestonePSTools\telemetry.uuid`. If the file
exists, the UserId is set based on the content of the file. Otherwise, a new
random GUID is generated and stored here.

Similarly, when you connect to a Milestone XProtect Management Server with
MilestonePSTools, we will check for a file named `site-<actual-site-id>.uuid`
in the same AppData directory at `~\AppData\Local\Milestone\MilestonePSTools\`.
If the file does not exist, a new random GUID is generated and stored here.

If the same Windows or Active Directory user connects to the same XProtect
instance from another Windows computer, new unique values for UserId and SiteId
are generated making it impossible to associate telemetry sent from two
computers with the same user or XProtect site.

These randomly generated GUID's ensure that telemetry cannot be associated with
a real user name, computer name, or the name of a Milestone customer, while
also enabling Milestone to observe module usage patterns over time.

## Logging

Raw telemetry data can be logged to the `MilestonePSTools<yyyyMMdd>.log` files in `C:\ProgramData\Milestone\MIPSDK\` by
running the following command:

```powershell
Set-VmsModuleConfig -LogTelemetry $true
```

The **NewVmsSession** event includes telemetry similar to the JSON document below:

```json
{
  "Timestamp": "2024-06-21T23:46:21.390801+00:00",
  "Context": {
    "InstrumentationKey": "0ec7d4ee-5b3a-4db2-b83d-ccb675330317",
    "Flags": 0,
    "Component": {
      "Version": "23.3.46\u002Bdb544ff02b"
    },
    "Device": {
      "Type": null,
      "Id": null,
      "OperatingSystem": null,
      "OemName": null,
      "Model": null,
      "NetworkType": null,
      "ScreenResolution": null,
      "Language": null
    },
    "Cloud": {
      "RoleName": "na",
      "RoleInstance": "na"
    },
    "Session": {
      "Id": "339856bd-a483-4dee-8f8a-582acad45a39",
      "IsFirst": null
    },
    "User": {
      "Id": "cbd0964d-c474-4f21-b43e-685d37b2de31",
      "AccountId": null,
      "UserAgent": null,
      "AuthenticatedUserId": "na"
    },
    "Operation": {
      "Id": null,
      "ParentId": null,
      "CorrelationVector": null,
      "Name": null,
      "SyntheticSource": null
    },
    "Location": {
      "Ip": "0.0.0.0"
    },
    "Properties": {
      "uuid": "cbd0964d-c474-4f21-b43e-685d37b2de31",
      "UserType": "WindowsUser",
      "IsOAuthConnection": "True",
      "EncryptionEnabled": "True",
      "SessionId": "339856bd-a483-4dee-8f8a-582acad45a39",
      "ProductVersion": "23.3.62.1",
      "ProductName": "XProtect Corporate 2023 R3",
      "AssemblyVersion": "23.3.46\u002Bdb544ff02b",
      "SiteId": "b5630dc9-1a27-49fa-8f0f-5801c72a8663"
    },
    "GlobalProperties": {}
  },
  "Extension": null,
  "Sequence": null
}
```

