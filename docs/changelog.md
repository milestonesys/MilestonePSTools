---
hide:
  - navigation
---

# Changelog

## [vNext] unreleased

### 🔄 Changed

- Updated MIP SDK package references from `25.1.3` to `25.2.1`.
- Removed the logic behind the `AcceptEula` switch parameter on the `Connect-Vms` and `Connect-ManagementServer`
  commands. The parameters still exists, but it does nothing and is no longer required on the first login.

### 🗑️ Removed

- The commands `Get-MipSdkEula` and `Invoke-MipSdkEula` have been removed in connection with the change in the
  `AcceptEula` parameter behavior.

## [25.1.50] 2025-06-06

### ➕ Added

- If [telemetry](./commands/en-US/about_Telemetry.md) is enabled, the use of any MilestonePSTools command will be
  reported to Azure Application Insights once per PowerShell session. The name of the command used, and the name of the
  parameter set will be reported. Specific parameter names, values, results, or errors are _not included_ in any
  telemetry data. See [about_Telemetry](./commands/en-US/about_Telemetry.md) to learn more about telemetry, how to
  enable local logging of telemetry data, or how to disable telemetry in your environment.

### 🐛 Fixed

- Fixed an issue with the `Get-VideoDeviceStatistics` command where an error would be thrown if MilestonePSTools was not
  installed into one of the default paths where PowerShell looks to automatically find and import modules.
- Fixed an issue where `Get-SequenceData` did not work if the device ID in the `Path` parameter was not provided in
  lower-case. The value of `Path` is now automatically passed to `VideoOS.Platform.Configuration.Instance.GetItemsBySearch`
  in lower-case.

### 🔄 Changed

- Updated ~54 commands to either add, or improve argument completers and transformation attributes. These are PowerShell
  features that allow you to tab through recording server names or press ++control+space++ after typing
  `Get-VmsRecordingServer -Name`. Interactive users will now find completions for more parameters, on more commands,
  with more consistency.

### 🗑️ Removed

- Removed `Get-AlarmDefinition` and added the name as an alias to `Get-VmsAlarmDefinition`.

## [25.1.39] 2025-05-23

### ⚠️ Breaking Changes

- The `Invoke-LicenseActivation` command has been removed, and added as an alias to the command `Invoke-VmsLicenseActivation`.
  This will only be a breaking change for you if you relied on the `[VideoOS.Platform.ConfigurationItems.LicenseInformation]`
  output previously returned by `Invoke-VmsLicenseActivation`. There is a new `-PassThru` switch parameter on the `Invoke-VmsLicenseActivation`
  command, and the optional output type is now `[VideoOS.Platform.ConfigurationItems.LicenseDetailChildItem]` which is
  more useful information and the same output you receive from `Get-VmsLicenseDetails`.
- The `Get-ValueDisplayName` command has been removed. This was used to resolve the "display value" for stream properties
  in an old version of the `Get-VmsCameraReport` command but is no longer used in the module at all, and should never have
  been made a public function. While we do not yet have telemetry to understand the popularity of individual commands in
  the module, it is not believed that this command would have been used in production.

### 🔄 Changed

- Updated dependencies
    - Autofac 8.2.1 &rarr; 8.3.0
    - Azure.Identity 1.12.0 &rarr; 1.14.0
    - Azure.Identity 1.12.0 &rarr; 1.14.0
    - Microsoft.Extensions.Configuration 9.0.3 &rarr; 9.0.5
    - Microsoft.Extensions.Configuration.Binder 9.0.3 &rarr; 9.0.5
    - Microsoft.Extensions.Configuration.EnvironmentVariables 9.0.3 &rarr; 9.0.5
    - Microsoft.Extensions.Configuration.Json 9.0.3 &rarr; 9.0.5
    - Microsoft.Identity.Client 4.70.0 &rarr; 4.72.1
    - Microsoft.IdentityModel.JsonWebTokens 7.6.3 &rarr; 8.10.0
    - MilestoneSystems.VideoOS.Platform 25.1.2 &rarr; 25.1.3
    - MilestoneSystems.VideoOS.Platform.SDK 25.1.2 &rarr; 25.1.3
    - System.IdentityModel.Tokens.Jwt 7.6.3 &rarr; 8.10.0
    - System.Text.Json 8.0.5 &rarr; 9.0.5
- Added argument completer for `Codec` parameter on `Start-Export` cmdlet.
- Updated the default formatter so all six device types appear the same
  in the terminal when output from commands like `Get-VmsCamera` or `Get-VmsDevice` aren't
  saved to a variable or manually formatted with a `Format-*` command.
- The following commands have been renamed to include the "Vms" prefix, and the un-prefixed command names are now aliases
  on the "Vms" version of the commands. Other than receiving a deprecation warning when using the old command names, these
  changes should not break existing scripts.
    - `Get-LicenseDetails` &rarr; `Get-VmsLicenseDetails`
    - `Get-LicensedProducts` &rarr; `Get-VmsLicensedProducts`
    - `Get-LicenseInfo` &rarr; `Get-VmsLicenseInfo`
    - `Get-LicenseOverview` &rarr; `Get-VmsLicenseOverview`
- A view has been defined for the default output from the `Get-GenericEventDataSource` command.
- Found and removed some unused variables, and fixed parameter name cases in the following commands:
    - `Import-VmsRole`
    - `Export-VmsRule`
    - `Set-VmsBasicUser`
    - `Set-VmsHardwareDriver`
    - `Get-VmsOpenIdConfig`

### 🐛 Fixed

- Fixed an issue with unhelpful error messages and unexpected behavior when using `Get-VmsDevice` or related commands
  with invalid Ids or Paths.
- Fixed an error with validation errors when importing a CSV file using `Import-VmsHardware`.
- The `Remove-GenericEvent` command has an `Id` parameter, but it threw an error unless a value like `GenericEvent[]`
  was supplied. The `Id` parameter now expects a `[Guid]` and `-WhatIf` support has been added.
- The `Get-HardwareSetting` command returned read-only properties when using the `-IncludeReadWriteOnly` switch parameter.
  This has been resolved and the command now returns a result ~32% faster.
- Calling `New-VmsLoginProvider` without a value for `-Scopes` did not actually create an external login provider
  because the call to `LoginProviderFolder.AddLoginProvider(...)` returns `$null` when the scopes argument is `$null`.
  This has been fixed by making an empty array the default value for `-Scopes`.
- Fixed `SmartMap` parameter on `New-VmsAlarmDefinition` and `Set-VmsAlarmDefinition`.

### ➕ Added

- The new commands `Get-VmsDeviceGeneralSetting`, and `Set-VmsDeviceGeneralSetting`, will deprecate all the
  device-specific commands like `Get-MicrophoneSetting` and `Set-SpeakerSetting` for accessing and modifying
  _general settings_. The four new commands reduce duplication of code by replacing 12 individual commands for the purpose
  of working with general, and stream settings, and include aliases
  like `Get-VmsMicrophoneGeneralSetting` and `Set-VmsMicrophoneStreamSetting` for each device type found under a
  `Hardware` object. The camera-specific `Get-VmsCameraStream` and `Set-VmsCameraStream` will remain available as they
  uniquely wrap configuration of both the streams themselves, and how the VMS _uses_ the streams (which stream is recorded,
  and which is for live only for example).

### 🛑 Deprecated

- The following commands are now deprecated in favor of `Get-VmsDeviceGeneralSetting` and `Set-VmsDeviceGeneralSetting` for
  changing general settings, and `Get-VmsDeviceStreamSetting` and `Set-VmsDeviceStreamSetting` for changing stream settings
  for all device types.
    - `Get-CameraSetting`
    - `Set-CameraSetting`
    - `Get-InputSetting`
    - `Set-InputSetting`
    - `Get-MetadataSetting`
    - `Set-MetadataSetting`
    - `Get-MicrophoneSetting`
    - `Set-MicrophoneSetting`
    - `Get-OutputSetting`
    - `Set-OutputSetting`
    - `Get-SpeakerSetting`
    - `Set-SpeakerSetting`
    - `Get-VmsCameraGeneralSetting`
    - `Set-VmsCameraGeneralSetting`

## [25.1.3] 2025-04-16

### ⚠️ Breaking Changes

- Removed the following aliases due to naming conflicts with other modules: `Add-User`, `Get-Role`, `Get-User`, `Remove-User`, `Get-Metadata`. See [Discussion 171](https://github.com/MilestoneSystemsInc/PowerShellSamples/discussions/171).

### 🔄 Changed

- Updated MIP SDK package references from 24.2 to 25.1.
- Updated numerous additional package references.
- Replaced hard-coded timeout values for oauth-based login sessions with references to configurable timeout values in `[MilestonePSTools.Connection.ChannelSettings+Timeouts]`.

### 🐛 Fixed

- Improved tab completion for the new `Get-VmsAlarmDefinition` command after discovering the valid values for `EventTypeGroup`
  are populated after calling the `ValidateItem()` method.

## [24.2.12] 2025-01-29

### ➕ Added

- New commands for creating and managing alarm definitions: `New-VmsAlarmDefinition`, `Get-VmsAlarmDefinition`, `Set-VmsAlarmDefinition` and `Remove-VmsAlarmDefinition`.

## [24.2.1] 2024-11-09

### ➕ Added

- Added commands for creating, getting, and removing `TrustedIssuer` records to support the use of external identity
  providers for single sign-on to a Milestone Federated Architecture (MFA) hierarchy.

### 🐛 Fixed

- Fixed [issue #155](https://github.com/MilestoneSystemsInc/PowerShellSamples/issues/155) where the `-LocalTimeStamp`
  switch on the `Get-Snapshot` cmdlet was ineffective and filenames contained the UTC time instead.

## [24.1.30] 2024-10-10

### 🐛 Fixed

- Fixed an issue with `-IncludeChildSites` introduced around the 23.3.2 release in February 2024 where we incorrectly
  called the `VideoOS.Platform.SDK.Environment.AddServer()` method with the `VideoOS.Platform.Login.LoginSettings` of
  the current site instead of using the URI of the child site. This led to a `ServerNotFoundMIPException` error when
  logging in to a parent site in a Milestone Federated Hierarchy using `Connect-Vms` or `Connect-ManagementServer` with
  the `-IncludeChildSites` switch.

## [24.1.27] 2024-09-26

### ➕ Added

- Added a set of commands for creating, updating, and removing live and recorded video restrictions. The associated
  commands can be listed using `Get-Command -Noun VmsRestricted*`.

### 🔄 Changed

- `Import-VmsHardware` and `Export-VmsHardware` will now always use the comma "," character as the separator when
  exporting to, or importing from a CSV file by default. This can be overridden using the `-Delimiter` parameter on
  these functions.

## [24.1.9] 2024-08-21

### 🔄 Changed

- The `Export-VmsHardware` and `Import-VmsHardware` cmdlets have been rewritten to support a cleaner CSV file format, in
  addition to supporting the `.xlsx` file extension in a much more detailed format. The same commands are used for both
  file formats and the processing will be different based on the file extension. When importing from either format, you
  can now provide an unlimited number of credentials to try during import, and you can add the `-UpdateExisting` switch
  to indicate that any hardware that has already been added, should be updated based on the settings in the incoming
  file.

## [24.1.6] 2024-08-02

### ➕ Added

- `Get-VmsDevice` and `Set-VmsDevice` is a generic form of the `Get-VmsCamera`, `Get-VmsMicrophone`, and similar
  commands. When you want to modify all child devices of one or more `Hardware` objects, for example when performing
  bulk renaming, the `Get-VmsDevice` cmdlet reduces duplicate code since you would previously need to have up to 6
  copies of the code for `Get-Vms<device type>` to cover changes to cameras, microphones, speakers, metadata, inputs,
  and outputs.
- `Get-VmsParentItem` makes it easier to retrieve the parent item for any object with a Configuration API
  `ParentItemPath` or `ParentPath` property. If a strongly-typed class for the parent item does not exist - the
  generic coPathNotFoundnfiguration item will be returned instead.
- A collection of 10 LPR commands are now available for reading, updating, deleting, and importing LPR match lists,
  and match list entries, as well as searching for LPR detection event records. All LPR commands have a noun beginning
  with `VmsLpr`, so you can use `Get-Command -Noun VmsLpr*` to get a list of them.

## [24.1.5] 2024-07-01

### 🐛 Fixed

- The previous version of MilestonePSTools was published with a default setting enabling the use of the API Gateway REST
  API when available. This resulted in at least one error like `Unknown resource: evidenceLockProfiles` when using
  Get-VmsRole. This option should be considered experimental for MilestonePSTools until further notice. A warning is now
  displayed on import if you have this option enabled in your environment. The warning provides the commands needed to
  disable it.

### ➕ Added

- `Get-Vms*` and `Set-Vms*` commands have been added for all device types including **Cameras**, **Microphones**,
  **Speakers**, **Metadata**, **Inputs**, and **Outputs**. The original `Get-<devicetype>` commands are now aliases to
  the new `Get-Vms<devicetype>` commands.

### 🔄 Changed

- Updated the `MilestoneSystems.VideoOS.Platform*` MIP SDK references to 2024 R1 (v24.1.1) which introduces .NET support
  for some new Management Client > Tools > Options features we can expose in new PowerShell commands in the future.

## [23.3.51] 2024-06-21

### 🔄 Changed

- Telemetry is now enabled and sent to Milestone through Azure Application Insights by default. Documentation, including
  instructions for disabling telemetry, can be found in the [about_Telemetry](./commands/en-US/about_Telemetry.md) topic.

### ➕ Added

- `Get-VmsMetadataLiveRecord` and `Get-VmsMetadataRecord` are now available for retrieving live, and recorded metadata
  respectively. Metadata is typically received and stored in the form of an XML document, and due to the wide variety of
  data you can find in a metadata stream, it is up to the user to parse the data and extract the information you need.
  We will add more examples over time to give you some more ideas for how to work with metadata.

## [23.3.42] 2024-06-10

### ➕ Added

- Support for Azure Application Insights telemetry has been introduced but is disabled by default in this release. In
  a future release it may be enabled by default.

## [23.3.33] 2024-06-10

### 🐛 Fixed

- `Get-VmsCameraReport` now correctly returns `$true` for the value of `PrivacyMaskEnabled` if a privacy mask is set.

### ➕ Added

- `Set-VmsDeviceStorage` for assigning **Camera**, **Microphone**, **Speaker**, and **Metadata** devices to different
  storage profiles on the same recording server. Assignments can be made by display name, so if you have many recording
  servers with the same storage profiles defined, you can do bulk device storage assignments on devices across multiple
  recorders with one command, as long as the **Destination** storage profile names match.
- `Set-VmsCameraMotion` and `Get-VmsCameraMotion` for simplified reading and updating of all **MotionDetection**
  properties, and a view format definition for the **MotionDetection** class to improve the appearance of these objects
  when rendered in the terminal.
- The module now takes advantage of the MIP SDK logging framework. You will find `MilestonePSTools<yyyyMMdd>.log` files
  in the MIPSDK folder at `C:\ProgramData\Milestone\MIPSDK\`. Debug logging is enabled by default and this can be
  modified if needed by editing the `appsettings.json` file in the MilestonePSTools module `bin/` folder, or by setting
  the corresponding environment variable `env:MIP_ENVIRONMENTMANAGER__DEBUGLOGGINGENABLED` to `$false`.

### 🔄 Changed

- The **patch** portion of the module version is now dynamically determined based on the "git commit height". For
  example, if there have been 10 commits to the main branch since the last change to the "major" or "minor" version, the
  git commit height would be "10". If the `Major.Minor` is 23.3, then the full module version would then be 23.3.10.

## [23.3.4] 2024-05-28

### 🐛 Fixed

- Fixes an issue where decoding H.265 video fails on systems without support for hardware accelerated HEVC decoding. This
  resulted in a misleading error from `Start-Export` like "No video or audio in the selected time period". It also resulted
  in a failure to retrieve live or recorded snapshots using `Get-Snapshot`.

### 🔄 Changed

- Updated project package references to remediate [CVE-2024-21319](https://github.com/advisories/GHSA-59j7-ghrg-fj52) related to transitive dependencies from Microsoft.

## [23.3.3] 2024-05-18

### 🔄 Changed

- Updated `VideoOS.Platform.SDK` reference from 23.3.1 to 23.3.2.
- Removed unnecessary pre-check for the presence of recordings between the start/end timestamps in `Start-Export`.

## [23.3.2] 2024-02-22

### ➕ Added

- `Get-VmsIServiceRegistrationService` has been added to offer easy access to the ServiceRegistrationService on the management server.
- The [installation docs](./help/compatibility.md) now include a compatibility table showing the most recent MilestonePSTools versions that should be compatible with different XProtect VMS releases, along with an indication of which combinations are supported. Generally speaking, as long as the XProtect version you connect to is not discontinued according to the official product lifecycle page, the latest MilestonePSTools release is supported for use with that VMS version.
- The [Command index page](./commands/en-US/index.md) now includes a note with information about how to access `command-history.json`. This is the raw data used to build the command index table.

### 🐛 Fixed

- Fixed an issue where, when using PowerShell ISE, you may have seen the error "Cannot validate argument on parameter 'ShowDialog'. An interactive PowerShell session is required."
- `Export-VmsRole` will now work on VMS versions without support for external login providers. Previously, the command attempted to retrieve the login provider claims assigned to a role, if any, resulting in an error when the VMS version did not support the feature.
- `Import-VmsRole` will now create new Basic User identities during an import if a basic user with the same name does not exist yet. Each new basic user created will be disabled by default, and will have a strong random 30-character password containing alphanumeric and special characters. There is no way to know the default passwords assigned to basic users created during an import - it will be up to the administrator to decide if and when to enable these accounts. At that time, they will need to reset the passwords
- Fixed an issue with the use of single sign-on (SSO) using an external login provider with `Connect-Vms -ShowDialog` and `Connect-VmsManagementServer -ShowDialog`.

## [23.3.1] 2023-11-17

### ➕ Added

- New `[MilestonePSTools.RequiresInteractiveSession()]` attribute for commands and parameters that should only be used
  in an interactive PowerShell session. Using the `Select-Camera`, or `Select-VideoOSItem` commands, or the `-ShowDialog` parameters on `Connect-Vms` and `Connect-ManagementServer` will now throw an exception when used in a non-interactive
  PowerShell session or a PSSession rather than risk blocking the shell indefinitely.

### 🐛 Fixed

- When passing more than one value for `-Path` to `Get-VmsDeviceGroup`, the values were not handled correctly.
- The `Clear-VmsCache` command was incorrectly decorated with `[RequiresVmsConnection()]` so running the command without
  a connection triggered a login flow. It no longer triggers a login and is effectively a no-op when used without an active connection.
- Fix an issue where an error could occur when changing the password on remote hardware using `Set-VmsHardware -UpdateRemoteHardware` without reporting it to the user.
- Fixed a null-reference exception issue where `Send-UserDefinedEvent` would fail if you attempted to trigger a user-defined event that was created in the same PowerShell session without first calling `Clear-VmsCache`.

### 🔄 Changed

- Removed a dependency on the independent `MipSdkRedist` module. Going forward, the `MilestonePSTools` module will include all required MIP SDK assemblies. This will simplify the maintenance of MilestonePSTools as new versions are released, and also the process of installing the module in an offline VMS environment.
- Updated a number of docs to remove the use of any aliases including `?`, `%`, and MilestonePSTools aliases for commands that have been renamed.
- Added tests for PowerShell code blocks and inline code in the docs, and `.PS1` files included in the docs site. This should help to eliminate the possibility of sharing examples with syntax errors or with aliases and other code quality issues.

## [23.2.3] 2023-10-11

### ➕ Added

- New `Move-VmsHardware` command can be used to move hardware between recording servers on the same management server.
- Change passwords on supported hardware devices with `Set-VmsHardware` and the `Password` parameter by including the `-UpdateRemoteHardware` switch.
- Manage hardware based events like edge motion detection and edge analytic events with `Get-VmsDeviceEvent` and `Set-VmsDeviceEvent`.
- New custom ValidateArgumentsAttribute `[ValidateTimeSpanRangeAttribute]` which can be used to constrain a `[timespan]`
  parameter like `[ValidateTimeSpanRange('00:01:00', '365000.00:00:00')]` which is now how the `-Retention` parameters
  are validated now in `Add-VmsStorage` and `Add-VmsArchiveStorage`.

### 🐛 Fixed

- When exporting in AVI format with `Start-Export` the warning message "No error occurred!: DETAILED_ERROR_OK" was
  returned at the end. This was due to an unexpected `AVIExporter` behavior where the `AVIExporter.LastErrorString`
  property was set to this message after a successful export with the assumption that any value in LastErrorString
  indicated an error.
- When using Set-VmsRoleOverallSecurity without the Role parameter, the Role was unable to be retrieved using the configuration API path of the Role from the permissions hashtable.

### 🔄 Changed

- When auto-connected to a management server as a result of running a command requiring a VMS connection, a new connection
  profile will not be saved automatically if the login dialog appears and you logon successfully. Either explicitly use
  `Connect-Vms`, or use `Save-VmsConnectionProfile` after logging in.
- Minor improvement to error messages for the "requirement" custom attributes. The error message now includes "Source: FunctionName"
  so that it's always clear which function called `Assert-VmsRequirementsMet` and failed an assertion.
- Changed the casing for the `VmsWebHook` commands by replacing all instances of "WebHook" with "Webhook".
- The Codec parameter on the `Start-Export` command now has an argument-completer so you can tab-complete the available
  codecs. If the `AVIExporter` client decides to use a different codec because the specified codec couldn't be used for
  some reason -- incompatible resolution for example -- a warning will be emitted after a successful export to indicate
  that the codec used did not match the codec specified.
- The `Resolve-VmsDeviceGroupPath` command will now include a path prefix like "/CameraGroupFolder/" to indicate the
  device type associated with the group. This makes it possible to pipe a collection of paths to the `New-VmsDeviceGroup`
  and `Get-VmsDeviceGroup` commands without worrying about supplying the `-Type` parameter when working with multiple
  device types. These prefixes can be omitted using NoTypePrefix.
- Custom ValidateVms\* attributes applied to parameters will now automatically result in a description of each requirement
  in the Get-Help info for the associated parameter, just as RequiresVms\* attributes on commands will be described in
  the command description.

## [23.2.2] 2023-09-28

### ➕ Added

- New cmdlets for managing webhooks on VMS versions 2023 R1 and later: `New-VmsWebhook`, `Get-VmsWebhook`, `Set-VmsWebhook`, and `Remove-VmsWebhook`.
- New `Connect-Vms`, `Disconnect-Vms`, and related connection profile cmdlets `Get|Set|Remove-VmsConnectionProfile` which together introduce a new way of managing MilestonePSTools connections. When using `Connect-Vms` without parameters, or when using only the 'Name' parameter, the default, or named connection profile will be used to login to the associated VMS. Or, if no connection profile has been created yet, you will be prompted for credentials. Afterward, the login information will be persisted to disk using `Export-CliXml` which will encrypt the provided credentials using CurrentUser scope in your local appdata directory.When using MilestonePSTools with automation via scheduled tasks or other means of launching scripts on event/schedule, this greatly simplifies things by eliminating the need to figure out credential management every time.
- New custom attributes, and an "about" topic detailing how custom attributes are used in MilestonePSTools, and how to use them in 3rd party scripts.
- Commands are now decorated with "Requirement" attributes describing required versions, and features for example. These attributes are now used to update a "REQUIREMENTS" list at the bottom of the DESCRIPTION section of each command's Get-Help info and in the online docs.

### 🔄 Changed

- Improved performance of `Get-VmsRoleOverallSecurity` by up to 35% on systems with 1000 roles by avoiding redundant API calls and unnecessary enumeration of Roles. Also improved the speed of tab-completion of SecurityNamespace values. Previously it could take more than 10-20 seconds to populate the security namespace names during tab completion. Now it takes ~1 second even with 1000 roles.
- The login dialog displayed with `Connect-ManagementServer -ShowDialog` will now automatically update the "Allow only secure communication" checkbox based on the http/https URL scheme. New users of MilestonePSTools are _very often_ tripped up by the initial default value of "checked" which doesn't make sense when the URL starts with http.
- All commands requiring a VMS connection are now decorated with the RequiresVmsConnection attribute which will attempt to connect you to your VMS before failing.

### 🐛 Fixed

- Fixed an issue where calling `Get-VmsSite` without parameters returned multiple sites instead of the current site when logged into a Milestone Federated Hierarchy. This behavior was introduced by mistake in version 23.2.1.
- Fixed issues with the `[MilestonePSTools.RequiresVmsVersion('[,23.2]')]` attribute when used with a blank minimum or maximum range value.

### 🗑️ Removed

- Removed Google Analytics from the documentation site. A GitHub cookie remains, but you can choose to disable it at any time by clicking the "Change cookie settings" button in the footer.

## [23.2.1] 2023-08-16

### 🐛 Fixed

- `Get-VmsCameraReport` returned an error when a recording server existed in the
  site but had no cameras assigned.
- `Get-VmsCameraReport` could, in rare cases, return unexpected `-IncludeRecordingStats` results when the report is run at or very near to midnight.
- `Invoke-VmsLicenseActivation` failed due to a reference to a missing `$ms`
  ManagementServer variable.
- When using MilestonePSTools in an environment where the .NET Framework does not allow the use of TLS 1.2 or later by
  default, and when the Management Server is configured for encryption, and IIS / SChannel on the Management Server is
  hardened such that only TLS 1.2 and later can be used to negotiate secure connections, running `Connect-ManagementServer`
  with the `-SecureOnly` switch would result in a failure to login, and omitting `-SecureOnly` would result in a fallback
  to HTTP. Now, when the module is imported, TLS 1.2 and later are explicitly added as allowed protocols.

### 🔄 Changed

- Updated target MIP SDK version to 23.2.1.
- Improved error messaging for ValidateResultException errors on `Set-VmsCameraStream`.
- Introduced new VMS version and feature attributes used to decorate cmdlets and
  parameters, thereby simplifying version/feature checking and offering consistent
  messaging when a cmdlet or parameter requires a specific VMS server version or
  feature to use.
- `Get-Site` and `Select-Site` are renamed to `VmsSite` with an alias for the old names to prevent breaking changes.
- `Get-VmsToken` now accepts a couple different parameter types to allow you to easily
  get a copy of the current token for the site to which a resource belongs (camera, or recording server for example).
- `Get-VmsCameraStream` and `Set-VmsCameraStream` have been updated to support the new 2023 R2
  adaptive playback feature which allows the recording of a secondary stream. The updated
  module should work on both 2023 R2 as well as older versions without breaking changes. However,
  you will not be able to use `-RecordingTrack Secondary` on versions older than 2023 R2.

### ➕ Added

- New VmsFailoverGroup and VmsFailoverRecorder cmdlets for managing failover
  recording server groups, assigning failover recording servers to groups, or
  assigning hot-standby.
- Added failover related properties to `Set-VmsRecordingServer`.
- New `Get-VmsVideoOSItem` and `Find-VmsVideoOSItem` cmdlets for working with items returned
  by `VideoOS.Platform.Configuration.Instance.GetItem` and `GetItems` methods. This should provide a better experience than
  the older `Get-PlatformItem` as they will "flatten" the item hierarchy for you, making it much simpler to generate a list
  of items.
- New `Test-VmsLicensedFeature`, `Assert-VmsLicensedFeature`, and `Assert-VmsRequirementsMet`
  primary for internal use. They are public because they can be very useful when
  building out tools/scripts that you want to run on different customer systems
  without knowing ahead of time whether certain features are available. Documentation
  will follow later, especially on the `Assert-VmsRequirementsMet` cmdlet which will
  be used in combination with custom cmdlet and parameter attributes like `[ValidateVmsVersion()]`.

## [23.1.3] 2023-04-20

### ➕ Added

- New VmsRule cmdlets for working with Milestone VMS rules. Please see the cmdlet
  documentation for more information. A more detailed guide will be written in
  the near future to thoroughly detail what the process would look like to create
  new rules "from scratch" or copy complex rules to new sites. Due to the highly
  dynamic nature of rules and the wide range of required properties depending on
  the rule trigger, start-action(s), and stop-action(s), it is easiest to create
  the rule you want by hand, then export and inspect the rule's property keys
  and values.
  - New-VmsRule
  - Get-VmsRule
  - Set-VmsRule
  - Remove-VmsRule
  - Export-VmsRule
  - Import-VmsRule

### 🔄 Changed

- Minor updates to the [all-users](https://www.milestonepstools.com/installation/#install-for-all-users)
  and [current-user](https://www.milestonepstools.com/installation/#install-for-the-current-user)
  quick-install scripts. Now the all-users script will block until the module has
  finished installing.

### 🐛 Fixed

- When supplying a CSV file without a DriverNumber value, the
  `Import-VmsHardware` cmdlet threw an exception when processing the results of
  the `Start-VmsHardwareScan` due to a new property added to the hardware scan
  result.
- Removed references to the `Get-HardwareDriver` alias from the
  `Import-VmsHardware` cmdlet as it resulted in a nuisance deprecation warning.

## [23.1.2] 2023-04-07

### ➕ Added

- Suite of nine new smart client profile cmdlets with nouns starting with 'VmsClientProfile'.
  The new cmdlets simplify adding, removing, updating, re-prioritizing, exporting, and importing
  smart client profiles.
- New `Export-VmsRole` and `Import-VmsRole` cmdlets.
- Added default views for `LoginProvider`, `RegisteredClaim`, and `ClaimChildItem` types to
  improve the way those objects are displayed in the terminal.

### 🔄 Changed

- Included "Always" as an option for time profile parameters on `Set-VmsRole`.
- Improved error handling when an error occurs while changing password on hardware with `Set-VmsHardware`.
- The `Remove-VmsRoleClaim` cmdlet now includes optional `LoginProvider` and `ClaimValue` parameters so that you can
  easily remove claims only if ClaimProvider, ClaimName, and ClaimValue properties match. This is useful when a role
  has multiple claims defined with the same claim name and different values. And today, only one login provider may be
  configured at a time in the VMS, but in the future there may be support for multiple login providers.
- `New-VmsRole` now returns the new role whether the `-PassThru` switch is used or not. Previously the role
  was only returned when using the `-PassThru` switch because it costs an extra API call to return the
  new role after asking the server to create it. However, because we need to retrieve it from the server
  anyway, to handle a potential MIP SDK bug with the time profile properties, and because the `New` verb
  is typically expected to return an object, the behavior has been changed.
- `Get-VmsRole` will now return role objects with values for ClientProfile, RoleDefaultTimeProfile, and
  RoleClientLogOnTimeProfile. These were not included previously unless retrieving a role by ID, because
  the values are only filled when explicitly instantiating a new Role object. The MIP SDK does not provide
  these values when enumerating roles from `RoleFolder.Roles`.

### 🐛 Fixed

- Online help url for `New-VmsBasicUser` used to point to the help for `New-VmsLoginProvider`.
- `New-VmsRole` did not set the DefaultTimeProfile or ClientLogOnTimeProfile as expected
  due to a potential MIP SDK bug. Now, once the new role is created, the current time
  profiles are checked, and if they don't match the expected values, they are updated
  before returning the new role.

## [23.1.1] 2023-03-28

### ➕ Added

- New "VmsBasicUser" and "VmsBasicUserClaim" cmdlets for managing all aspects of basic users, including
  basic user entries created for users who have logged in using an external
  login provider.
- New "VmsLoginProvider" cmdlets for creating, reading, updating, and deleting
  external login providers.
- New "VmsRoleClaim" cmdlets for managing external login provider claims.
- `Get-VmsHardwarePassword` replaces `Get-HardwarePassword` but an alias is provided to prevent a breaking change.
- `Set-VmsHardware` adds support for changing state, name, address, credentials, description, and password for hardware.
  The `Set-HardwarePassword` cmdlet has been removed and is now aliased to `Set-VmsHardware` to prevent a breaking change.

### 🔄 Changed

- Updated target MIP SDK version to 23.1.1.
- Added `VideoOS.Platform.Configuration.Instance.ConfigurationApiManager.UseRestApiWhenAvailble = false;` prior to logging
  in to server because the API Gateway / REST API does not (yet) support the QueryItems method which is used in `Get-VmsCameraReport`,
  and `Get-VmsCamera` among other places.
- `Invoke-ServerConfigurator` can now be used without a "CertificateGroup" parameter and encryption will be enabled or
  disabled for all certificate groups or VMS components. A new "OverrideLocalManagementServer" switch was added which can
  be used when using a custom "AuthAddress" during registration directly on a management server.
  - Note that ServerConfigurator.exe does not currently support removal of this override, and that it is not possible to enable, or disable encryption _after_ using this
    override switch. If encryption is disabled, you will have to manually use the Server Configurator GUI to disable it from the "Register" tab, enable encryption, then
    change the override again afterward. This is due to a quirk in the logic of the
    server configurator which is intended to protect you from accidentally enabling
    encryption on a recording server node when it is not enabled on the management
    server node.

## [22.3.1] 2023-02-09

### ➕ Added

- Introduced `Set-VmsHardwareDriver` which can be used to perform a "hardware
  replacement" on XProtect VMS versions 2023 R1 and later. This is an exciting
  and long awaited capability that has been made available in the Configuration
  API.

### 🐛 Fixed

- Fixed issue #77 - error thrown by `Remove-VmsDeviceGroup` when used with `-Recurse` on 2019 or older.
- Fixed snapshot timeout issues in `Get-VmsCameraReport` by adding a `SnapshotTimeoutMS` parameter with a default value of 10 seconds.

### 🔄 Changed

- The previous code signing certificate has expired and a new one has been
  issued to Milestone Systems, Inc. with the subject 'CN="Milestone Systems, Inc.", OU=Custom Development Americas, O="Milestone Systems, Inc.", L=Lake Oswego, S=Oregon, C=US',
  issued by 'CN=SSL.com Root Certification Authority RSA, O=SSL Corporation, L=Houston, S=Texas, C=US'.
  In order to upgrade from a previous version, you will need to run `Install-Module MilestonePSTools -SkipPublisherCheck`.
- `Clear-VmsCache` will now also invoke `VideoOS.Platform.SDK.Environment.ReloadConfiguration`
  which will make it possible to access stream and status information for
  devices that have been added since the start of the PowerShell session.
- Improved `Get-VmsCameraStream` and `Set-VmsCameraStream` to minimize the
  number of times the configuration is saved server-side when changing multiple
  settings, and to reduce the risk that the state of the settings in a local
  stream reference don't match the updated state of the stream on the server.
- `Get-HardwareDriver` has been renamed to `Get-VmsHardwareDriver` and an alias
  for the old name has been added to prevent breaking changes.

### 🗑️ Removed

## [22.3.0] 2022-11-29

### Summary

This version introduces significantly improved cmdlets for managing device groups
and roles, making room for the removal (and aliasing) of many older cmdlets. In
addition to these changes, this module makes use of the 2022 R3 MIP SDK binaries.

Most parameters in the new cmdlets implement two very useful features for
interactive PowerShell use: argument completers, and argument transformers. The
completers make it possible to tab-complete or list-complete using CTRL+Space. For
example, try `Get-VmsRole -Name` then press TAB after ensuring there is a space
after "-Name". You should see a list of the names of your existing roles.

Combining these argument completers with argument transformers makes it possible
for a function that expects a "Role" object to receive a role "name" instead, and
then go retrieve the role object for you in the background and substitute the
string value you provided with the associated role object. For example, the
`Set-VmsRole` cmdlet expects a `Role` object, but you can do `Set-VmsRole -Role Administrators -Description "Foo"`
and it will work anyway.

Here is a quick summary of the cmdlet additions/removals. In almost all cases,
the cmdlets removed have replacement `*-Vms*` cmdlets and the new cmdlets are
aliasing the old cmdlet names with very few breaking changes in terms of
parameters.

### Cmdlet Changes

| Name                           | Status  | Comment                                 |
| ------------------------------ | ------- | --------------------------------------- |
| Get-VmsConnectionString        | Added   | Replaces Get-ConnectionString           |
| Set-VmsConnectionString        | Added   |                                         |
| Get-VmsDeviceGroup             | Added   | Replaces Get-DeviceGroup                |
| New-VmsDeviceGroup             | Added   | Replaces Add-DeviceGroup                |
| Remove-VmsDeviceGroup          | Added   | Replaces Remove-DeviceGroup             |
| Set-VmsDeviceGroup             | Added   |                                         |
| Add-VmsDeviceGroupMember       | Added   | Replaces Add-DeviceGroupMember          |
| Get-VmsDeviceGroupMember       | Added   |                                         |
| Remove-VmsDeviceGroupMember    | Added   |                                         |
| Join-VmsDeviceGroupPath        | Added   |                                         |
| Split-VmsDeviceGroupPath       | Added   |                                         |
| Get-VmsHardware                | Added   | Replaces Get-Hardware                   |
| Get-VmsRecordingServer         | Added   | Replaces Get-RecordingServer            |
| Set-VmsRecordingServer         | Added   |                                         |
| Get-VmsRole                    | Added   | Replaces Get-Role                       |
| New-VmsRole                    | Added   | Replaces Add-Role                       |
| Remove-VmsRole                 | Added   | Replaces Remove-Role                    |
| Set-VmsRole                    | Added   |                                         |
| Add-VmsRoleMember              | Added   | Replaces Add-User                       |
| Get-VmsRoleMember              | Added   | Replaces Get-User                       |
| Remove-VmsRoleMember           | Added   | Replaces Remove-User                    |
| Get-VmsRoleOverallSecurity     | Added   |                                         |
| Set-VmsRoleOverallSecurity     | Added   |                                         |
| Get-VmsToken                   | Added   | Replaces Get-Token                      |
| Get-CameraReport               | Removed |                                         |
| Get-ConnectionString           | Removed | Now aliased to Get-VmsConnectionString  |
| Add-DeviceGroup                | Removed | Now aliased to New-VmsDeviceGroup       |
| Get-DeviceGroup                | Removed | Now aliased to Get-VmsDeviceGroup       |
| Remove-DeviceGroup             | Removed | Now aliased to Remove-VmsDeviceGroup    |
| Add-DeviceGroupMember          | Removed | Now aliased to Add-VmsDeviceGroupMember |
| Add-Hardware                   | Removed |                                         |
| Get-Hardware                   | Removed | Now aliased to Get-VmsHardware          |
| Export-HardwareCsv             | Removed |                                         |
| Import-HardwareCsv             | Removed |                                         |
| Remove-MobileServerCertificate | Removed |                                         |
| Set-MobileServerCertificate    | Removed |                                         |
| Get-RecordingServer            | Removed | Now aliased to Get-VmsRecordingServer   |
| Add-Role                       | Removed | Now aliased to New-VmsRole              |
| Get-Role                       | Removed | Now aliased to Get-VmsRole              |
| Remove-Role                    | Removed | Now aliased to Remove-VmsRole           |
| Get-Token                      | Removed | Now aliased to Get-VmsToken             |
| Add-User                       | Removed | Now aliased to Add-VmsRoleMember        |
| Get-User                       | Removed | Now aliased to Get-VmsRoleMember        |
| Remove-User                    | Removed | Now aliased to Remove-VmsRoleMember     |

### ➕ Added

- New `VmsDeviceGroup*` cmdlets for adding, removing, and changing device groups and device group members for all device types.
- New `VmsRole*` cmdlets for getting, adding, setting, and removing roles, role members, and overall security permissions.
- New `Get-VmsRecordingServer` and `Set-VmsRecordingServer` cmdlets.

### 🐛 Fixed

- `Import-VmsHardware` did not apply hardware and device names after adding hardware which uses a DNS name instead of an IP or URI format.
- `Get-VmsLog` uses `Write-Progress` to provide a progress bar, but did not "complete" the progress when finished, leaving a progress bar up until the script completes.
- `Connect-ManagementServer -ShowDialog` opens a login dialog but that dialog did not always have keyboard focus. Now, hopefully, the dialog always shows on top of the shell, and has keyboard focus.
- `Import-VmsLicense` failed due to missing `$ms = Get-VmsManagementServer`. So unless you had already done that in your own global or local scope, this cmdlet did not work.
- `Set-VmsCameraStream` incorrectly attempted to save changes to stream settings even if the key for the setting didn't exist on the camera. This did not result in an error, but did cause an unnecessary API call and a confusing verbose message.
- After removing hardware, the removed hardware could still be returned by Get-Hardware. Now the HardwareFolder cache is cleared to prevent this.
- Fixed a stale cache issue when adding or removing hardware causing new hardware to be undiscoverable and removed hardware to still be present in the cache.
- Calling `Get-VmsStorage` without parameters threw an error instead of returning all storages from all recording servers.
- `Get-VmsCamera` returned cameras that were enabled even though their parent hardware device was disabled. Now if you want enabled cameras, you only get cameras that would normally show up as enabled in Management Client.
- `Get-PlaybackInfo` threw a null reference exception when called with a camera that is either disabled or not a member of a camera group. Now a more useful error is displayed.
- Fixed missing "Online Help" links so that `Get-Help command-name -Online` should work for all cmdlets in the module again.

### 🔄 Changed

- Updated to 2022 R3 MIP SDK libraries.
- Added Shortcut and ShortName properties to `Get-VmsCameraReport`.
- Application icon for `Connect-ManagementServer -ShowDialog` user interface replaced with plain Milestone diamond logo without the "milestone" wordmark. The title bar is too small an area for an icon with a word in it, and it didn't render well.
- `Get-ConnectionString` has been renamed to `Get-VmsConnectionString` and it now supports 2022 R3 where the connection strings are now all placed in a new registry key together.
- `Set-VmsCameraStream` will now apply changes to all streams before calling `Save()`. This reduces the number of API calls made while saving changes, and makes it easier to fix rare validation issues where you have to change the value of a stream property across more than one stream at the same time.

### 🗑️ Removed

- `Remove-MobileServerCertificate` and `Set-MobileServerCertificate` - use `Set-XProtectCertificate`, or if your Milestone version is not old enough to use the server configurator CLI, use an older version of MilestonePSTools.
- `Export-HardwareCsv` and `Import-HardwareCsv` - use `Export-VmsHardware` or alternative import/export samples to be made available online.
- `Get-CameraReport` - use `Get-VmsCameraReport` instead.

## [22.2.0] 2022-07-22

### 🐛 Fixed

- Typo in documentation for `Import-VmsHardware`.
- `Get-Snapshot -Live` sometimes returned very old, definitely not live, images. Fixed by setting `SendInitialImage` to `false`.
- `Add-DeviceGroup` threw an exception when attempting to create the same group twice in the same session, or when creating a subgroup after creating the parent group. Now the `ClearChildrenCache()` method is called on the parent device group to ensure the cache is updated with newly created groups.

### 🔄 Changed

- Removed default description "Added using PowerShell at [date]" applied to devices added with `Import-VmsHardware`.
- `Export-VmsHardware` now overwrites the CSV at `Path` if it exists already, and the `Append` switch has been added.
- Added `Culture` switch to the `Get-VmsLog` cmdlet to make it possible to request log entries in a specific language.
- Improved error messages for licensing cmdlets when they are used against a VMS version released before server-side support of those commands.
- Removed noisy verbose logging for cmdlets associated with snapshot and export retrieval.
- Added `MotionThreshold` column to `Get-VmsCameraReport` output, and the `ManualSensitivity` value is now reported the same as the Management Client UI - the internal value from configuration API is now divided by 3.

## [22.1.0] 2022-04-19

### 🐛 Fixed

- Fixed an issue with `Import-VmsHardware` where cameras on one recording server could not be
  imported into another recording server.
- Fixed an issue with `Import-VmsHardware` where cameras were not enabled or renamed after importing.
- Fixed an uncommon issue with `Get-VmsCameraReport` where the error `Cannot index into a null array` is returned
  when at least one camera lacks any stream settings in the Settings tab for the camera in Smart Client.

### ➕ Added

- New cmdlets for getting, setting, and clearing site information properties like company name, address, and contact information.
  - Get-VmsSiteInfo
  - Set-VmsSiteInfo
  - Clear-VmsSiteInfo

### 🔄 Changed

- Changed RequiredModules entry for MipSdkRedist in module manifest from 21.2.0 to 22.1.0.

## [21.2.7] 2022-02-23

### 🐛 Fixed

- Fixed an issue with `Get-RecorderStatusService2` throwing a null reference exception when attempting to get a status service instance for a Recording Server when that recording server, for some reason, has a null FQID.ServerId.Uri value. Now a regular error should be returned via `Write-Error`.
- Fixed an error in `Get-VmsCameraReport` where cameras without multi-stream support would result in errors being passed to the pipeline.
- Fixed an error in `Get-VmsCameraReport` where recording servers without cameras could cause an error when using the `-IncludeRetentionInfo` switch.

### ➕ Added

- Several cmdlets for working with ViewGroup and View objects, including cmdlets for copying, exporting, and importing ViewGroups, and modifying permissions.
  - Clear-VmsView
  - Copy-VmsView
  - Copy-VmsViewGroup
  - Export-VmsViewGroup
  - Get-VmsView
  - Get-VmsViewGroup
  - Get-VmsViewGroupAcl
  - Import-VmsViewGroup
  - New-VmsView
  - New-VmsViewGroup
  - Remove-VmsView
  - Remove-VmsViewGroup
  - Set-VmsView
  - Set-VmsViewGroup
  - Set-VmsViewGroupAcl

### 🔄 Changed

- Replaced all internal references to `Get-ManagementServer` with `Get-VmsManagementServer` to eliminate deprecation warning messages when running built-in cmdlets.

## [21.2.6] 2022-02-08

### ➕ Added

- `Clear-VmsCache` can be used to clear the child items from the cached
  ManagementServer object (see the caching reference in changes below). This will
  also dispose of cached WCF proxy clients generated by `Get-IServerCommandService` and
  `Get-IConfigurationService`. Previously, you would use `Get-Site | Select-Site`
  or reconnect to the Management Server to clear those cached proxy clients.

### 🐛 Fixed

- Fixed an issue where functions were not correctly exported and made available to users of some OS's like Server 2012 R2.
- `ConvertTo-GisPoint` was, in some cases, outputing "POINT (0 0)" instead of the given coordinates.
  This behavior is fixed, and the cmdlet has been improved with support for altitude/elevation.
- `Start-VmsHardwareScan` produced an empty `[VmsHardwareScanResult]` even when the scan returned no entries. Now, when the request for a scan returns an error, no results will be returned and a `Write-Error` will show the error returned by the VMS.

### 🔄 Changed

- Updated `Get-Log`
  - Renamed to `Get-VmsLog` and added alias for old name, `Get-Log`
  - Implemented a "windowing" strategy to improve performance when reading
      logs for a broad time period. In testing, a 24-hour audit log request
      completed three times faster using the new cmdlet.
- **Caching:** Added caching of the current site's ManagementServer configuration api object.
  All cmdlets that previously instantiated a new ManagementServer object when needed
  have been updated to use the cached reference, which in turn caches child items
  when they are accessed through it. This dramatically improves the performance when
  multiple enumerates of configuration items are performed during the same PowerShell
  session. For example, accessing general settings for all cameras on a test system
  took 29 seconds the first time. Subsequent requests took 0.15 seconds.

## [21.2.5] 2022-01-27

### ➕ Added

- `Get-VmsDeviceStatus` offers very fast streaming device status information
  through the use of the MIP SDK RecorderStatusService2 API and the
  GetCurrentDeviceStatus method.

## [21.2.4] 2022-01-20

### 🐛 Fixed

- `Get-VmsCameraGeneralSetting` was returning an unexpected `$null` value that
  was missed during a refactoring.

## [21.2.3] 2022-01-20

### ➕ Added

- Spanish language translations.
- `Get-VmsCamera` replaced `Get-Camera` and adds the ability to search by name.
- `Set-VmsCamera` adds an easy method of changing all properties directly
  attached to camera objects.
- `Get-VmsCameraGeneralSetting` adds a quick and easy way to access general
  settings and defaults to "display values" instead of "raw values".
- `Set-VmsCameraGeneralSetting` adds an easy way to change several general
  settings at once.
- `Get-VmsCameraStream` adds a much easier way to retrieve stream properties
  including how they're used (live, recording), and the associated settings
  like FPS, Resolution, and Codec.
- `Set-VmsCameraStream` is a simple cmdlet for adding new streams and
  configuring properties of streams like FPS, Resolution, Codec, and
  multi-stream properties like LiveMode and stream display name.

### 🔄 Changed

- MilestonePSTools is now signed with the Milestone code signing certificate.
- `Get-Camera` is now aliased to `Get-VmsCamera`.

### 🛑 Deprecated

- `Get-Camera` is deprecated in favor of `Get-VmsCamera`.
- `Get-CameraSetting` is deprecated in favor of `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream`.
- `Set-CameraSetting` is deprecated in favor of `Set-VmsCameraGeneralSetting` and `Set-VmsCameraStream`.
- `Get-Stream` is deprecated in favor of `Get-VmsCameraStream`.
- `Set-Stream` is deprecated in favor of `Set-VmsCameraStream`.

## [21.2.2] 2021-11-04

### ➕ Added

- `New-VmsFailoverGroup`, `Get-VmsFailoverGroup`, and `Remove-VmsFailoverGroup`
  which is supported for XProtect Expert and XProtect Corporate 2021 R2 and
  newer.

### 🐛 Fixed

- `Get-VmsCameraReport` failed with the error `Exception calling "FillChildren" with "2" argument(s): "VMS64001: The feature is not licensed."`
  on XProtect Essential+ due to an attempt to use the "FillChildren" method to
  pre-populate the configuration hierarchy with a variety of ItemType's
  including PrivacyProtection and PrivacyProtectionFolder items which are only
  present from XProtect Express+ and above.

## [21.2.1] 2021-10-28

### 🐛 Fixed

- `Get-VmsCameraReport` failed to produce a report if communication with the
  recording server(s) failed. Now the communication error will be returned and
  the report will be produced with some missing information.
- `Get-RecorderStatusService2` always used the `WebServerUri` or "local web
  server address" to try to reach the recording server status service. Now the
  Milestone internal FQID will be looked up in
  `[VideoOS.Platform.Configuration]::Instance`, and the FQID.ServerId.Uri value
  will be used to instantiate the
  `[VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2]` client. This
  should ensure that the status client can be used while on a local network or
  when connecting over the internet, or through a NAT/PAT firewall.

## [21.2.0] 2021-10-27

### ➕ Added

- Support for `Get-Help -Online`
- Get-VmsCameraReport as a faster, more reliable replacement for Get-CameraReport.
- License management functions have been added which make use of Configuration API features introduced in 2020 R2.
  - Import-VmsLicense for importing initial, or manually-activated license files downloaded from My Milestone.
  - Export-VmsLicenseRequest for exporting license request files for manual activation on My Milestone.
  - Set-VmsLicense for changing the software license code by importing a different license file.
  - Invoke-VmsLicenseActivation for initiating an online activation with the option to enable auto-activation.
- Start-VmsHardwareScan can be used to perform express, or manual hardware scans to discover cameras and which drivers to use with them.
- Add-VmsHardware as a replacement for the original Add-Hardware cmdlet.
- Import-VmsHardware as a replacement for Import-HardwareCsv (shallow support of device settings only)
- Export-VmsHardware as a replacement for Export-HardwareCsv (shallow support of device settings only)
- Wait-VmsTask is useful for monitoring long-running operations. You can use it with most Configuration API method calls and it will return when the server-side task completes.

### 🔄 Changed

- Updated MipSdkRedist dependency to [MipSdkredist 21.2.0](https://www.powershellgallery.com/packages/MipSdkRedist/) based on MIP SDK 2021 R2.
- Improved Get-PlaybackInfo performance by switching from RawDataSource to SequenceDataSource.
- Changed Find-XProtectDevice -ShowDialog UI to filter out all non-string property names in the advanced section.
- Updated Set-CertKeyPermission private function to improve reliability and support ECC certificates. This function is used with Set-XProtectCertificate.
- Added documentation for previously undocumented commands.
- Experimental: Introduced the concept of "proxy client pools" so that two of each proxy client type can be created instead of one. This may help when using runspaces for parallelization but testing has not proven this out yet.
  - To try using more than one proxy client for Configuration API and other WCF channels, add the environment variable MILESTONEPSTOOLS_PROXYCOUNT with an integer value.
- Added ActivationAutomatic column to LicenseInformation formatter - it's useful information to see in the output of Invoke-VmsLicenseActivation, Import-VmsLicense, and Set-VmsLicense.
- Updated Remove-Hardware to support -WhatIf, and set ConfirmImpact to "High".
  The -Force switch no longer exists as we are relying on the more idiomatic
  ConfirmImpact feature to stand in the way of potential accidental usage. This
  is a breaking change considering the -Force switch will now cause an error,
  and we no longer accept the Hardware object by ID. To remove hardware in bulk
  such as you might do in a test environment, you can add `-Confirm:$false` and
  you should not be required to acknowledge any removal operations.

### 🐛 Fixed

- Added error handling for Configuration API cmdlets Get-ConfigurationItem, Set-ConfigurationItem, Invoke-Method, and Get-Translations so that if the Configuration API proxy client has faulted, due to an idle timeout for example, the proxy client pool is cleared and new communication channels are established.

### 🗑️ Removed

- Get-CameraReportV1 - use Get-VmsCameraReport

### Deprecated

- Get-CameraReport in favor of Get-VmsCameraReport
- Add-Hardware in favor of Add-VmsHardware
- Export-HardwareCsv in favor of Export-VmsHardware
- Import-HardwareCsv in favor of Import-VmsHardware

