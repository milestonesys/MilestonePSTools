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

using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.PermissionCommands
{
    [Cmdlet(VerbsCommon.Set, "OverallSecurity")]
    [RequiresVmsConnection()]
    public class SetOverallSecurity : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true)]
        public Role Role { get; set; }

        [Parameter]
        public PSObject SecurityPermissions { get; set; }

        protected override void ProcessRecord()
        {
            var task = Role.ChangeOverallSecurityPermissions(SecurityPermissions.Properties["SecurityNamespace"].Value
                .ToString());
            foreach (var property in SecurityPermissions.Properties)
            {
                task.SetProperty(property.Name, property.Value.ToString());
            }

            task.ExecuteDefault();
        }
    }

    [Cmdlet(VerbsCommon.Get, "OverallSecurity")]
    [RequiresVmsConnection()]
    public class GetOverallSecurity : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true)]
        public Role Role { get; set; }

        [Parameter]
        public string SecurityNamespaceId { get; set; }

        protected override void ProcessRecord()
        {
            if (string.IsNullOrEmpty(SecurityNamespaceId))
            {
                var task = Role.ChangeOverallSecurityPermissions();
                WriteObject(new PSObject(task.SecurityNamespaceValues));
            }
            else
            {
                var task = Role.ChangeOverallSecurityPermissions(SecurityNamespaceId);
                var obj = new PSObject();
                foreach (var key in task.GetPropertyKeys())
                {
                    obj.Properties.Add(new PSNoteProperty(key, task.GetProperty(key)));
                }
                WriteObject(obj);
            }
        }
    }
}

