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
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.EventCommands
{
    [Cmdlet(VerbsCommon.Remove, nameof(UserDefinedEvent), DefaultParameterSetName = "ByName")]
    [RequiresVmsConnection()]
    public class RemoveUserDefinedEvent : ConfigApiCmdlet
    {
        [Parameter(Position = 1, Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromPipeline")]
        public UserDefinedEvent UserDefinedEvent { get; set; }

        [Parameter(Position = 2, Mandatory = true, ParameterSetName = "ByName")]
        public string Name { get; set; }

        [Parameter(Position = 3, Mandatory = true, ParameterSetName = "ById")]
        public Guid Id { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                var ms = Connection.ManagementServer;
                if (ParameterSetName == "ByName")
                {
                    var pattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
                    var events = ms.UserDefinedEventFolder.UserDefinedEvents.Where(e => pattern.IsMatch(e.Name));
                    foreach (var e in events)
                    {
                        ms.UserDefinedEventFolder.RemoveUserDefinedEvent(e.Path);
                    }
                }
                else
                {
                    ms.UserDefinedEventFolder.RemoveUserDefinedEvent(
                        UserDefinedEvent?.Path ?? $"UserDefinedEvent[{Id}]");
                }
            }
            catch (Exception ex)
            {
                WriteExceptionError(ex);
            }
        }
    }
}

