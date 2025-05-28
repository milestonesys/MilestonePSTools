# Support

MilestonePSTools is actively maintained and supported by Milestone Systems. We value your feedback and are committed
to resolving any issues you encounter with our PowerShell module. Questions, suggestions, and bug reports should be
submitted to us using our public GitHub [issue tracker](https://github.com/MilestoneSystemsInc/PowerShellSamples/issues).

!!! note
    Our team addresses reported issues as time permits. We do not provide a guaranteed response time for reported issues
    at this time.

## What kind of support is available?

### :material-bug: Bug fixes

- Bugs are fixed for future releases of MilestonePSTools and are not back-ported to previous versions.
- The severity of the bug _may_ influence how quickly a new version of the module is released.
- If a bug is not reproducible on a _supported XProtect VMS version_ we may choose not to implement a fix. This helps prevent code from becoming
unmaintainable, and ensures we do not distract our core XProtect and MIP SDK developers with issues related to versions
they no longer support.
- Some bugs are caused by the XProtect VMS itself rather than our PowerShell module. If we believe that to be the case,
  we will either assist you by providing you with the information you need to open a traditional technical support case,
  or we will open a bug report directly with the appropriate internal team at Milestone. This will be done at our
  discretion.

### :material-chat-question: General questions

Whether you are new to PowerShell, XProtect, both, or neither, you are bound to have a question for us at some point. We
want to hear it! Please create an "issue" at [MilestoneSystemsInc/PowerShellSamples/issues](https://github.com/MilestoneSystemsInc/PowerShellSamples/issues)
and we will respond.

### :sparkles: Feature requests

If you have an idea for an improvement or new feature for MilestonePSTools, let us know! Please create an "issue" at [MilestoneSystemsInc/PowerShellSamples/issues](https://github.com/MilestoneSystemsInc/PowerShellSamples/issues)
so we can start a dialog. Whether or not we choose to implement your feature, your feedback is _incredibly important_
and highly motivating

### :octicons-comment-discussion-24: Discussions

We will occasionally post a topic for discussion in the [discussions](https://github.com/MilestoneSystemsInc/PowerShellSamples/discussions)
section on GitHub. These are great for broad discussions that don't necessarily fall under the category of "bugs" or
"feature requests". If you're looking for a more casual chat, you can also reach us on the
[Milestone Developer Community Discord](https://discord.milestonepstools.com/).

## What Makes a Good Bug Report?

- **Reproducibility**: Include steps that allow us to easily reproduce the issue.
- **Minimal Example**: Strip down your example to the bare minimum necessary to exhibit the problem.
- **Clarity and Detail**: Provide enough context for others to understand your environment and scenario.

By following these guidelines, you help us address issues faster and more effectively. Thank you for contributing to making MilestonePSTools better!

## How to submit a bug report

Your detailed reports help us to improve this valuable tool to the benefit of the entire community. Here are a few tips
for making a quality bug report.

1. **Search Existing Issues**
    - Before opening a new issue, check if someone else has already reported the same problem:
        1. Go to [our GitHub repository](https://github.com/MilestoneSystemsInc/PowerShellSamples/issues).
        2. Click on the “Issues” tab and use the search tool.

2. **Create a Minimal Example**
    - Write down the exact steps needed to replicate the issue:
        1. Provide the necessary commands or scripts that trigger the error.
        2. Include any relevant output or screenshots.

3. **Provide Context Information**
    - Help us understand your environment by including these relevant details in your report:
        1. The version of MilestonePSTools you are using (find using `#!powershell Get-Module`).
        2. The version of PowerShell returned by `#!powershell $PSVersionTable.PSVersion`
        3. The Milestone XProtect VMS version you are connected (or trying to connect) to.

4. **Write a Clear Description**
    - Craft a concise yet detailed description of the issue:
        1. Start with a short summary or title for your report.
        2. Describe what you expected to happen versus what actually occurred.
        3. Mention any error messages and their context (e.g., where they appear in logs).

5. **Submit Your Report**
    - Finally, submit your bug report. We will respond as time permits.

