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
using System.Management.Automation;
using System.Text.RegularExpressions;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.PermissionCommands
{
    [Cmdlet(VerbsCommon.Set, nameof(DeviceAcl))]
    [RequiresVmsConnection()]
    public class SetDeviceAcl : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public DeviceAcl DeviceAcl { get; set; }

        protected override void ProcessRecord()
        {
            object device = null;
            switch (GetObjectTypeFromPath(DeviceAcl.Path))
            {
                case "Camera":
                {
                    device = new Camera(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
                case "Microphone":
                {
                    device = new Microphone(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
                case "Speaker":
                {
                    device = new Speaker(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
                case "Metadata":
                {
                    device = new Metadata(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
                case "InputEvent":
                {
                    device = new InputEvent(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
                case "Output":
                {
                    device = new Output(Connection.CurrentSite.FQID.ServerId, DeviceAcl.Path);
                    break;
                }
            }

            var task = ServerTasks.WaitForTask(AclHelpers.SetAcl(device, DeviceAcl));
            WriteVerbose(ServerTasks.GetTaskPropertyReport(task, "SetAcl Results"));
        }

        private static string GetObjectTypeFromPath(string path)
        {
            return Regex
                .Match(path,
                    @"(?<objectType>\w+)\[(?<guid>[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\]")
                .Groups["objectType"].Value;
        }
    }
}
