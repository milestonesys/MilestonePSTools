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
using MilestonePSTools.Utility;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.PermissionCommands
{
    [Cmdlet(VerbsCommon.Get, nameof(DeviceAcl))]
    [OutputType(typeof(DeviceAcl))]
    [RequiresVmsConnection()]
    public class GetDeviceAcl : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromCamera")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Camera>))]
        [MipItemTransformation(typeof(Camera))]
        public Camera Camera { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromMicrophone")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Microphone>))]
        [MipItemTransformation(typeof(Microphone))]
        public Microphone Microphone { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromSpeaker")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Speaker>))]
        [MipItemTransformation(typeof(Speaker))]
        public Speaker Speaker { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromInput")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<InputEvent>))]
        [MipItemTransformation(typeof(InputEvent))]
        public InputEvent Input { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromOutput")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Output>))]
        [MipItemTransformation(typeof(Output))]
        public Output Output { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromMetadata")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Metadata>))]
        [MipItemTransformation(typeof(Metadata))]
        public Metadata Metadata { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromHardware")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Hardware>))]
        [MipItemTransformation(typeof(Hardware))]
        public Hardware Hardware { get; set; }

        [Parameter(Position = 1)]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Role>))]
        public string RoleName { get; set; }

        [Parameter]
        public Guid? RoleId { get; set; }

        [Parameter]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Role>))]
        [MipItemTransformation(typeof(Role))]
        public Role Role { get; set; }

        protected override void ProcessRecord()
        {
            if (!MyInvocation.BoundParameters.ContainsKey(nameof(RoleName)) &&
                !MyInvocation.BoundParameters.ContainsKey(nameof(RoleId)) &&
                !MyInvocation.BoundParameters.ContainsKey(nameof(Role)))
            {
                WriteError(
                    new ErrorRecord(
                        new InvalidOperationException("No role specified."),
                        "NoRoleSpecified",
                        ErrorCategory.InvalidArgument,
                        null));
                return;
            }
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

