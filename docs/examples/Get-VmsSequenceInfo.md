---
hide:
  - toc
---

# Get-VmsSequenceInfo

The `Get-VmsCameraReport` cmdlet can include the percentage of time recorded in the last 7 days when you use the
`-IncludeRecordingStats` switch, but what if you want more detailed information, or you want that information over the
previous month instead of the last week?

The `Get-SequenceData` cmdlet is what the `Get-VmsCameraReport` cmdlet uses, and this example function uses the same
command to help extract more detailed information with support for a user-defined start and end time, and type of
sequence (motion vs recording).

```plaintext linenums="1" title="Example output"
Camera          : AXIS P1465-LE Bullet Camera (172.16.128.163) - Camera 1
TimeSpan        : 03:00:00.0014893
PercentCoverage : 0.912366471501168
TotalCoverage   : 02:44:13.5592510
SequenceCount   : 2
MinimumGap      : 00:00:42.9290000
MaximumGap      : 00:15:03.5130000
AverageGap      : 00:07:53.2210000
GapCount        : 2
```

!!! note
    The `PercentCoverage` value is the percentage as a value between 0 and 1. So in this example, the percent of time
    recorded in the 3-hour timespan was ~91.2%.

[Download :material-download:](../scripts/Get-VmsSequenceInfo.ps1){ .md-button .md-button--primary }

## :material-powershell: Code

```powershell linenums="1" title="Get-VmsSequenceInfo.ps1"
--8<-- "scripts/Get-VmsSequenceInfo.ps1"
```

--8<-- "abbreviations.md"

