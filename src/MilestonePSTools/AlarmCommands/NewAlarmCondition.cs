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
    /// <para type="synopsis">Creates a new filter condition to specify which alarms should be returned in a query using Get-AlarmLines.</para>
    /// <para type="description">The IAlarmCommand.GetAlarmLines can be provided with an AlarmFilter containing conditions and sorting orders.</para>
    /// <para type="description">The cmdlet allows you to reduce the scope of the search for alarm lines.</para>
    /// <example>
    ///     <code>C:\PS>$condition = New-AlarmCondition -Operator NotEquals -Target StateName -Value Closed</code>
    ///     <para>Creates a condition which will ensure only alarms which are not closed will be returned.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.New, "AlarmCondition")]
    [OutputType(typeof(Condition))]
    [RequiresVmsConnection(false)]
    public class NewAlarmCondition : VmsCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the AlarmLine property to be used for this condition.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateSet("AssignedTo", "CameraId", "Category", "CategoryName", "CustomTag", "Description", "Id", "LocalId", "Location", "Message", "Modified", "Name", "ObjectId", "ObjectValue", "Priority", "PriorityName", "RuleType", "SourceName", "State", "StateName", "Timestamp", "Type", "VendorName")]
        public string Target { get; set; }

        /// <summary>
        /// <para type="description">Specifies the condition comparison operator such as 'BeginsWith' or 'Equals'.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateSet("BeginsWith", "Contains", "Equals", "GreaterThan", "LessThan", "NotEquals")]
        public string Operator { get; set; } = VideoOS.Platform.Proxy.Alarm.Operator.Equals.ToString();

        /// <summary>
        /// <para type="description">Specifies the AlarmLine property value to compare against.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public object Value { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteObject(new Condition
            {
                Operator = (Operator)Enum.Parse(typeof(Operator), Operator),
                Target = (Target)Enum.Parse(typeof(Target), Target),
                Value = Value
            });
        }
    }
}
