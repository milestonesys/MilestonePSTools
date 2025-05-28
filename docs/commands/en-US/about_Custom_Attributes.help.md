# about_Custom_Attributes

## SHORT DESCRIPTION

Describes how the custom attributes in MilestonePSTools are used internally, and
how they can be used externally.

## LONG DESCRIPTION

Attributes are used to add information and/or change behavior for pieces of software. They can be used during the use of
software to affect the user experience in some way, and they can be used externally as a documentation tool.

Custom attributes were introduced internally in MilestonePSTools version 23.2.1, and are expanded and improved for
version 23.2.2. The attributes listed below are used in this module to validate that certain criteria are met, depending
on the command, or parameters used. Some attributes are applied to command _parameters_, and others are applied to whole
commands.

```
[MilestonePSTools.RequiresVmsConnection()]
[MilestonePSTools.RequiresVmsFeature()]
[MilestonePSTools.RequiresVmsVersion()]
[MilestonePSTools.RequiresElevation()]
[MilestonePSTools.ValidateVmsFeature()]
[MilestonePSTools.ValidateVmsVersion()]
```

## Requires vs Validate

The `[MilestonePSTools.Validate*()]` attributes are similar to the built-in parameter validation attributes
like `[ValidateNotNullOrEmpty()]`, or `[ValidateSet('Option1', 'Option2')]`. When these built-in
attributes are applied to a parameter in a command, and that parameter is used, the `#!csharp Validate(object arguments, EngineIntrinsics engineIntrinsics)`
method of that attribute is automatically invoked by the PowerShell runtime. The source code for the attribute will then
make sure that the input provided is valid. The difference with the initial two custom argument validation attributes in
MilestonePSTools is that they don't check the value of the parameter. Instead, they check the connected VMS to ensure the
environment is suitable for using those parameters.

As an example, the `Set-VmsRecordingServer` function has some parameters for changing settings related to
failover recording servers. But if you provide values for these parameters on a system without support for failover
recording servers, the `[ValidateVmsFeature('RecordingServerFailover')]` attributes will automatically
ensure that the command fails with a clear and consistent error message.

The `[MilestonePSTools.Requires*()]` attributes serve a similar purpose, but the implementation is slightly
different. These attributes are intended to be applied to the whole function and are placed next to where the
`[CmdletBinding()]`, `[OutputType()]`, and other "class level attributes" are normally found, just above the `param()`
block. However, the PowerShell 5.1 runtime will not automatically call `Validate()` methods on attributes applied to
functions or cmdlets, so we needed to do this ourselves. Every function in MilestonePSTools that uses one of these
attributes will therefore include a call to `Assert-VmsRequirementsMet` in the `Begin {}` block.

The `Assert-VmsRequirementsMet` function uses `Get-PSCallStack` to find the function from which it was invoked, and looks
for any attributes which implement the `MilestonePSTools.IVmsRequirementValidator` interface. The `Validate()` method is
then called for each matching attribute. If an exception error is thrown by any one of these attributes, the function
will return a descriptive error message and no further code in that function will execute.

## Usage

### RequiresVmsConnection

The `[MilestonePSTools.RequiresVmsConnection()]` attribute ensures that a function will not run unless you are connected
to a Milestone XProtect VMS. If you are not connected, it will by default attempt to connect by calling `Connect-Vms`. This
command will by default connect to the profile named "default". If no default connection profile exists, a login dialog
will be displayed instead. In both cases, if the connection fails, the command will throw a `VmsNotConnectedException` error
and stop.

=== "Default: With auto-connect"
    When used without any arguments, the `RequiresVmsConnection` attribute will require a VMS connection, and will
    auto-connect if no connection is available.

    ```powershell linenums="1"
    function Test-RequiresVmsConnection {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsConnection()]
        param()

        begin {
            Assert-VmsRequirementsMet # (1)!
        }

        process {
            $true # (2)!
        }
    }
    ```

    1. It is necessary to call this function when using the `MilestonePSTools.Requires*` attributes, or no assertions will
    be made and the function will continue whether a connection is available or not.
    2. This line will not be reached if a connection is not available.

=== "Without auto-connect"
    If you want to ensure the command does not run without a connection, but you don't want to automatically connect
    to the default connection profile, you can provide values for `ConnectionRequired` and `AutoConnect`.

    ```powershell linenums="1"
    function Test-RequiresVmsConnection {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsConnection(ConnectionRequired, AutoConnect = $false)]
        param()

        begin {
            Assert-VmsRequirementsMet # (1)!
        }

        process {
            $true # (2)!
        }
    }
    ```

    1. It is necessary to call this function when using the `MilestonePSTools.Requires*` attributes, or no assertions will
    be made and the function will continue whether a connection is available or not.
    2. This line will not be reached if a connection is not available.

### RequiresVmsFeature

The `[MilestonePSTools.RequiresVmsFeature('feature-name')]` attribute will check for the presence of a feature flag on the
connected VMS and throw a `VmsNotConnectedException` error if not connected to a VMS, or a `VmsFeatureNotAvailableException`
error if connected to a VMS without the specified feature flag. The feature flags available in your VMS can be found using
`(Get-VmsSystemLicense).FeatureFlags`.

Only one feature flag may be specified per attribute, but you can apply the attribute more than once if there are two or
more feature flags you want to ensure are present before running your function.

```powershell linenums="1"
function Test-RequiresVmsFeature {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsFeature('FirmwareUpdate')]
    param()

    begin {
        Assert-VmsRequirementsMet # (1)!
    }

    process {
        $true # (2)!
    }
}
```

1. It is necessary to call this function when using the `MilestonePSTools.Requires*` attributes, or no assertions will
   be made and the function will continue whether a connection is available or not.
2. This line will not be reached if a connection is not available.

### RequiresVmsVersion

The `[MilestonePSTools.RequiresVmsVersion('23.2')]` attribute asserts that the connected VMS version matches the specified
version string. The basic syntax checks whether the VMS version is _at least_ the specified version. The version numbers
use the Major.Minor.Build.Revision format but can typically be simplified to a Major.Minor version. For example, Milestone
XProtect 2023 R2 is version 23.2, and 2023 R3 will be 23.3.

If the need arises, you can specify that the version must be between a minimum and maximum version (inclusive or exclusive),
or exactly the specified version. See the examples below, and Microsoft's [nuget package versioning](https://learn.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges) documentation for more detail on defining very specific version requirements.

=== "At least"
    The simplest, and most common usage is to specify that the VMS version is _at least_ some version. For example,
    commands using the "replace hardware" functionality introduced to Milestone's APIs in version 2023 R1 should assert
    that the VMS version is at least "23.1".

    ```powershell linenums="1"
    function Test-RequiresVmsVersion {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsVersion('23.1')]
        param()

        begin {
            Assert-VmsRequirementsMet # (1)!
        }

        process {
            $true # (2)!
        }
    }
    ```

    1. It is necessary to call this function when using the `MilestonePSTools.Requires*` attributes, or no assertions will
    be made and the function will continue whether a connection is available or not.
    2. This line will not be reached if a connection is not available.

=== "Exactly"
    If you have reason to restrict a command to a specific VMS version exactly, you can enclose the version number in square
    brackets.

    ```powershell linenums="1"
    function Test-RequiresVmsVersion {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsVersion('[23.2]')]
        param()

        begin {
            Assert-VmsRequirementsMet # (1)!
        }

        process {
            $true # (2)!
        }
    }
    ```

    1. It is necessary to call this function when using the `MilestonePSTools.Requires*` attributes, or no assertions will
    be made and the function will continue whether a connection is available or not.
    2. This line will not be reached if a connection is not available.

=== "Range"
    In some cases it might be required to limit a function to operating against VMS versions in a given range. If no
    minimum version is provided, it is assumed to be `[Version]'0.0.0.0'`. Square brackets and parentheses are used to
    indicate whether the version values are to be _inclusive_ or _exclusive_, respectfully.

    ```powershell linenums="1"
    function Test-RequiresVmsVersion {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsVersion('[20.1,22.3]')]
        param()

        begin {
            Assert-VmsRequirementsMet
        }

        process {
            # The VMS version is at least 2020 R1, and no greater than 2022 R3
            $true
        }
    }
    ```

    ```powershell linenums="1"
    function Test-RequiresVmsVersion {
        [CmdletBinding()]
        [MilestonePSTools.RequiresVmsVersion('(,23.1)')]
        param()

        begin {
            Assert-VmsRequirementsMet
        }

        process {
            # The VMS version is older than 2023 R1
            $true
        }
    }
    ```

### RequiresElevation

The `[MilestonePSTools.RequiresElevation()]` attribute will check whether the current PowerShell session has elevated
privileges (run as administrator). Most commands in MilestonePSTools do not require elevated privileges, but a few of them
do because they update properties of the operating system or because they call external utilities like Server Configurator
which requires elevation.

Normally, if your script requires administrator privileges, you should add `#Requires -RunAsAdministrator` to the top of
your script. PowerShell will then automatically fail to execute the script without elevation, and this is a capability that
is built into the PowerShell runtime.

However, if you have a collection of functions with some that require elevation and some that do not, you might want to
check for elevation in some of them and not others. In that case, this attribute can be useful.

```powershell linenums="1"
function Test-RequiresElevation {
    [CmdletBinding()]
    [MilestonePSTools.RequiresElevation()]
    param()

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $true
    }
}
```

### ValidateVmsFeature

The `[MilestonePSTools.ValidateVmsFeature('feature-flag')]` attribute is applied to function parameters where the use of that parameter
depends on the presence of a specific feature flag. Unlike the `[MilestonePSTools.Requires*]` attributes, this attribute
does not require you to call `Assert-VmsRequirementsMet`.

To see a list of the feature flags associated with your VMS installation, you can use `(Get-VmsSystemLicense).FeatureFlags`.
If you need to write a function with a parameter that requires the presence of the "SmartClientProfiles" feature flag,
you would decorate the parameter with `[MilestonePSTools.ValidateVmsFeature('SmartClientProfiles')]` as in the example below.

```powershell linenums="1"
function Test-ValidateVmsFeature {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Parameter1,

        [Parameter()]
        [MilestonePSTools.ValidateVmsFeature('SmartClientProfiles')]
        [string]
        $Parameter2
    )

    process {
        $true
    }
}
```

### ValidateVmsVersion

The `[MilestonePSTools.ValidateVmsVersion('23.2')]` attribute is applied to function parameters where the use of that parameter
requires a specific VMS version. For example, `Set-VmsCameraStream` has a "PlaybackDefault" parameter which is only applicable
on VMS version 2023 R2 and later as it relates to a feature introduced in 2023 R2 which allows a second stream to be recorded.

```powershell linenums="1"
function Test-ValidateVmsVersion {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Parameter1,

        [Parameter()]
        [MilestonePSTools.ValidateVmsVersion('22.1')]
        [string]
        $Parameter2
    )

    process {
        $true
    }
}
```

## Attributes vs Assert Functions

Without the use of attributes, code would need to be added to every function where a specific VMS feature must be present,
or where a VMS version requirement must be met. The implementation might not be the same in every command, and the error
messages across different commands might be inconsistent as a result.

The "DRY" principle, or "Don't Repeat Yourself", informs us that we should aim to minimize repetition in our code. To do
that, we could choose to create specific functions like `Assert-VmsVersion` and `Assert-VmsFeature`, and that is a perfectly
good solution. But what happens when a function has a version, _and_ a feature requirement? Now we need to remember to
call both "assert" functions.

Honestly, that's not so bad. It's probably less complex than the use of custom attributes. However, attributes have the
added advantage of being easy to "query" for documentation purposes. Any attribute applied to a function, cmdlet, or
parameter, is relatively easily discovered using "reflection" - a feature of many programming languages allowing a program
to "look" at itself.

The custom attributes in MilestonePSTools are therefore used to simplify the use of "assertions", as well as to ensure
the module documentation includes information about the unique requirements of each command. And because the documentation
is generated, and updated each time a new version of the module is built, these properties will always be present and
up to date in the documentation if a custom attribute is used in that command.

