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
    [Cmdlet(VerbsData.Update, "RegisteredService")]
    [RequiresVmsConnection()]
    public class UpdateRegisteredService : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public Configuration.ServiceURIInfo RegisteredService { get; set; }

        protected override void ProcessRecord()
        {
            Configuration.Instance.RegisterServiceUri(
                RegisteredService.Type,
                Connection.CurrentSite.FQID.ServerId,
                RegisteredService.Instance,
                new Uri(RegisteredService.UriArray.First()), 
                RegisteredService.Name,
                RegisteredService.Description,
                RegisteredService.ServiceData,
                RegisteredService.Endpoints);
        }
    }
}
