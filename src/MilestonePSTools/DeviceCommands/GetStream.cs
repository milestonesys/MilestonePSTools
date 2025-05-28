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

using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Get, "Stream", DefaultParameterSetName = "LiveDefault")]
    [OutputType(typeof(StreamUsageChildItem))]
    [RequiresVmsConnection()]
    public class GetStream : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "LiveDefault")]
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "Recorded")]
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "All")]
        public Camera Camera { get; set; }

        [Parameter(Position = 1, ParameterSetName = "LiveDefault")]
        public SwitchParameter LiveDefault { get; set; }

        [Parameter(Position = 2, Mandatory = true, ParameterSetName = "Recorded")]
        public SwitchParameter Recorded { get; set; }

        [Parameter(Position = 3, Mandatory = true, ParameterSetName = "All")]
        public SwitchParameter All { get; set; }

        [Parameter(Position = 4)]
        public SwitchParameter StreamIds { get; set; }


        protected override void ProcessRecord()
        {
            // Deprecated on 2022-01-18
            WriteWarning("This command is deprecated. Please use Get-VmsCameraStream instead.");
            var streams = new List<StreamUsageChildItem>();

            switch (ParameterSetName)
            {
                case "LiveDefault":
                {
                    streams.Add(Camera.StreamFolder.Streams.First().StreamUsageChildItems.First(s => s.LiveDefault));
                    break;
                }
                case "Recorded":
                {
                    streams.Add(Camera.StreamFolder.Streams.First().StreamUsageChildItems.First(s => s.Record));
                    break;
                }
                case "All":
                {
                    streams.AddRange(Camera.StreamFolder.Streams.First().StreamUsageChildItems);
                    break;
                }
            }

            foreach (var stream in streams)
            {
                if (StreamIds.IsPresent)
                {
                    foreach (var kvp in stream.StreamReferenceIdValues)
                    {
                        WriteObject(new {kvp.Key, kvp.Value});
                    }
                }
                else
                {
                    WriteObject(stream);
                }
            }
        }
    }
}

