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
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Get, "MetadataSetting")]
    [OutputType(typeof(PSObject))]
    [RequiresVmsConnection()]
    public class GetMetadataSetting : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "GeneralSettings")]
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "StreamSettings")]
        public Metadata Metadata { get; set; }

        [Parameter(ParameterSetName = "GeneralSettings", Mandatory = true)]
        public SwitchParameter General { get; set; }
        
        [Parameter(ParameterSetName = "StreamSettings", Mandatory = true)]
        public SwitchParameter Stream { get; set; }

        [Parameter(ParameterSetName = "StreamSettings")]
        public int? StreamNumber { get; set; }

        [Parameter(ParameterSetName = "GeneralSettings")]
        [Parameter(ParameterSetName = "StreamSettings")]
        public string Name { get; set; }

        
        [Parameter(ParameterSetName = "GeneralSettings")]
        [Parameter(ParameterSetName = "StreamSettings")]
        public SwitchParameter ValueInfo { get; set; }

        protected override void ProcessRecord()
        {
            var settings = Metadata.DeviceDriverSettingsFolder.DeviceDriverSettings.First();
            var nameFilter = new WildcardPattern(Name ?? "*", WildcardOptions.IgnoreCase);
            switch (ParameterSetName)
            {
                case "GeneralSettings":
                {
                    var keys = settings.DeviceDriverSettingsChildItem?.Properties.Keys.Where(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k))).ToList();
                    if (keys == null) return;
                    if (ValueInfo)
                    {
                        foreach (var key in keys)
                        {
                            
                            var valueTypeInfos = settings.DeviceDriverSettingsChildItem.Properties
                                .GetValueTypeInfoCollection(key);
                            foreach (var info in valueTypeInfos)
                            {
                                var record = new PSObject();
                                record.Properties.Add(
                                    new PSVariableProperty(
                                        new PSVariable("Setting", StringParsingUtils.GetPropertyNameFromKey(key))));
                                record.Properties.Add(
                                    new PSVariableProperty(
                                        new PSVariable("Property", info.Name)));
                                record.Properties.Add(
                                    new PSVariableProperty(
                                        new PSVariable("Value", info.Value)));
                                WriteObject(record);
                            }
                            
                        }
                    }
                    else
                    {
                        var record = new PSObject();
                        foreach (var key in keys)
                        {
                            record.Properties.Add(
                                new PSVariableProperty(
                                    new PSVariable(
                                        StringParsingUtils.GetPropertyNameFromKey(key),
                                        settings.DeviceDriverSettingsChildItem.Properties.GetValue(key))));
                        }
                        WriteObject(record);
                    }
                    break;
                }
                case "StreamSettings":
                {
                    var streams = settings.StreamChildItems.ToList();
                    if (StreamNumber.HasValue)
                    {
                        var stream = streams[StreamNumber.Value];
                        var keys = stream.Properties.Keys.Where(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
                        WriteStreamInfo(stream, keys);
                    }
                    else
                    {
                        foreach (var stream in streams)
                        {
                            var keys = stream.Properties.Keys.Where(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
                            WriteStreamInfo(stream, keys);
                        }
                    }
                    break;
                }
            }
        }

        private void WriteStreamInfo(StreamChildItem stream, IEnumerable<string> keys)
        {
            if (ValueInfo.IsPresent)
            {
                foreach (var key in keys)
                {
                    foreach (var info in stream.Properties.GetValueTypeInfoCollection(key))
                    {
                        var record = new PSObject();
                        record.Properties.Add(new PSVariableProperty(
                            new PSVariable("Setting", StringParsingUtils.GetPropertyNameFromKey(key))));
                        record.Properties.Add(new PSVariableProperty(
                            new PSVariable("Property", info.Name)));
                        record.Properties.Add(new PSVariableProperty(
                            new PSVariable("Value", info.Value)));
                        WriteObject(record);
                    }
                }
            }
            else
            {
                var record = new PSObject();
                foreach (var key in keys)
                {
                    record.Properties.Add(
                        new PSVariableProperty(
                            new PSVariable(StringParsingUtils.GetPropertyNameFromKey(key), stream.Properties.GetValue(key))));
                }
                WriteObject(record);
            }
        }
    }
}
