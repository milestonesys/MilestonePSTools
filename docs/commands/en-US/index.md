# Command Index

All commands in the latest release of MilestonePSTools can be found in the table below, each with a link to their
documentation page. If you have the module installed already, you may see a list of available commands from PowerShell
using `#!powershell Get-Command -Module MilestonePSTools`.

To get to the online help for any command in the module from a PowerShell terminal with an internet connection, you may
use `Get-Help` with the "-Online" switch. For example, `#!powershell Get-Help -Name Get-VmsCameraReport -Online`.

!!! note

    The data used to build this index is available in JSON format at [https://www.milestonepstools.com/commands/command-history.json](https://www.milestonepstools.com/commands/command-history.json).
    
    ```powershell title="Get commands that have been removed, or aliased"
    $cmdHistory = Invoke-RestMethod https://www.milestonepstools.com/commands/command-history.json
    $cmdHistory.Commands | Where-Object VersionRemoved | Select-Object Name, VersionRemoved, AliasedTo | Sort-Object Name
    ```

## :card_index: Index

--8<-- "commands/commands.mdtable"

