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
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform;

namespace MilestonePSTools.RegisteredServiceCommands
{
    [Cmdlet(VerbsCommon.Get, "RegisteredService")]
    [OutputType(typeof(Configuration.ServiceURIInfo))]
    [RequiresVmsConnection()]
    public class GetRegisteredService : ConfigApiCmdlet
    {
        [Parameter]
        public Guid? ServiceType { get; set; }
        
        [Parameter]
        public string Name { get; set; } = "*";

        protected override void ProcessRecord()
        {
            List<Configuration.ServiceURIInfo> services;
            if (ServiceType.HasValue)
            {
                services = Configuration.Instance.GetRegisteredServiceUriInfo(ServiceType.Value, Connection.CurrentSite.FQID.ServerId);
            }
            else
            {
                services = Configuration.Instance.GetRegisteredServiceUriInfo(Connection.CurrentSite.FQID.ServerId);
            }

            var namePattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);

            foreach (var service in services.Where(s => namePattern.IsMatch(s.Name)))
            {
                WriteObject(service);
            }
        }
    }
}
