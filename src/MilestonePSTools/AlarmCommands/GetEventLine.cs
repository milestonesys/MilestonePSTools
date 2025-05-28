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
    /// <para type="synopsis">Gets Events from the Event Server</para>
    /// <para type="description">Gets a list of Events from the Event Server using the AlarmCommandClient / IAlarmCommand interface.</para>
    /// <example>
    ///     <code>
    /// PS C:\> $c = New-AlarmCondition -Target Timestamp -Operator GreaterThan -Value (Get-Date).Date.ToUniversalTime()
    /// PS C:\> $order = New-AlarmOrder -Order Descending -Target Timestamp
    /// PS C:\> Get-EventLine -Conditions $c -SortOrders $order</code>
    ///     <para>Create Conditions to filter the EventLines to only those events with a timestamp occurring on or after midnight of the current day,
    ///     and order the results in descending order by time.</para>
    ///     <para>Note that the New-AlarmCondition and New-AlarmOrder cmdlets work for both Alarms and Events.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(EventLine), DefaultParameterSetName = "GetEventLines")]
    [OutputType(typeof(EventLine))]
    [RequiresVmsConnection()]
    public class GetEventLine : ConfigApiCmdlet, IDisposable
    {
        private AlarmClientManager _alarmClientManager;
        private IAlarmClient _alarmClient;

        /// <summary>
        /// <para type="description">Specifies the Guid of a single AlarmLine entry to be retrieved.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "Get", ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public Guid Id { get; set; }

        /// <summary>
        /// <para type="description">Specifies the AlarmFilter used to filter alarms to those having only the desired attributes. This is also used to specify how the output should be sorted.</para>
        /// <para type="description">By default the results will be unfiltered with no guaranteed order.</para>
        /// </summary>
        [Parameter(ParameterSetName = "GetEventLines")]
        public Condition[] Conditions { get; set; }

        /// <summary>
        /// <para type="description">Specifies the AlarmFilter used to filter alarms to those having only the desired attributes. This is also used to specify how the output should be sorted.</para>
        /// <para type="description">By default the results will be unfiltered with no guaranteed order.</para>
        /// </summary>
        [Parameter(ParameterSetName = "GetEventLines")]
        public OrderBy[] SortOrders { get; set; }

        /// <summary>
        /// <para type="description">Results are requested and returned in pages defined by a starting number and a PageSize</para>
        /// </summary>
        [Parameter(ParameterSetName = "GetEventLines")]
        [ValidateRange(0, int.MaxValue)]
        public int StartAt { get; set; } = 0;

        /// <summary>
        /// <para type="description">Each call to IAlarmCommand.GetAlarmLines returns a maximum number of results.</para>
        /// <para type="description">By default this module implements a page size of 100, but you may increase or decrease the page size to optimize for speed or memory consumption.</para>
        /// </summary>
        [Parameter(ParameterSetName = "GetEventLines")]
        [ValidateRange(1, int.MaxValue)]
        public int PageSize { get; set; } = 100;

        /// <summary>
        /// <para type="description">By default all alarms matching the given conditions will be returned.</para>
        /// <para type="description">Use this switch and the StartAt and PageSize parameters if you need control over pagination.</para>
        /// </summary>
        [Parameter(ParameterSetName = "GetEventLines")]
        public SwitchParameter SinglePage { get; set; }

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
            if (ParameterSetName == "Get")
            {
                WriteObject(_alarmClient.GetEvent(Id));
            }
            else
            {
                var filter = new EventFilter()
                {
                    Conditions = Conditions,
                    Orders = SortOrders
                };
                var index = StartAt;
                EventLine[] eventLines;
                do
                {
                    eventLines = _alarmClient.GetEventLines(index, PageSize, filter);
                    foreach (var eventLine in eventLines)
                    {
                        WriteObject(eventLine);
                    }

                    index += PageSize;
                } while (!SinglePage && eventLines.Length == PageSize);
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


