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

using MilestonePSTools.Utility;
using System;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.EventCommands
{
    [Cmdlet(VerbsCommon.Get, nameof(UserDefinedEvent), DefaultParameterSetName = "ByName")]
    [OutputType(typeof(UserDefinedEvent))]
    [RequiresVmsConnection()]
    public class GetUserDefinedEvent : ConfigApiCmdlet
    {
        [Parameter(Position = 1, ParameterSetName = "ByName")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<UserDefinedEvent>))]
        public string Name { get; set; } = "*";

        [Parameter(Position = 2, ParameterSetName = "ById")]
        public Guid Id { get; set; }

        protected override void ProcessRecord()
        {
            var ms = Connection.ManagementServer;
            if (ParameterSetName == "ById")
            {
                WriteObject(ms.UserDefinedEventFolder.UserDefinedEvents.Single(e => e.Id.Equals(Id.ToString(), StringComparison.OrdinalIgnoreCase)));
            }
            else
            {
                var pattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
                var matches = ms.UserDefinedEventFolder.UserDefinedEvents.Where(e => pattern.IsMatch(e.Name));
                foreach (var match in matches)
                {
                    WriteObject(match);
                }
            }
        }
    }
}

