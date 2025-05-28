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
using System.Collections.Generic;
using System.Management.Automation;
using VideoOS.Platform.Proxy.Alarm;
using VideoOS.Platform.Proxy.AlarmClient;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Updates the provided properties on the alarm matching the given id.</para>
    /// <para type="description">Useful for automatically updating the state or other properties of alarms.</para>
    /// <para type="description">Following are the valid keys for the Updates hashtable:
    /// - "AssignedTo"
    /// - "Comment"
    /// - "Priority"
    /// - "PriorityInt"
    /// - "PriorityName"
    /// - "ReasonCode"
    /// - "State"
    /// - "StateInt"
    /// - "StateName"</para>
    /// <example>
    ///     <code>
    /// PS C:\> $c1 = New-AlarmCondition -Target State -Operator NotEquals -Value 11
    /// PS C:\> Get-AlarmLine -Conditions $c1 | Update-AlarmLine -Updates @{ StateName = 'Closed'; StateInt = '11' }</code>
    ///     <para>Get all alarms which are not marked as closed, and close them by updating their state</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>
    /// PS C:\> $c1 = New-AlarmCondition -Target Message -Operator Contains -Value "Tailgating"
    /// PS C:\> Get-AlarmLine -Conditions $c1 | Update-AlarmLine -Text "Investigation completed" -State 11</code>
    ///     <para>Get's alarms with a message containing the word 'Tailgating' and closes them with the comment 'Investigation completed'.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsData.Update, nameof(AlarmLine))]
    [RequiresVmsConnection()]
    public class UpdateAlarmLine : ConfigApiCmdlet, IDisposable
    {
        private AlarmClientManager _alarmClientManager;
        private IAlarmClient _alarmClient;
        private List<KeyValuePair<string, string>> _updates;
        private int _recordsUpdated;

        /// <summary>
        /// <para type="description">Specifies the Guid of a single AlarmLine entry to be updated.</para>
        /// </summary>
        [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public Guid[] Id { get; set; }

        /// <summary>
        /// <para type="description">Specifies the Guid of a single AlarmLine entry to be updated.</para>
        /// <para type="description">Valid property names are listed in the cmdlet description but no validation is performed before sending the request to the Event Server.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "UpdateAlarmValues")]
        public Hashtable Updates { get; set; }

        /// <summary>
        /// <para type="description">The text associated with this update which will be shown as a comment in the Alarm history.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "UpdateAlarm")]
        public string Text { get; set; }

        /// <summary>
        /// <para type="description">Specifies the new state of the alarm.</para>
        /// </summary>
        [Parameter(ParameterSetName = "UpdateAlarm")]
        public int State { get; set; }

        /// <summary>
        /// <para type="description">Specifies the new priority of the alarm.</para>
        /// </summary>
        [Parameter(ParameterSetName = "UpdateAlarm")]
        public int Priority { get; set; }

        /// <summary>
        /// <para type="description">Specifies the user to which the alarm should now be assigned.</para>
        /// </summary>
        [Parameter(ParameterSetName = "UpdateAlarm")]
        public string AssignedTo { get; set; }

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

            if (Updates != null)
            {
                _updates = new List<KeyValuePair<string, string>>();
                foreach (DictionaryEntry update in Updates)
                {
                    _updates.Add(new KeyValuePair<string, string>(update.Key.ToString(), update.Value.ToString()));
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            foreach (var id in Id)
            {
                WriteVerbose($"Updating alarm with ID {id}");
                switch (ParameterSetName)
                {
                    case "UpdateAlarmValues":
                        _alarmClient.UpdateAlarmValues(id, _updates.ToArray());
                        break;
                    case "UpdateAlarm":
                        _alarmClient.UpdateAlarm(id, Text, State, Priority, DateTime.UtcNow, AssignedTo);
                        break;
                }
                _recordsUpdated++;
                if (PassThru)
                {
                    WriteObject(_alarmClient.Get(id));
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void EndProcessing()
        {
            base.EndProcessing();
            WriteVerbose("Closing IAlarmClient instance");
            WriteVerbose($"Records updated: {_recordsUpdated}");
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
