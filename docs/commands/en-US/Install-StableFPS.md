---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Install-StableFPS/
schema: 2.0.0
---

# Install-StableFPS

## SYNOPSIS

Install the StableFPS driver on a Recording Server

## SYNTAX

```
Install-StableFPS [[-Source] <String>] [[-Cameras] <Int32>] [[-Streams] <Int32>] [[-DevicePackPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The StableFPS driver is used to add any number of virtual cameras simulated from static video files.
It includes support for multiple video codecs, audio, metadata, input and output.
See the Milestone
MIP SDK documentation for more information.

This command must be run with elevated permissions due to the fact it must add/modify files in the
Device Pack installation path which is typically placed in the protected C:\Program Files (x86)\ path.
It also must stop and start the Recording Server service in order for the new driver to be made available.

If you re-install the StableFPS driver with different parameters, or if you add new video/audio to the
%DevicePackPath%\StableFPS_DATA folder, you will need to perform "Replace Hardware" on each StableFPS
hardware device you require to use the new settings/media.

REQUIREMENTS  

- Does not require a VMS connection
- Requires elevated privileges (run as Administrator)

## EXAMPLES

### EXAMPLE 1

```powershell
Install-StableFPS -Source C:\StableFPS -Cameras 4 -Streams 2
```

Installs the StableFPS driver from the source already present at C:\StableFPS.
Each StableFPS device added
to the Recording Server will have 4 camera channels, each with the option of up to 2 streams.

## PARAMETERS

### -Cameras

Each StableFPS hardware device can have between 1 and 200 camera channels associated with it.
The default
value is 32.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 32
Accept pipeline input: False
Accept wildcard characters: False
```

### -DevicePackPath

By default the DevicePackPath will be determined from the Get-RecorderConfig cmdlet which assumes the
StableFPS driver is intended to be installed on the local machine which is also a Recording Server.
In
some cases you may wish to install the StableFPS driver to a remote machine.
If this property is provided,
then the driver will be deployed to the path without attempting to restart any Recording Server service or
validating the presence of a Recording Server installation.
It will then be your responsibility to restart
the remote Recording Server to make the new driver available.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

The path to the StableFPS folder included with the MIP SDK installation.
The default path is
"C:\Program Files\Milestone\MIPSDK\Tools\StableFPS".
To execute this command on a system without MIP
SDK installed, make sure to copy the StableFPS folder to a path available to the target system.
If you
specify "-Path C:\StableFPS" then this command expects to find the folders C:\StableFPS\StableFPS_DATA and
C:\StableFPS\vLatest

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: C:\Program Files\Milestone\MIPSDK\Tools\StableFPS
Accept pipeline input: False
Accept wildcard characters: False
```

### -Streams

Each camera channel can provide up to 5 streams.
By default, each channel will provide only one stream.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
