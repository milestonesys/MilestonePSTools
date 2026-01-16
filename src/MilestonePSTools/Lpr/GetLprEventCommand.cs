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

using MilestonePSTools.Events;
using MilestonePSTools.Utility;
using System;
using System.Collections.Generic;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.Alarm;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Get, "VmsLprEvent")]
    [OutputType(typeof(EventLine))]
    [RequiresVmsConnection()]
    public class GetLprEventCommand : ConfigApiCmdlet
    {
        [Parameter()]
        [Alias("ObjectValue", "Plate")]
        public string RegistrationNumber { get; set; }

        [Parameter()]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        [Alias("Message")]
        public string MatchList { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        [Alias("Id")]
        public Guid CameraId { get; set; }

        [Parameter()]
        public DateTime StartTime { get; set; } = DateTime.Now.AddHours(-1);

        [Parameter()]
        public DateTime EndTime { get; set; } = DateTime.Now;

        protected override void ProcessRecord()
        {
            var conditions = new List<Condition>
            {
                new Condition { Target = Target.Type, Operator = Operator.Equals, Value = "LPR Event" },
                new Condition { Target = Target.Timestamp, Operator = Operator.GreaterThan, Value = StartTime.ToUniversalTime() },
                new Condition { Target = Target.Timestamp, Operator = Operator.LessThan, Value = EndTime.ToUniversalTime() },
            };
            if (MyInvocation.BoundParameters.ContainsKey(nameof(RegistrationNumber)))
            {
                conditions.Add(new Condition { Target = Target.ObjectValue, Operator = Operator.Contains, Value = RegistrationNumber });
            }
            if (MyInvocation.BoundParameters.ContainsKey(nameof(MatchList)))
            {
                conditions.Add(new Condition { Target = Target.Message, Operator = Operator.Contains, Value = MatchList });
            }
            if (MyInvocation.BoundParameters.ContainsKey(nameof(CameraId)))
            {
                conditions.Add(new Condition { Target = Target.ObjectId, Operator = Operator.Equals, Value = CameraId });
            }
            
            using (var reader = new EventLineReader(Connection.CurrentSite.FQID.ServerId))
            {
                reader.Conditions = conditions.ToArray();
                reader.OrderBy = new OrderBy[] { new OrderBy { Target = Target.Timestamp, Order = Order.Ascending } };
                foreach (var record in reader.GetEvents())
                {
                    WriteObject(record);
                }
            }
        }
    }
}

