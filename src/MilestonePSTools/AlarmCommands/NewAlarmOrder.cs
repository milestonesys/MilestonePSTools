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

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Creates a new OrderBy object which is used when working with and filtering alarms.</para>
    /// <para type="description">One or more OrderBy objects can be used in an AlarmFilter to specify the order of
    /// alarms to be returned.</para>
    /// <example>
    ///     <code>C:\PS>$order = New-AlarmOrder -Order Descending -Target SourceName</code>
    ///     <para>Create a new OrderBy object to specify that alarms should be sorted by SourceName in descending order.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.New, "AlarmOrder")]
    [OutputType(typeof(OrderBy))]
    [RequiresVmsConnection(false)]
    public class NewAlarmOrder : PSCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the order as either Ascending or Descending. Default is Ascending.</para>
        /// </summary>
        [Parameter]
        [ValidateSet("Ascending", "Descending")]
        public string Order { get; set; } = VideoOS.Platform.Proxy.Alarm.Order.Ascending.ToString();

        /// <summary>
        /// <para type="description">Specifies the target AlarmLine property to be sorted. Default is Timestamp.</para>
        /// </summary>
        [Parameter]
        [ValidateSet("AssignedTo", "CameraId", "Category", "CategoryName", "CustomTag", "Description", "Id", "LocalId", "Location", "Message", "Modified", "Name", "ObjectId", "ObjectValue", "Priority", "PriorityName", "RuleType", "SourceName", "State", "StateName", "Timestamp", "Type", "VendorName")]
        public string Target { get; set; } = VideoOS.Platform.Proxy.Alarm.Target.Timestamp.ToString();

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            var orderBy = new OrderBy
            {
                Order = (Order) Enum.Parse(typeof(Order), Order),
                Target = (Target) Enum.Parse(typeof(Target), Target)
            };
            WriteObject(orderBy);
        }
    }
}
