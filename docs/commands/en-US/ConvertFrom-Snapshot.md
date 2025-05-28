---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/ConvertFrom-Snapshot/
schema: 2.0.0
---

# ConvertFrom-Snapshot

## SYNOPSIS

Converts from the output provided by Get-Snapshot to a \[System.Drawing.Image\] object.

## SYNTAX

```
ConvertFrom-Snapshot [-Content] <Byte[]> [<CommonParameters>]
```

## DESCRIPTION

Converts from the output provided by Get-Snapshot to a \[System.Drawing.Image\] object.
Don't forget to call Dispose() on Image when you're done with it!

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$image = Select-Camera | Get-Snapshot -Live | ConvertFrom-Snapshot
$image.Size
```

Get's a live snapshot from the camera selected from the camera selection dialog, converts it
to a System.Drawing.Image object and saves it to $image

## PARAMETERS

### -Content

Specifies an array of bytes as is returned by `Get-Snapshot`

```yaml
Type: Byte[]
Parameter Sets: (All)
Aliases: Bytes

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Accepts a byte array, and will accept the byte array from Get-Snapshot by property name. The property name for

### Accepts a byte array, and will accept the byte array from Get-Snapshot by property name. The property name for

### Accepts a byte array, and will accept the byte array from Get-Snapshot by property name. The property name for

## OUTPUTS

### [System.Drawing.Image]

### [System.Drawing.Image]

Don't forget to call Dispose() when you're done with the image!

## NOTES

## RELATED LINKS
