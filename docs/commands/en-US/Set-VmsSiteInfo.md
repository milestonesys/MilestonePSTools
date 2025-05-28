---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsSiteInfo/
schema: 2.0.0
---

# Set-VmsSiteInfo

## SYNOPSIS
Sets the value for one Site Information property such as name, address, or administrator contact number.

## SYNTAX

```
Set-VmsSiteInfo [-Property] <String> [-Value] <String> [-Append] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is used to add or update values displayed in the Management Client under Site / Basics / Site Information,
just under the License Information node.

There are several predefined property names with keys like "address.Name", and the VMS allows you to add one or more values
for the same field. For example, you could add multiple entries, or lines, for address, or phone number. Each line can
be up to 256 characters in length.

The lines are returned by Get-VmsSiteInfo and displayed in the Management Client in the order they were created. If you
want to add a second value for a given property, you can include the `-Append` switch (see the examples.)

In order for this command to remain flexible in the event the available fields change in the future, the parameters are
simplified and accept a property name, and a value. The valid property names are available with tab or list completion,
so you may type "-Property " and then press tab, or CTRL+Space, and the supported property names will be displayed. The
currently available values as of XProtect VMS version 2022 R2 are...

address.Name, address.Address, address.State, address.Phone, address.Country, address.ZipCode, admin.Name,
admin.Address, admin.Phone, additional.AdditionalInfo

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Clear-VmsSiteInfo -Verbose
Set-VmsSiteInfo -Property address.Name -Value 'Milestone Systems' -Verbose
Set-VmsSiteInfo -Property address.Address -Value '5300 Meadows Rd STE 400' -Verbose
Set-VmsSiteInfo -Property address.Address -Value 'Lake Oswego, OR 97035' -Append -Verbose
Set-VmsSiteInfo -Property address.Country -Value 'United States' -Verbose
Set-VmsSiteInfo -Property address.Phone -Value '+1 503-350-1100' -Verbose
```

After connecting to the Management Server, we clear the site information and set the name, address, and phone number
for the site. Notice that instead of using the address.State and address.ZipCode fields, we chose to enter the city,
state and zipcode as a second address.Address property by including the -Append switch. Without the -Append switch, the
second address.Address value would have replaced the first.

### Example 2
```powershell
# Export current site's site info to csv
Get-VmsSiteInfo | Export-Csv ~\Desktop\siteinfo.csv

# Update the site info on a different site to be identical
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

### -Append
Specifies that if a value already exists for the specified Property, an
additional line should be added for the same property name. This allows you to
have two Address lines, and more than one phone number associated with a site.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Property
Specifies the property name to add or update. The available property names are
dynamically discovered from the Management Server and provided as argument
completions using tab, or CTRL+Space.

The values as of 2022 R2 are: address.Name, address.Address, address.State,
address.Phone, address.Country, address.ZipCode, admin.Name, admin.Address,
admin.Phone, additional.AdditionalInfo

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

### -Value
Specifies the value for the given property name. The value can be any string up
to 256 characters in length.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
