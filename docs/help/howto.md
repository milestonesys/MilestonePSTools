# How do I...

We get a lot of great questions about how to do small, specific tasks that don't justify a whole dedicated example page.
We'll add some of these quick "how do I" answers to this page over time.

## How do I get a list of evidence locks about to expire?

Evidence locks are used to apply a custom retention policy for video and related devices. If an incident occurs, you may
want to "lock" that video and keep it for an extra month, or two, or maybe indefinitely.

!!! tip

    When an event is serious enough to warrant the use of the "Evidence Lock" feature, it is probably also important
    enough to export. You'll thank yourself later if your recording server storage fails, or your evidence lock expires
    before you're ready.

MilestonePSTools includes the following commands for working with evidence locks:

- [`#!powershell Add-EvidenceLock`](../commands/en-US/Add-EvidenceLock.md)
- [`#!powershell Copy-EvidenceLock`](../commands/en-US/Copy-EvidenceLock.md)
- [`#!powershell Get-EvidenceLock`](../commands/en-US/Get-EvidenceLock.md)
- [`#!powershell Remove-EvidenceLock`](../commands/en-US/Remove-EvidenceLock.md)
- [`#!powershell Update-EvidenceLock`](../commands/en-US/Update-EvidenceLock.md)

Here's how you can use `#!powershell Get-EvidenceLock` to get a list of evidence locks expiring in the next 7 days:

```powershell
Get-EvidenceLock | Where-Object RetentionExpire -lt (Get-Date).AddDays(7)
```

## How do I get a list of cameras and the make or model?

In XProtect, the configuration hierarchy from the Management Server down to a device (camera, microphone, speaker, etc) looks like...

- Management Server
  - Recording Server
    - Hardware
      - Camera
      - Microphone
      - Speaker
      - Metadata
      - Input
      - Output

Some of the information you might want to see in a report may be available at any level. For example, you may want to
see `Camera` names, along with the IP address which is a property of the logical _hardware_ object which is the "parent item" of the `Camera` object. Further more, properties like the MAC and firmware are not available directly on the `Hardware` object. They exist as a property of the "general settings" child item on the hardware.

Here are some examples of how you can retrieve various combinations of properties.

### Get the hardware name, address, and model

```powershell
Get-VmsHardware | Select-Object -Property Name, Address, Model
```

??? abstract "Output"
    | Name                             | Address                  | Model                          |
    |----------------------------------|--------------------------|--------------------------------|
    | Lobby Fisheye (10.11.2.11)       | http://10.11.2.11/       | FLEXIDOME IP panoramic 7000 MP |
    | Workroom Hallway (10.11.2.6)     | http://10.11.2.6/        | AXIS P3255-LVE Dome Camera     |
    | FLEXIDOME IP 4000i (10.11.2.57)  | http://10.11.2.57/       | FLEXIDOME IP 4000i             |
    | Stairwell Door (10.11.2.10)      | http://10.11.2.10/       | AXIS P3265-V Dome Camera       |
    | Right Elevator (10.11.2.2)       | http://10.11.2.2/        | AXIS P3267-LV Dome Camera      |
    | Casino - Sweating Being Nervous  | http://127.0.0.1:110/    | StableFPS_T800                 |
    | HA Falling - Night 2 (127.0.0.1) | http://127.0.0.1:1108/   | StableFPS_T800                 |
    | Partner Activation (10.11.2.26)  | http://10.11.2.26/       | AXIS P3268-LV Dome Camera      |
    | Breakroom (10.11.2.27)           | http://10.11.2.27/       | Hanwha Vision XND-9083RV       |
    | iSentry (10.11.2.113)            | http://10.11.2.113:8554/ | Universal16ChAdv               |

### Get the hardware name, IP, and model

```powershell linenums="1"
$props = @(
    'Name',
    @{
        Name       = 'IP'
        Expression = { ([uri]$_.Address).Host }
    },
    'Model'
)
Get-VmsHardware | Select-Object -Property $props
```

??? abstract "Output"
    | Name                             | IP          | Model                          |
    |----------------------------------|-------------|--------------------------------|
    | Lobby Fisheye (10.11.2.11)       | 10.11.2.11  | FLEXIDOME IP panoramic 7000 MP |
    | Workroom Hallway (10.11.2.6)     | 10.11.2.6   | AXIS P3255-LVE Dome Camera     |
    | FLEXIDOME IP 4000i (10.11.2.57)  | 10.11.2.57  | FLEXIDOME IP 4000i             |
    | Stairwell Door (10.11.2.10)      | 10.11.2.10  | AXIS P3265-V Dome Camera       |
    | Right Elevator (10.11.2.2)       | 10.11.2.2   | AXIS P3267-LV Dome Camera      |
    | Casino - Sweating Being Nervous  | 127.0.0.1   | StableFPS_T800                 |
    | HA Falling - Night 2 (127.0.0.1) | 127.0.0.1   | StableFPS_T800                 |
    | Partner Activation (10.11.2.26)  | 10.11.2.26  | AXIS P3268-LV Dome Camera      |
    | Breakroom (10.11.2.27)           | 10.11.2.27  | Hanwha Vision XND-9083RV       |
    | iSentry (10.11.2.113)            | 10.11.2.113 | Universal16ChAdv               |

!!! info
    The way we used `Select-Object` in the previous example was a lot more complicated looking than the first example. Let's
    first talk a little about the first example where we "piped" hardware to `Select-Object -Property Name, Address, Model`.
    
    This "selects" the specified _properties_ from the original `Hardware` objects, and returns a _new object_ having only
    the desired properties. The `-Property` parameter on `Select-Object` accepts an array or a list of "objects" which can
    be strings like "Name", or "Address", and if the object being processed has those properties, their values will be included in the output.
    
    What if want _just_ the IP address though? Not a fully-qualified URI like "http://192.168.64.123/", but just the value
    "192.168.64.123"? There is no "IP" property on a `Hardware` object, so in the second example we use two great PowerShell
    features to transform the output: [calculated properties](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_calculated_properties?view=powershell-5.    1) and the `[uri]` [type accelerator](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_type_accelerators?view=powershell-5.1).
    
    In the second example, the `IP` calculated property is added using the following hashtable...
    
    ```powershell linenums="1"
    @{
        Name       = 'IP'
        Expression = { ([uri]$_.Address).Host } # (1)!
    }
    ```
    
    1. The special variable `$_`, also aliased as `$PSItem`, represents the "current item" which will be one of whatever you
    pipe to `Select-Object`. In this case it represents a `Hardware` object which has a property named "Address".
    
    Based on the documentation for calculated properties in PowerShell, this [hashtable](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/    about_calculated_properties?view=powershell-5.1#hashtable-key-definitions) can have several keys in addition to `Name` and `Expression` keys, but these are the most
    important ones. The value provided for `Name` will become the name of the property on the resulting object returned by
    `Select-Object`, and the `Expression` value is expected to be a [scriptblock](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_script_blocks?    view=powershell-5.1).
    Whatever value is returned by the scriptblock will be the value of the calculated property.
    
    You will sometimes see examples of calculated properties in an abbreviated form since the "Name" and "Expression" keys
    do not need to be spelled out completely...
    
    ```powershell
    Get-VmsHardware | Select-Object Name, @{n='IP';e={([uri]$_.Address).Host}}, Model
    ```
    
    This example returns the _exact same_ output. The only difference is that the `Name` and `Expression` keys are shortened
    to `n` and `e` respectively, and everything is on one line instead of splitting it up for better clarity. This is quite
    often how I will write code in the terminal where I'm not concerned about anyone else understanding what I've written.
    For documentation and examples I try to use full command names, and split long commands onto multiple lines in ways that
    improve readability and are safe to copy/paste.
    
    In the remaining examples, I will gather the properties for `Select-Object` into an array like in the first example, and
    the calculated properties will be included as hashtables written over multiple lines.

### Get the hardware name, IP, model, and parent recording server

```powershell linenums="1"
$props = @(
    'Name',
    @{
        Name       = 'IP'
        Expression = { ([uri]$_.Address).Host }
    },
    'Model',
    @{
        Name       = 'RecordingServer'
        Expression = { ($_ | Get-VmsParentItem).Name } # (1)!
    }
)
Get-VmsHardware | Select-Object -Property $props
```

1. Here, `$_` represents a `Hardware` object, and the parent item is a `RecordingServer` object.

??? abstract "Output"
    | Name                             | IP          | Model                          | RecordingServer |
    |----------------------------------|-------------|--------------------------------|-----------------|
    | Lobby Fisheye (10.11.2.11)       | 10.11.2.11  | FLEXIDOME IP panoramic 7000 MP | NGD-RS          |
    | Workroom Hallway (10.11.2.6)     | 10.11.2.6   | AXIS P3255-LVE Dome Camera     | NGD-RS          |
    | FLEXIDOME IP 4000i (10.11.2.57)  | 10.11.2.57  | FLEXIDOME IP 4000i             | NGD-RS          |
    | Stairwell Door (10.11.2.10)      | 10.11.2.10  | AXIS P3265-V Dome Camera       | NGD-RS          |
    | Right Elevator (10.11.2.2)       | 10.11.2.2   | AXIS P3267-LV Dome Camera      | NGD-RS          |
    | Casino - Sweating Being Nervous  | 127.0.0.1   | StableFPS_T800                 | NGD-RS          |
    | HA Falling - Night 2 (127.0.0.1) | 127.0.0.1   | StableFPS_T800                 | NGD-RS          |
    | Partner Activation (10.11.2.26)  | 10.11.2.26  | AXIS P3268-LV Dome Camera      | NGD-RS          |
    | Breakroom (10.11.2.27)           | 10.11.2.27  | Hanwha Vision XND-9083RV       | NGD-RS          |
    | iSentry (10.11.2.113)            | 10.11.2.113 | Universal16ChAdv               | NGD-RS          |

### Get the camera name, IP, MAC, firmware, and recording server

```powershell linenums="1"
$props = @(
    'Name',
    @{
        Name       = 'IP'
        Expression = { ([uri]($_ | Get-VmsParentItem).Address).Host }
    },
    @{
        Name       = 'MAC'
        Expression = { ($_ | Get-VmsParentItem | Get-HardwareSetting).MacAddress }
    },
    @{
        Name       = 'Firmware'
        Expression = { ($_ | Get-VmsParentItem | Get-HardwareSetting).FirmwareVersion }
    },
    @{
        Name       = 'RecordingServer'
        # Here, $_ represents a Camera object, and the recorder is the parent of the parent item
        Expression = { ($_ | Get-VmsParentItem | Get-VmsParentItem).Name }
    }
)
Get-VmsCamera | Select-Object -Property $props
```

??? abstract "Output"
    | Name                                                    | IP                                   | MAC               | Firmware              | RecordingServer |
    |---------------------------------------------------------|--------------------------------------|-------------------|-----------------------|-----------------|
    | 2N IP Verso Camera                                      | 10.11.2.49                           | 7C1EB3F18045      | 2.43.1.56.3           | NGD-RS          |
    | AirportEastPerimeter                                    | 10.11.2.113                          | 199F4A7C04E9      | NA                    | NGD-RS          |
    | ATM Weapon                                              | 10.11.2.113                          | 199F4A7C04E9      | NA                    | NGD-RS          |
    | Axis Body Worn (Body worn user camera) - Camera 1       | 26a92fe7_ca72_450e_b166_e5130764a14b | E2:27:34:85:4C:DE | 1.1                   | NGD-RS          |
    | Axis Door Station (AXIS A8105-E)                        | 10.11.2.38                           | ACCC8EDB02BB      | 1.65.12               | NGD-RS          |
    | AXIS M1125 Network Camera - 10.3.32.172                 | msapi.arcules.com                    | 02:AD:9F:55:A7:15 | 1.0                   | NGD-XPROTE-RS   |
    | Axis P3268-LV                                           | msapi.arcules.com                    | 02:17:3C:17:D7:7F | 1.0                   | NGD-XPROTE-RS   |
    | AXIS Q1615 Mk III Network Camera (10.11.2.8) - Camera 1 | 10.11.2.8                            | B8A44F140265      | 12.1.64               | NGD-RS          |
    | BeNeLux AXIS P1455-LE                                   | msapi.arcules.com                    | 02:3A:B1:DF:C9:7F | 1.0                   | NGD-XPROTE-RS   |
    | Breakroom (Hanwha XND-9083RV)                           | 10.11.2.27                           | E4302276F8B6      | 2.23.01_20240911_R482 | NGD-RS          |

!!! tip
    On systems with only a few hundred cameras, these examples are _okay_, but they begin to slow down as more more
    calculated properties are used. Especially when we make API calls to retrieve the parent item or general settings using
    commands like `Get-VmsParentItem` and `Get-HardwareSetting`.

If you frequently need to generate a report with information from multiple levels in XProtect's Configuration API
hierarchy, you might want to use some nested `foreach` blocks and construct your own custom object using the
`[pscustomobect]` type accelerator. This method avoids unnecessary extra API calls to retrieve parent items, or multiple
calls to `Get-HardwareSetting` when a single call already retrieves all general settings.

```powershell linenums="1"
foreach ($recorder in Get-VmsRecordingServer) {
    foreach ($hardware in $recorder | Get-VmsHardware) {
        $hardwareSettings = $hardware | Get-HardwareSetting
        foreach ($camera in $hardware | Get-VmsCamera) {
            [pscustomobject]@{
                Name     = $camera.Name
                Model    = $hardware.Model
                IP       = ([uri]$hardware.Address).Host
                MAC      = $hardwareSettings.MacAddress
                Firmware = $hardwareSettings.FirmwareVersion
                Recorder = $recorder.Name
            }
        }
    }
}
```

And to make things even easier on "future you", you can make this a function and put it into your `$Profile` so that
it's always at your fingertips...

```powershell title="C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" linenums="1"
function Get-MyCameraInfo {
    foreach ($recorder in Get-VmsRecordingServer) {
        foreach ($hardware in $recorder | Get-VmsHardware) {
            $hardwareSettings = $hardware | Get-HardwareSetting
            foreach ($camera in $hardware | Get-VmsCamera) {
                [pscustomobject]@{
                    Name     = $camera.Name
                    Model    = $hardware.Model
                    IP       = ([uri]$hardware.Address).Host
                    MAC      = $hardwareSettings.MacAddress
                    Firmware = $hardwareSettings.FirmwareVersion
                    Recorder = $recorder.Name
                }
            }
        }
    }
}
```

Once the function is in your profile, you can use it from any Windows PowerShell session on that computer with...

```powershell
Get-MyCameraInfo | Export-Csv ~\report.csv -NoTypeInformation
```

## How do I "Replace Hardware" in bulk?

Sometimes it's necessary to force XProtect to "re-discover" a camera and its capabilities, even if the camera and the
device pack driver haven't changed. The "click-ops" method is to open Management Client, find the hardware under the
**Recording Servers** section, right-click on one of the "hardware" in the tree, and then click **Replace Hardware**.

In PowerShell, we can do this using the `#!powershell Set-VmsHardwareDriver` cmdlet.

!!! tip
    Add `-Confirm:$false` when calling `Set-VmsHardwareDriver` if you want to avoid being prompted to confirm you want
    to proceed. For example...

    ```powershell
    Get-VmsHardware | Where-Object Model -match 'Axis' | Set-VmsHardwareDriver -Confirm:$false
    ```

### Replace hardware on all cameras

This will run a simple "replce hardware" on every camera from every recording server.

```powershell linenums="1"
Get-VmsHardware | Set-VmsHardwareDriver
```

### Replace hardware on all cameras on a specific recording server

This will run a simple "replace hardware" on every camera added to the recording server named "Recorder1"

```powershell title="Named recording server" linenums="1"
Get-VmsRecordingServer -Name Recorder1 | Get-VmsHardware | Set-VmsHardwareDriver
```

```powershell title="Select one or more recording servers" linenums="1"
$recorders = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorders | Get-VmsHardware | Set-VmsHardwareDriver
```

### Replace hardware only for Axis cameras

This will run "replace hardware" on all cameras with the word "Axis" in the hardware `Model` property.

```powershell linenums="1"
$hardware = Get-VmsHardware | Where-Object Model -match 'Axis'
$hardware | Set-VmsHardwareDriver
```

