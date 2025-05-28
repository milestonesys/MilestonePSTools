# Group cameras by model

## Description

Creates a specified base camera group, and within that base group, it creates a group for every enabled camera
make/model. For each camera model, a group is created with a name like 1-X where X is the number of cameras in that
group. If the number exceeds 400, it will create another group called 401-X, until all enabled cameras of that model
have been added to a group.

!!! note
    
    Groups larger than 400 should not be created as the Management Client will not be able to do bulk configurations on them.

Having groups of camera models is very useful for doing bulk configurations. Note that in some instances, cameras
report their models as a series of cameras and not a specific model. In cases like this, bulk configuration will
likely not work as the cameras in the series might support different resolutions and/or frame rates.

[Download :material-download:](../scripts/Group-CamerasByModel.ps1){ .md-button .md-button--primary }

## :material-powershell: Code

```powershell linenums="1" title="Group-CamerasByModel.ps1"
--8<-- "scripts/Group-CamerasByModel.ps1"
```

--8<-- "abbreviations.md"

