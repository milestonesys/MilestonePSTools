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
using VideoOS.Platform.Data;
using VideoOS.Platform.Proxy.AlarmClient;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Sends a new Alarm object to the Event Server.</para>
    /// <para type="description">A new alarm object can be created with New-Alarm, then after the properties are filled out as desired, you can send the alarm to the Event Server to create a new AlarmLine directly.</para>
    /// <example>
    ///     <code>
    /// PS C:\> $cameraItem = Get-VmsCamera -Id 948aa6a2-9a46-4c4c-8279-af0485428d75 | Get-PlatformItem
    /// PS C:\> $alarm = New-Alarm -Message "Important Alarm Message" -Source $cameraItem
    /// PS C:\> $alarm | Send-Alarm</code>
    ///     <para>Retrieves the Item object for Camera with the given Id and creates an Alarm with this camera as the source.</para>
    ///     <para>The Alarm object is then sent to the Event Server which generates a new alarm.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommunications.Send, nameof(Alarm))]
    [RequiresVmsConnection()]
    public class SendAlarm : ConfigApiCmdlet, IDisposable
    {
        private AlarmClientManager _alarmClientManager;
        private IAlarmClient _alarmClient;

        /// <summary>
        /// <para type="description">An alarm object to send to the Event Server through an AlarmClient instance.</para>
        /// <para type="description">Create an alarm with New-Alarm and fill out the properties before sending it.</para>
        /// </summary>
        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public Alarm Alarm { get; set; }

        /// <summary>
        /// <para type="description">Pass the alarm object back into the pipeline.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter PassThru { get; set; }

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
            WriteVerbose("Calling IAlarmClient.Add(alarm)");
            _alarmClient.Add(this.Alarm);
            if (PassThru)
            {
                WriteObject(this.Alarm);
            }
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
