---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsLprMatchListEntry/
schema: 2.0.0
---

# Add-VmsLprMatchListEntry

## SYNOPSIS
Adds or updates a registration number with optional custom fields on an LPR match list.

## SYNTAX

### Name (Default)
```
Add-VmsLprMatchListEntry [-Name] <String> -RegistrationNumber <String> [-CustomFields <Hashtable>] [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject
```
Add-VmsLprMatchListEntry -InputObject <LprMatchList> -RegistrationNumber <String> [-CustomFields <Hashtable>]
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Add-VmsLprMatchListEntry` cmdlet adds, or updates a registration number with optional custom fields on an LPR
match list. The match list can be provided by name, or by providing a match list object returned by
`Get-VmsLprMatchList`.

If a hashtable is provided with custom field names and values, they will be matched to existing custom fields using a
case-insensitive comparison. If no matching custom field already exists on the match list, you can force new fields to
be created using the `-Force` switch.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
New-VmsLprMatchList -Name Tenants
Add-VmsLprMatchListEntry -Name Tenants -RegistrationNumber B675309
```

This example creates a match list named "Tenants" if it does not already exist, then adds a registration number to the
list by name.

### Example 2
```powershell
$list = New-VmsLprMatchList -Name Tenants
$list | Add-VmsLprMatchListEntry -RegistrationNumber B675309
```

This example is the same as the previous example, except creates a match list named "Tenants" if it does not already
exist, then adds a registration number to the list by piping the match list object to `Add-VmsLprMatchListEntry`.

### Example 3
```powershell
$list = New-VmsLprMatchList -Name Tenants
$customFields = @{
    Driver = 'Tommy'
    Color  = 'Red'
    Year   = 1981
}
$list | Add-VmsLprMatchListEntry -RegistrationNumber B675309 -CustomFields $customFields -Force
$list | Get-VmsLprMatchListEntry -RegistrationNumber B675309
```

This example expands on the previous examples by demonstrating how to add custom fields related to a registration
number. Thanks to the presence of the `-Force` switch, the "Driver", "Color", and "Year" fields will be added to the
match list if not already present.

## PARAMETERS

### -CustomFields
A hashtable with a set of custom fields associated with the registration number. If the provided custom field names do
not already exist, you can create them automatically by including `-Force` switch. Custom field names are case-sensitive
in the VMS, but this cmdlet will perform a case-insensitive comparison. So if you have a custom field named "Color" and
you supply a hashtable with a key named "color", the value will be stored in the "Color" field.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that if any keys in the `CustomFields` hashtable do not exist, they should be created.

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

### -InputObject
Specifies an `LprMatchList` object as returned by `Get-VmsLprMatchList`.

```yaml
Type: LprMatchList
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies the name of an existing LPR match list.

```yaml
Type: String
Parameter Sets: Name
Aliases: MatchList

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RegistrationNumber
Specifies a license plate registration number.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### VideoOS.Platform.ConfigurationItems.LprMatchList

### System.String

### System.Collections.Generic.IDictionary`2[[System.Object, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.Object, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
