---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/ConvertTo-GisPoint/
schema: 2.0.0
---

# ConvertTo-GisPoint

## SYNOPSIS

Translates coordinates to a Milestone GisPoint value suitable for updating GPS coordinates on a Milestone device.

## SYNTAX

### FromGeoCoordinate
```
ConvertTo-GisPoint -Coordinate <GeoCoordinate> [<CommonParameters>]
```

### FromValues
```
ConvertTo-GisPoint -Latitude <Double> -Longitude <Double> [-Altitude <Double>] [<CommonParameters>]
```

### FromString
```
ConvertTo-GisPoint -Coordinates <String> [<CommonParameters>]
```

## DESCRIPTION

GPS coordinates in Milestone are stored an X,Y order in the format "POINT (X Y)".
As such, if you have a latitude and longitude value, you must reverse them and
format them properly for Milestone to accept the new GisPoint value.

In some cases, the GisPoint property can have a third value representing altitude
or elevation. This is expressed in the format "POINT (X Y Z)".

If the Coordinate object, Coordinates string, or Altitude value are provided, then
the cmdlet will output a three-part GisPoint value.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-GisPoint -Coordinates '40, -122'
```

Produces a string like "POINT (-122 40)"

### EXAMPLE 2

```powershell
ConvertTo-GisPoint -Latitude 40 -Longitude -122
```

Produces a string like "POINT (-122 40)"

### EXAMPLE 3

```powershell
ConvertTo-GisPoint -Latitude 40 -Longitude -122 -Altitude 125
```

Produces a string like "POINT (-122 40 125)"

### EXAMPLE 4

```powershell
ConvertTo-GisPoint -Coordinates '40, -122, 125'
```

Produces a string like "POINT (-122 40 125)"

## PARAMETERS

### -Altitude
Specifies the altitude in meters, relative to sea level.

```yaml
Type: Double
Parameter Sets: FromValues
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Coordinate

A GeoCoordinate object with Latitude and Longitude properties.

```yaml
Type: GeoCoordinate
Parameter Sets: FromGeoCoordinate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Coordinates

A coordinate written in the format "latitude, longitude", or "latitude, longitude, altitude".

```yaml
Type: String
Parameter Sets: FromString
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Latitude

A latitude value in the form of a double.

```yaml
Type: Double
Parameter Sets: FromValues
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Longitude

A longitude value in the form of a double.

```yaml
Type: Double
Parameter Sets: FromValues
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
