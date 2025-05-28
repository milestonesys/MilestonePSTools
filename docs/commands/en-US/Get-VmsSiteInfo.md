---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsSiteInfo/
schema: 2.0.0
---

# Get-VmsSiteInfo

## SYNOPSIS
Gets one or more site information fields.

## SYNTAX

```
Get-VmsSiteInfo [[-Property] <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet gets the site information values. Each line of information is returned
as pscustomobject with a DisplayName, Property, and Value property.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsSiteInfo

<# OUTPUT
  DisplayName       Property        Value
  -----------       --------        -----
  Address - Name    address.Name    Milestone Systems
  Address - Address address.Address 5300 Meadows Rd STE 400
  Address - Address address.Address Lake Oswego, OR 97035
  Address - Country address.Country United States
  Address - Phone   address.Phone   +1 503-350-1100
#>
```

After logging in to the Management Server, this example returns all site information.
This information could be piped directly to a CSV file and then imported on a different
site if you have many sites that you manage. See the next example for inspiration.

### Example 1
```powershell
# Export current site's site info to csv
Get-VmsSiteInfo | Export-Csv ~\Desktop\siteinfo.csv

# Update the site info on a different site
Clear-VmsSiteInfo -Verbose
Import-Csv ~\Desktop\siteinfo.csv | Set-VmsSiteInfo -Append -Verbose
```

This example shows how you might export the site information, and then import
that information on a different site. On the new site, we first use
Clear-VmsSiteInfo to ensure that we don't add new data to existing site info
properties. Then we import the rows from the csv file which as the columns
"DisplayName", "Property", and "Value" by default because that is the name of
the properties returned by Get-VmsSiteInfo.

## PARAMETERS

### -Property
Specifies the property name to get. The default is to return all values.

The values as of 2022 R2 are: address.Name, address.Address, address.State,
address.Phone, address.Country, address.ZipCode, admin.Name, admin.Address,
admin.Phone, additional.AdditionalInfo

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSCustomObject

## NOTES

## RELATED LINKS
