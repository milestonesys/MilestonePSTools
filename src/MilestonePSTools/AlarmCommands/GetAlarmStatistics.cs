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
using System.Management.Automation;
using VideoOS.Platform.Proxy.Alarm;
using VideoOS.Platform.Proxy.AlarmClient;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Gets alarm statistics from the Event Server which provides the number of alarms in each state.</para>
    /// <para type="description">Gets the number of alarms in each state. The values are estimates as the statistics are not updated on demand.</para>
    /// <para type="description">The built-in alarm state values are New=1, In progress=4, On hold=9 and Closed=11. Administrators may add additional states in Management Client.</para>
    /// <para type="description">In the resulting Statistic[] object, the Statistic.Number property represents the State and the Statistic.Value property represents the number of alarms in that state.</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "AlarmStatistics")]
    [OutputType(typeof(Statistic[]))]
    [RequiresVmsConnection()]
    public class GetAlarmStatistics : ConfigApiCmdlet, IDisposable
    {
        private AlarmClientManager _alarmClientManager;
        private IAlarmClient _alarmClient;

        /// <summary>
        /// 
        /// </summary>
        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            WriteVerbose("Creating an instance of IAlarmClient");
            _alarmClientManager = new AlarmClientManager();
            _alarmClient = _alarmClientManager.GetAlarmClient(Connection.CurrentSite.FQID.ServerId);
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteObject(_alarmClient.GetStatistics());
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void EndProcessing()
        {
            base.EndProcessing();
            WriteVerbose("Closing IAlarmClient instance");
            Dispose();
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void StopProcessing()
        {
            base.StopProcessing();
            Dispose();
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
            _alarmClient?.CloseClient();
            _alarmClient = null;
        }
    }
}


