// Copyright 2025 Milestone Systems A/S
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System;
using System.Collections;
using System.Diagnostics;
using System.Management.Automation;
using VideoOS.Platform.Log;

namespace MilestonePSTools.Commands
{
    [Cmdlet(VerbsCommon.Get, "VmsLog", DefaultParameterSetName = "TimestampFilter")]
    [Alias("Get-Log")]
    [OutputType(typeof(PSObject))]
    [RequiresVmsConnection()]
    public class GetLog2 : ConfigApiCmdlet
    {
        [Parameter(Position = 1, ParameterSetName = "TimestampFilter")]
        [Parameter(Position = 2, ParameterSetName = "Tail")]
        [ValidateSet(validValues: new[] { "System", "Audit", "Rules" }, IgnoreCase = true)]
        public string LogType { get; set; } = "System";

        [Parameter(Position = 3, ParameterSetName = "TimestampFilter")]
        [Alias("BeginTime")]
        public DateTime StartTime { get; set; } = DateTime.UtcNow.AddHours(-24);

        [Parameter(Position = 4, ParameterSetName = "TimestampFilter")]
        public DateTime EndTime { get; set; } = DateTime.UtcNow;

        [Parameter(Position = 5, Mandatory = true, ParameterSetName = "Tail")]
        public SwitchParameter Tail { get; set; }

        [Parameter(Position = 6, ParameterSetName = "Tail")]
        public long Minutes { get; set; } = 60;

        [Parameter(Position = 7)]
        public string Culture { get; set; }

        protected override void BeginProcessing()
        {
          base.BeginProcessing();
          if (string.IsNullOrEmpty(Culture))
          {
            Culture = System.Globalization.CultureInfo.CurrentCulture.Name;
          }
          LogClient.Instance.Close(Connection.CurrentSite.FQID.ServerId.Id);
          LogClient.Instance.SetCulture(Culture);
        }

        protected override void ProcessRecord()
        {
            if (MyInvocation.InvocationName.Equals("Get-Log", StringComparison.CurrentCultureIgnoreCase))
            {
                WriteWarning("The Get-Log command is deprecated. For compatibility purposes it is temporarily aliased to Get-VmsLog.");
            }

            if (Tail)
            {
                StartTime = EndTime.AddMinutes(Math.Abs(Minutes) * -1);
            }
            else
            {
                StartTime = StartTime.ToUniversalTime();
            }
            EndTime = EndTime.ToUniversalTime();
            if (StartTime >= EndTime)
            {
                throw new InvalidOperationException("EndTime must be greater than StartTime.");
            }
            var totalTicks = EndTime.Ticks - StartTime.Ticks;
            var minWindow = TimeSpan.FromMinutes(1);
            var maxWindow = TimeSpan.FromMinutes(60);
            var maxWindowInterval = TimeSpan.FromMinutes(5);
            var window = TimeSpan.FromMinutes(10);
            var windowStart = StartTime;
            var windowEnd = new DateTime(Math.Min(EndTime.Ticks, windowStart.Add(window).Ticks));
            var progressRecord = new ProgressRecord(0, $"Reading {LogType} log", $"Range: {StartTime.ToLocalTime()} to {EndTime.ToLocalTime()}");
            var overallStopWatch = Stopwatch.StartNew();
            var stopWatch = Stopwatch.StartNew();
            try
            {
                var logClient = LogClient.Instance;
                ArrayList result = null;
                ArrayList headers = null;
                ArrayList entry = null;
                var page = 1;
                var logsInRange = 0;
                var readNextPage = false;
                do
                {
                    stopWatch.Restart();
                    page = 1;
                    logsInRange = 0;
                    do
                    {
                        progressRecord.PercentComplete = (int)((windowStart.Ticks - StartTime.Ticks) / (decimal)totalTicks * 100.0m);
                        if (overallStopWatch.Elapsed > minWindow)
                        {
                            progressRecord.SecondsRemaining = (int)(100.0d / progressRecord.PercentComplete * overallStopWatch.Elapsed.TotalSeconds);
                        }

                        WriteProgress(progressRecord);
                        logClient.ReadLog(Connection.CurrentSite.FQID.ServerId, page++, out result,
                            out headers, LogType, windowStart, windowEnd);
                        for (var r = result.Count - 1; r > -1; r--)
                        {
                            entry = result[r] as ArrayList;
                            var record = new PSObject();
                            for (var i = 1; i < entry.Count; i++)
                            {
                                record.Properties.Add(
                                    new PSVariableProperty(
                                        new PSVariable(headers[i - 1] as string, entry[i] as string)));
                            }
                            WriteObject(record);
                        }
                        logsInRange += result.Count;
                        readNextPage = result.Count == 1000;
                    } while (readNextPage);
                    var logsPerSecond = logsInRange / (windowEnd - windowStart).TotalSeconds;
                    if (logsInRange > 2000)
                    {
                        window = TimeSpan.FromSeconds((1000 / logsPerSecond));
                        window = window < minWindow ? minWindow : window;
                    }
                    else if (logsInRange < 500)
                    {
                        window = window.Add(maxWindowInterval);
                        window = window > maxWindow ? maxWindow : window;
                    }

                    windowStart = windowEnd.AddMilliseconds(1);
                    windowEnd = new DateTime(Math.Min(EndTime.Ticks, windowStart.Add(window).Ticks));
                } while (windowStart < windowEnd);
            }
            catch (PipelineStoppedException)
            {
                throw;
            }
            catch (Exception ex)
            {
                WriteExceptionError(ex);
            }
            finally
            {
                progressRecord.PercentComplete = 100;
                progressRecord.RecordType = ProgressRecordType.Completed;
                WriteProgress(progressRecord);
            }
        }
    }
}

