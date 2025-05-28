---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-IAlarmClient/
schema: 2.0.0
---

# Get-IAlarmClient

## SYNOPSIS

Gets a working IAlarmClient for making direct calls to the Event Server.

## SYNTAX

```
Get-IAlarmClient [<CommonParameters>]
```

## DESCRIPTION

Other Alarm cmdlets are wrappers for the commands you can send directly through the IAlarmClient interface.
If you need access to additional functionality not provided in the cmdlets, this cmdlet will give you direct access to the Event Server and the ability to query/send events and alarms.
Just remember to call CloseClient() when you're finished as this will not be done for you.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$client = Get-IAlarmClient
$client | Get-Member
```

Gets an IAlarmClient instance that can be used to interact directly with the
alarm and event features supported in MIP SDK.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Proxy.AlarmClient.IAlarmClient

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/interface_video_o_s_1_1_platform_1_1_proxy_1_1_alarm_client_1_1_i_alarm_client.html&tree=tree_search.html?search=ialarmclient)

