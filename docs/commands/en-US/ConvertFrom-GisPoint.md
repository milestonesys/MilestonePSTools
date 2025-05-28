---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/ConvertFrom-GisPoint/
schema: 2.0.0
---

# ConvertFrom-GisPoint

## SYNOPSIS

Converts Milestone's internal representation of a GPS coordinate to a \[System.Device.Location.GeoCoordinate\] object.

## SYNTAX

```
ConvertFrom-GisPoint [-GisPoint] <String> [<CommonParameters>]
```

## DESCRIPTION

Milestone stores GPS coordinates as X,Y coordinates on a standard coordinate plane.
For example, the coordinates
47.25726, -122.51608 are represented in Milestone as "POINT (-122.51608 47.25726)" where the latitude and longitude
are reversed.
An unset coordinate for a camera is represented as "POINT EMPTY".

This function converts Milestone's GisPoint property string into a \[System.Device.Location.GeoCoordinate\] object which
has a ToString() method which will properly format the coordinates.
If the coordinates are unset in Milestone, then you
will receive the same object but the position will be defined as "Unknown".

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Select-Camera | ConvertFrom-GisPoint
```

Opens a camera selection dialog and pipes the camera to ConvertFrom-GisPoint.
The GisPoint parameter accepts the value
from the pipeline by property name and the Camera object's coordinates are stored in a property with a matching name.

## PARAMETERS

### -GisPoint

Specifies the GisPoint value to convert to a GeoCoordinate.
Milestone stores GisPoint data in the format "POINT (\[longitude\] \[latitude\])" or "POINT EMPTY".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Device.Location.GeoCoordinate

## NOTES

## RELATED LINKS
