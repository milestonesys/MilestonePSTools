---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-EvidenceLock/
schema: 2.0.0
---

# Get-EvidenceLock

## SYNOPSIS

Gets evidence lock records matching the specified parameters.

## SYNTAX

```
Get-EvidenceLock [-DeviceIds <Guid[]>] [-SearchText <String>] [-Users <String[]>] [-CreatedFrom <DateTime>]
 [-CreatedTo <DateTime>] [-FootageFrom <DateTime>] [-FootageTo <DateTime>] [-ExpireFrom <DateTime>]
 [-ExpireTo <DateTime>] [-PageSize <Int32>] [-SortBy <String>] [-SortDecending] [<CommonParameters>]
```

## DESCRIPTION

The `Get-EvidenceLock` cmdlet gets evidence lock records matching the specified parameters.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "EvidenceLock"

## EXAMPLES

### Example 1

```powershell
Get-EvidenceLock
```

Returns all evidence lock records visible to the logged in VMS user account.

## PARAMETERS

### -CreatedFrom

Specifies that only evidence lock records with a "Created" timestamp on or after the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreatedTo

Specifies that only evidence lock records with a "Created" timestamp on or earlier than the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceIds

Specifies that only evidence lock records with one or more devices matching the provided Guid's should be returned.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireFrom

Specifies that only evidence lock records with an "Expiration" timestamp on or after the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireTo

Specifies that only evidence lock records with an "Expiration" timestamp on or earlier than the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FootageFrom

Specifies that only evidence lock records referencing recordings on or after the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FootageTo

Specifies that only evidence lock records referencing recordings on or earlier than the provided DateTime should be returned.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

Specifies the maximum number of evidence lock search results per page. The underlying API is paginated, and a larger page size may allow all records to be returned faster overall, but the first group of records returned may take longer with a larger page size. The default value is 100.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchText

Specifies that only evidence locks where the provided SearchText matches part of the header or description should be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy

Specifies the order of the returned results. Results are sorted by CreateTime by default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: CreateTime, Description, EndTime, Header, RetentionExpireTime, Size, StartTime, TagTime, UserName

Required: False
Position: Named
Default value: CreateTime
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDecending

Specifies that the results should be returned in descending order instead of ascending order.

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

### -Users

Specifies that only evidence lock records created by one of the provided users should be returned.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.MarkedData

## NOTES

## RELATED LINKS
