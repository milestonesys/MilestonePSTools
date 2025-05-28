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
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.HardwareCommands
{
    [Cmdlet(VerbsCommon.Set, "HardwareSetting")]
    [RequiresVmsConnection()]
    public class SetHardwareSetting : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public Hardware Hardware { get; set; }

        [Parameter(Position = 1, Mandatory = true)]
        public string Name { get; set; }

        [Parameter(Position = 2, Mandatory = true)]
        public string Value { get; set; }

        protected override void ProcessRecord()
        {
            var filter = new WildcardPattern(Name ?? "*", WildcardOptions.IgnoreCase);
            
            var settings = Hardware.HardwareDriverSettingsFolder.HardwareDriverSettings.Single();
            var properties = settings.HardwareDriverSettingsChildItems.Single().Properties;
            var key = properties.Keys.Single(k => filter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
            properties.SetValue(key, Value);
            settings.Save();
        }
    }
}
