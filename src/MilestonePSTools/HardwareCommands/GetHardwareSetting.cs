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

using System.IO;
using System.Linq;
using System.Management.Automation;
using MilestoneLib;
using MilestonePSTools.Utility;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.HardwareCommands
{
    [Cmdlet(VerbsCommon.Get, "HardwareSetting")]
    [OutputType(typeof(PSObject))]
    [RequiresVmsConnection()]
    public class GetHardwareSetting : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Hardware>))]
        [MipItemTransformation(typeof(Hardware))]
        public Hardware Hardware { get; set; }

        [Parameter]
        public string Name { get; set; }

        [Parameter]
        public SwitchParameter ValueTypeInfo { get; set; }

        [Parameter]
        public SwitchParameter IncludeReadWriteOnly { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                var pattern = new WildcardPattern(Name ?? "*", WildcardOptions.IgnoreCase);
                var generalSettings = ConfigurationService.GetItem($"HardwareDriverSettings[{Hardware.Id}]")?.Children
                    ?.SingleOrDefault(c => c.ItemType == "HardwareDriverSettings")
                    ?.Properties;

                if (generalSettings == null)
                {
                    WriteError(
                        new ErrorRecord(
                            new InvalidDataException($"HardwareDriverSettingsChildItem is null on {Hardware.Name}"),
                            string.Empty,
                            ErrorCategory.InvalidData,
                            null));
                    return;
                }

                var record = new PSObject();
                foreach (var property in generalSettings)
                {
                    var shortKey = StringParsingUtils.GetPropertyNameFromKey(property.Key);
                    if (!property.IsSettable && IncludeReadWriteOnly)
                    {
                        continue;
                    }
                    else if (!pattern.IsMatch(shortKey))
                    {
                        continue;
                    }

                    if (ValueTypeInfo)
                    {
                        foreach (var info in property.ValueTypeInfos)
                        {
                            record.Properties.Add(
                                new PSVariableProperty(
                                    new PSVariable(info.Name, info.Value)));
                        }
                    }
                    else
                    {
                        record.Properties.Add(
                            new PSVariableProperty(
                                new PSVariable(shortKey, property.Value)));
                    }
                }
                if (record.Properties.Count() > 0)
                {
                    WriteObject(record);
                }
            }
            catch (System.Exception ex)
            {
                if (ex.Message == "Unrecognized Guid format.")
                {
                    WriteWarning($"ConfigurationAPI unable to parse HardwareDriverSettings. This may have been caused by a missing hardware property display name and display name reference ID which was identified in Bug 233936 as being caused by a Device Pack 10.3 driver for Axis cameras.");
                }
                else
                {
                    WriteError(
                        new ErrorRecord(
                            ex,
                            ex.Message,
                            ErrorCategory.InvalidOperation,
                            Hardware));
                }
            }
        }
    }
}

