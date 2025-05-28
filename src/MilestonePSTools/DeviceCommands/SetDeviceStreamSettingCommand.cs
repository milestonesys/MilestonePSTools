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

using MilestonePSTools.Extensions;
using System;
using System.Collections;
using System.Linq;
using System.Management.Automation;
using VideoOS.ConfigurationAPI;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{

    [Cmdlet(VerbsCommon.Set, "VmsDeviceStreamSetting", DefaultParameterSetName = nameof(Device), SupportsShouldProcess = true)]
    [OutputType("None")]
    [RequiresVmsConnection()]
    [Alias("Set-VmsCameraStreamSetting", "Set-VmsMicrophoneStreamSetting",
           "Set-VmsSpeakerStreamSetting", "Set-VmsMetadataStreamSetting")]
    public class SetDeviceStreamSettingCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Device))]
        [ValidateVmsItemType("Camera", "Microphone", "Speaker", "Metadata")]
        public IConfigurationItem Device { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Id))]
        [Alias("Guid")]
        public Guid Id { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Path))]
        public string Path { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        [SupportsWildcards()]
        public string StreamName { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true)]
        public IDictionary Settings { get; set; }
        
        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }
        
        protected override void ProcessRecord()
        {
            if (Settings.Keys.Count == 0)
            {
                WriteWarning($"The {nameof(Settings)} parameter is an empty hashtable.");
                return;
            }
            switch (ParameterSetName)
            {
                case nameof(Device):
                    Id = Device.Guid;
                    break;
                case nameof(Id):
                    break;
                case nameof(Path):
                    Id = new Guid(new ConfigurationItemPath(Path).Id);
                    break;
                default:
                    throw new InvalidOperationException($"Parameter set '{ParameterSetName}' not implemented.");
            }
            var deviceSettings = ConfigurationService.GetItem($"DeviceDriverSettings[{Id}]");
            var parentPath = new ConfigurationItemPath(deviceSettings.ParentPath);
            var name = Device?.Name ?? $"{parentPath.ParentItemType}[{parentPath.Id}]";
            var streamSettings = deviceSettings?.Children
                .Where(child => child.ItemType == nameof(ItemTypes.Stream))
                .ToList();
            if (streamSettings.Count == 0)
            {
                WriteError(
                    new ErrorRecord(
                        new ItemNotFoundException($"Stream settings not found for {name}"),
                        string.Empty,
                        ErrorCategory.ObjectNotFound,
                        null));
                return;
            }
            else if (streamSettings.Count > 1 && string.IsNullOrWhiteSpace(StreamName))
            {
                WriteError(
                    new ErrorRecord(
                        new ItemNotFoundException($"Multiple streams found for {name}. Specify the name of the stream to update using the Name parameter. Use * to update all streams on the specified device."),
                        string.Empty,
                        ErrorCategory.ObjectNotFound,
                        null));
                return;
            }

            var dirty = false;
            StreamName = string.IsNullOrEmpty(StreamName) ? "*" : StreamName;
            var streamNamePattern = new WildcardPattern(StreamName, WildcardOptions.IgnoreCase);
            foreach (var stream in streamSettings)
            {
                if (!streamNamePattern.IsMatch(stream.DisplayName))
                {
                    continue;
                }
                foreach (var key in Settings.Keys)
                {
                    var property = stream.GetProperty(key.ToString());
                    var newValue = property?.GetResolvedValue(Settings[key].ToString());

                    if (property == null)
                    {
                        WriteWarning($"A stream setting named '{key}' was not found on {name}.");
                        continue;
                    }

                    if (property.Value != newValue)
                    {
                        if (ShouldProcess(name, $"Change {property.Key} from {property.Value} to {newValue}"))
                        {
                            property.Value = newValue;
                            dirty = true;
                        }
                    }
                }
            }
            if (dirty && ShouldProcess(name, "Save changes"))
            {
                foreach (var error in ConfigurationService.SetItem(deviceSettings).GetValidationErrors())
                {
                    WriteError(error);
                }
            }
        }
    }
}

