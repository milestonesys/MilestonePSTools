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

using MilestoneLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.PermissionCommands
{
    [Cmdlet(VerbsCommon.Get, nameof(DeviceAcl))]
    [OutputType(typeof(DeviceAcl))]
    [RequiresVmsConnection()]
    public class GetDeviceAcl : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromCamera")]
        public Camera Camera { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromMicrophone")]
        public Microphone Microphone { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromSpeaker")]
        public Speaker Speaker { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromInput")]
        public InputEvent Input { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromOutput")]
        public Output Output { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromMetadata")]
        public Metadata Metadata { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromHardware")]
        public Hardware Hardware { get; set; }

        [Parameter(Position = 1)]
        public string RoleName { get; set; }

        [Parameter]
        public Guid? RoleId { get; set; }

        [Parameter]
        public Role Role { get; set; }

        protected override void ProcessRecord()
        {
            var ms = Connection.ManagementServer;
            var roleNameFilter = new WildcardPattern(RoleName ?? "*", WildcardOptions.IgnoreCase);
            var role = Role ?? (RoleId.HasValue
                           ? new Role(Connection.CurrentSite.FQID.ServerId, $"Role[{RoleId.Value}]")
                           : ms.RoleFolder.Roles.Single(r => roleNameFilter.IsMatch(r.Name)));

            if (ParameterSetName == "FromHardware")
            {
                var devices = new List<object>();
                devices.AddRange(Hardware.CameraFolder.Cameras);
                devices.AddRange(Hardware.MicrophoneFolder.Microphones);
                devices.AddRange(Hardware.SpeakerFolder.Speakers);
                devices.AddRange(Hardware.MetadataFolder.Metadatas);
                devices.AddRange(Hardware.InputEventFolder.InputEvents);
                devices.AddRange(Hardware.OutputFolder.Outputs);
                foreach (var device in devices)
                {
                    WriteObject(AclHelpers.GetAcl(device, role));
                }
            }
            else
            {
                var device = GetDeviceBasedOnParameterSet();
                WriteObject(AclHelpers.GetAcl(device, role));
            }
        }

        private object GetDeviceBasedOnParameterSet()
        {
            object device = null;
            switch (ParameterSetName)
            {
                case "FromCamera":
                    device = Camera;
                    break;
                case "FromMicrophone":
                    device = Microphone;
                    break;
                case "FromSpeaker":
                    device = Speaker;
                    break;
                case "FromInput":
                    device = Input;
                    break;
                case "FromOutput":
                    device = Output;
                    break;
                case "FromMetadata":
                    device = Metadata;
                    break;
            }

            return device;
        }
    }
}

