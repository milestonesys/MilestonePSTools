[![CI](https://github.com/milestonesys/MilestonePSTools/actions/workflows/CI.yml/badge.svg)](https://github.com/milestonesys/MilestonePSTools/actions/workflows/CI.yml)
[![Docs](https://github.com/milestonesys/MilestonePSTools/actions/workflows/Docs.yml/badge.svg)](https://github.com/milestonesys/MilestonePSTools/actions/workflows/Docs.yml)
[![Issues][issues-shield]][issues-url]
[![PowerShell Gallery][downloads-shield]][downloads-url]
[![Apache 2.0][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/milestonesys/MilestonePSTools">
    <img src="docs/assets/images/logo.svg" alt="Logo" height="100">
  </a>

  <h3 align="center">Manage XProtect® at <u>ANY SCALE</u></h3>

  <p align="center">
    Configure. Automate. Report. You decide what is possible on the Open Platform.
    <br />
    <a href="https://github.com/milestonesys/MilestonePSTools"><strong>Explore the samples »</strong></a>
    <br />
    <br />
    <a href="https://github.com/milestonesys/MilestonePSTools/issues">Report an Issue</a>
    ·
    <a href="https://github.com/milestonesys/MilestonePSTools/discussions">Start a Discussion</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [Why](#why)
* [Quick start](#quick-start)
  * [Prerequisites](#prerequisites)
* [Developers](#developers)
  * [Repo organization](#Repo-organization)
* [Contributing](#contributing)
* [License](#license)

## Why

Taking advantage of Milestone's Open Platform used to require skilled developers and long product development cycles.
Tools or integrations were exclusively developed using Milestone's SDK, or were developed in another language at the
protocol level, representing a steep investment of time and resources.

The MilestonePSTools module lowers the barrier to entry, enabling administrators as well as developers to perform most
tasks related to the lifetime operation and maintenance of an XProtect Video Management System using PowerShell while
simultanously allowing advanced users to access the underlying `VideoOS.*` namespaces from our .NET Framework SDK
directly within the same PowerShell environment.

Administrators who are already comfortable with PowerShell can build their own scripts and automations, while developers
can accelerate and automate the deployment of test environments, and interact with the various XProtect API's at the
terminal in real-time.

## Quick start

* Install the MilestonePSTools module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/MilestonePSTools)
  and login to XProtect:

```powershell
Install-Module -Name MilestonePSTools -Scope CurrentUser
Connect-Vms -AcceptEula
```

* Export detailed information about camera configuration to CSV using the built-in `Get-VmsCameraReport` command:

```powershell
Get-VmsCameraReport | Export-Csv report.csv -NoTypeInformation
```

* List the top ten devices by total used disk space

```powershell
$properties = @(
    @{
        Name       = 'Camera'
        Expression = { Get-VmsCamera -Id $_.DeviceId }
    },
    'UsedSpaceInBytes'
)
Get-VideoDeviceStatistics | % VideoDeviceStatistics | Sort UsedSpaceInBytes | Select $properties -Last 10
```

> 🔥 **Tip** </br>
> 
> It is __not required__ to install MilestonePSTools on any of your Milestone XProtect VMS servers. You may install it
> on any computer with network access to your VMS. If Smart Client works on the computer, MilestonePSTools _should_ work
> too. Oh, and you (usually) _do not_ need Administrative privileges on the computer, or in XProtect, to use
> MilestonePSTools!

### Prerequisites

* Milestone XProtect VMS (XProtect Essential+, Express+, Professional+, Expert, or Corporate) 2014 or newer
* Windows PowerShell 5.1

> 🔥 **Tip** </br>
>
> Use `$PSVersionTable` to determine the PSVersion of your current PowerShell terminal. If you need to upgrade
> PowerShell, download Windows [Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)
> from Microsoft.

* .NET Framework 4.7.2
* Full Language Mode

> 🔥 **Tip** </br>
>
> Check your current language mode by running `$ExecutionContext.SessionState.LanguageMode`.

* Execution policy != `Restricted`

> 🔥 **Tip** </br>
>
> We typically use the `RemoteSigned` execution policy. Check yours with `Get-ExecutionPolicy` and change it with
> `Set-ExecutionPolicy RemoteSigned`

## Developers

The file `build.ps1` is intended to be the entrypoint for building, testing, and publishing both the module, and the
documentation. To perform your first local build on a forked/cloned repo, you can run...

```powershell
.\build.ps1 -Bootstrap
```

The presence of `-Bootstrap` results in the installation of prerequisites found in `requirements.psd1` which includes...

* **Visual Studio Build Tools**
* **Chocolatey** & the `dotnet-sdk` and `nuget.commandline` packages
* The `dotnet` tool `nbgv` used for automatic versioning
* The following PowerShell modules
  * **BuildHelpers** for generating build-time environment variables
  * **Microsoft.PowerShell.SecretManagement & SecretStore** for secret management used for integration tests
  * **PlatyPS** for generating and updating documentation in markdown and maml format
  * **PowerShellBuild** for common PowerShell module build tasks based on psake
  * **Pester** for module and documentation tests
  * **psake** for build tasks (see `psakefile.ps1`)
  * **PSScriptAnalyzer** for static PowerShell script analysis
  * **VSSetup** for interacting with Visual Studio Setup and discovering the correct `msbuild` path

Technically `powershell.exe` and `git` are the only absolute prerequisites for developing and testing the module, but
for the best experience we recommend you also have...

* **Visual Studio Code** with the `ms-vscode.powershell` and `ms-dotnettools.csharp` extensions for working with PowerShell
scripts and C#.
* **Visual Studio Community Edition** for a more reliable C# developer experience (optional, but vscode isn't always
  a great experience for .NET Framework projects)
* **dotnet sdk** which is primarily used to install the tools `nbgv` and `azuresigntool`. Using the `-Bootstrap` switch
  installs the `dotnet sdk`, but only adds it to `$env:PATH` for the current process. Download and install the sdk so
  that the `dotnet` CLI is available on `$env:PATH` so you don't have to use `-Bootstrap` every time.

### Repo organization

---

**Building**

* `build.ps1` is your main entrypoint. Call it without parameters and the build will be performed in an isolated
  PowerShell process so as to avoid loading and locking the module and MIP SDK assemblies. Run `.\build.ps1 -Help` to
  see all build tasks. The most common tasks you use will be...
  * `.\build.ps1` for a build without tests
  * `.\build.ps1 runtests` for a build with tests, but not _integration tests_
  * `.\build.ps1 integration-tests` will execute the integration Pester tests
  * `.\build.ps1 mkdocs-serve` will start up an MkDocs Material container and serve a local copy of the docs site

> ❗ Note</br>
>
> We support and use the [Material for MkDocs Insiders](https://squidfunk.github.io/mkdocs-material/insiders/) theme and
> and need to make changes to the mkdocs project in this repo to gracefully fall back to the community version of the
> theme since we can't provide external contributors with access to our copy of the insiders container image.

---

**Documentation**

If you add or change a `function` or `cmdlet` in the module, the corresponding file under `docs/commands/en-US/` will be
automatically created or, if necessary, updated. New documentation stubs will have `Synopsis`, `Description`, `Examples`
and `Parameter` descriptions populated with placeholders using the format `{{ ... }}`. You will want to find and replace
these placeholders with real documentation before a PR will be accepted. We choose not to use [Comment Based Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-5.1)
for a few reasons.

First, this module is a hybrid of compiled `cmdlets` written in C# and `functions` written in
PowerShell, and there is not a consistent way to represent comment based help. Second, keeping the documentation
separate allows different people to improve the code, and the documentation at the same time without stepping on each
other's toes, even with everything in the same repo.

We have the following additional resources under `docs`:

* `docs/blog` for blog posts. These are typically written by internal Milestone authors but we will consider
  non-promotional posts from our developer community.
* `docs/examples` for example scripts that might have a broad appeal to the community. These should be tested and maintained
  as users often come to rely on them.
* `docs/help/howto.md` includes relatively simple examples that help with questions like _"How do I get a list of cameras that aren't in a view?"_
  or _"How do I find all cameras that aren't recording in H.264?"_. These are very valuable examples for new
  MilestonePSTools users, and the more examples we have, the faster people can reach beyond `Get-VmsCameraReport` and
  begin building valuable solutions for their business.

---

**Module functions and cmdlets**

The C# source code for the compiled part of the module is found under `src/MilestonePSTools`. The module `.psd1` and
`.psm1` files, along with all the `.ps1` files are found in `MilestonePSTools/`. There is no rhyme or reason for which
commands are written in C# vs PowerShell today. The first versions of the module were entirely written in C#. As the
module matured, some functions were written in PowerShell as it tends to be faster to write and test new functions that
way, and the PowerShell functions double as example PowerShell code in a way.

Advantages of writing cmdlets in C# include typesafety, and better support for deduplicating code using inheritance.
It is also a good place for implementing new validation & transformation attributes, and argument completers that can be
used both in C# and in PowerShell.

Advantages of writing functions in PowerShell include rapid and incremental development and testing. Some minor
drawbacks include the lack of typesafety, and slightly poorer performance compared to a compiled cmdlet.

For the time being, it is up to the developer to choose whether to implement a new command in PowerShell or C#. A future
cross-platform version of the module may or may not end up following the same hybrid model.

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

0. _Optional_ - Create an issue and describe the problem, or new feature you want to address
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/great-new-feature`)
3. Commit your Changes (`git commit -m 'Add a great new feature'`)
4. Push to the Branch (`git push origin feature/great-new-feature`)
5. Open a Pull Request and reference an issue if one exists

## License

Distributed under the Apache 2.0 license. See `LICENSE` for more information.

<!-- MARKDOWN LINKS & IMAGES -->
[issues-shield]: https://img.shields.io/github/issues/milestonesys/MilestonePSTools.svg?style=flat-square
[issues-url]: https://github.com/milestonesys/MilestonePSTools/issues
[downloads-shield]: https://img.shields.io/powershellgallery/dt/MilestonePSTools
[downloads-url]: https://powershellgallery.com/packages/MilestonePSTools
[license-shield]: https://img.shields.io/github/license/milestonesys/MilestonePSTools.svg?style=flat-square
[license-url]: https://github.com/milestonesys/MilestonePSTools/blob/master/LICENSE
[product-screenshot]: images/screenshot.png
