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
using VideoOS.Platform;

namespace MilestonePSTools.RegisteredServiceCommands
{
    [Cmdlet(VerbsCommon.Add, "RegisteredService")]
    [OutputType(typeof(Configuration.ServiceURIInfo))]
    [RequiresVmsConnection()]
    public class AddRegisteredService : ConfigApiCmdlet
    {
        [Parameter(Position = 1, Mandatory = true)]
        public string Name { get; set; }

        [Parameter(Position = 2, Mandatory = true)]
        public Uri Uri { get; set; }

        [Parameter(Position = 3, Mandatory = true)]
        public Guid ServiceType { get; set; }

        [Parameter]
        public string Description { get; set; }

        [Parameter]
        public string Data { get; set; }

        [Parameter]
        public Guid? InstanceId { get; set; }

        protected override void ProcessRecord()
        {
            var id = InstanceId ?? Guid.NewGuid();
            Configuration.Instance.RegisterServiceUri(
                ServiceType,
                Connection.CurrentSite.FQID.ServerId,
                id,
                Uri,
                Name,
                Description,
                Data);

            WriteObject(Configuration.Instance.GetRegisteredServiceUriInfo(ServiceType, Connection.CurrentSite.FQID.ServerId).SingleOrDefault(r => r.Instance == id));
        }
    }
}
