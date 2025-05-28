# Group all devices by model

## Description

Creates a base device group for cameras, microphones, speakers, metadata, inputs, and/or outputs, and within each
base group, it creates a group for every selected device by make/model. For each model, a group is created with a
name like 1-X where X is the number of devices in that group. If the number exceeds 400, it will create another
group called 401-X, until all selected devices of that model have been added to a group.

!!! note
    
    Groups larger than 400 should not be created as the Management Client will not be able to do bulk configurations on them.

Having groups of devices by model is very useful for doing bulk configuration changes in the Management Client. Note
that in some instances, devices report their models as a series of and not a specific model. In cases like this,
bulk configuration will likely not work as the cameras in the series might support different resolutions and/or
frame rates.

[Download :material-download:](../scripts/Group-DevicesByModel.ps1){ .md-button .md-button--primary }

## :material-powershell: Code

```powershell linenums="1" title="Group-CamerasByModel.ps1"
--8<-- "scripts/Group-DevicesByModel.ps1"
```

--8<-- "abbreviations.md"

