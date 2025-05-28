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
using VideoOS.ConfigurationApi.ClientService;

namespace MilestonePSTools.ConfigApiCommands
{
    [Cmdlet(VerbsCommon.Get, nameof(IConfigurationService))]
    [OutputType(typeof(IConfigurationService))]
    [RequiresVmsConnection()]
    public class GetConfigurationService : ConfigApiCmdlet
    {
        protected override void ProcessRecord()
        {
            WriteObject(ConfigurationService);
        }
    }
}

