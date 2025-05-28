---
hide:
  - toc
---

# Rename-VmsHardwareTree

When adding hardware to XProtect, the default hardware name is typically something like
"AXIS P1465-LE Bullet Camera (192.168.6.16)". The logical child devices would then have names like
"AXIS P1465-LE Bullet Camera (192.168.6.16) - Camera 1". However, if you've replaced the hardware with a camera using a
different IP address, or you've renamed the hardware and want all the child devices (and there can be a lot of them!) to
adopt the new name, there's no option to do this in the Management Client in bulk.

This script was written for our solution engineers in response to a need to rename a large number of devices following
this naming pattern. If you want to rename devices, but not the hardware, you can simply omit the `BaseName` parameter.
And if you want to rename the hardware and all child devices using the typical naming convention mentioned earlier, you
can run `Get-VmsHardware | Rename-VmsHardwareTree -BaseName '<model> (<ipaddress>)'`.

[Download :material-download:](../scripts/Rename-VmsHardwareTree.ps1){ .md-button .md-button--primary }

## :material-powershell: Code

```powershell linenums="1" title="Rename-VmsHardwareTree.ps1"
--8<-- "scripts/Rename-VmsHardwareTree.ps1"
```

--8<-- "abbreviations.md"

