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
using MilestonePSTools.Extensions;
using System;
using System.Collections;
using System.Linq;
using System.Management.Automation;
using VideoOS.ConfigurationAPI;
using VideoOS.Platform;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{

    [Cmdlet(VerbsCommon.Get, "VmsDeviceGeneralSetting", DefaultParameterSetName = nameof(Device))]
    [OutputType(typeof(Hashtable))]
    [RequiresVmsConnection()]
    [Alias("Get-VmsCameraGeneralSetting", "Get-VmsMicrophoneGeneralSetting",
           "Get-VmsSpeakerGeneralSetting", "Get-VmsMetadataGeneralSetting",
           "Get-VmsInputGeneralSetting", "Get-VmsOutputGeneralSetting",
           "Get-VmsHardwareGeneralSetting")]
    public class GetDeviceGeneralSettingCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Device))]
        [ValidateVmsItemType("Camera", "Microphone", "Speaker", "Metadata", "InputEvent", "Output", "Hardware")]
        public VideoOS.Platform.ConfigurationItems.IConfigurationItem Device { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Id))]
        [Alias("Guid")]
        public Guid Id { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Path))]
        public string Path { get; set; }

        [Parameter()]
        public SwitchParameter RawValues { get; set; }
        
        [Parameter()]
        public SwitchParameter ValueTypeInfo { get; set; }

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            if (RawValues && ValueTypeInfo)
            {
                WriteVerbose($"The {nameof(RawValues)} switch has no impact when using the {nameof(ValueTypeInfo)} switch parameter.");
            }
        }

        protected override void ProcessRecord()
        {
            var driverSettingsPrefix = "Device";
            // Use the ConfigurationService instead of strongly typed objects because IConfigurationItem does
            // not have a DeviceDriverSettings property.
            switch (ParameterSetName)
            {
                case nameof(Device):
                    Id = Device.Guid;
                    if (Device is VideoOS.Platform.ConfigurationItems.Hardware)
                    {
                        driverSettingsPrefix = "Hardware";
                    }
                    break;
                case nameof(Id):
                    if (Configuration.Instance.GetItem(Id, Kind.Hardware) != null)
                    {
                        driverSettingsPrefix = "Hardware";
                    }
                    break;
                case nameof(Path):
                    Id = new Guid(new ConfigurationItemPath(Path).Id);
                    if (Path.StartsWith("Hardware", StringComparison.OrdinalIgnoreCase))
                    {
                        driverSettingsPrefix = "Hardware";
                    }
                    break;
                default:
                    throw new InvalidOperationException($"Parameter set '{ParameterSetName}' not implemented.");
            }
            
            // The driverSettingsPrefix is used here to allow the use of this command with Hardware as well as devices.
            var deviceSettings = ConfigurationService.GetItem($"{driverSettingsPrefix}DriverSettings[{Id}]");
            var parentPath = new ConfigurationItemPath(deviceSettings.ParentPath);
            var name = Device?.Name ?? $"{parentPath.ParentItemType}[{parentPath.Id}]";
            var properties = deviceSettings?.Children
                ?.FirstOrDefault(c => c.ItemType == nameof(ItemTypes.DeviceDriverSettings) || c.ItemType == nameof(ItemTypes.HardwareDriverSettings))
                ?.Properties;
            if (properties == null)
            {
                WriteError(new ErrorRecord(
                    new ItemNotFoundException($"{driverSettingsPrefix}DriverSettings not found for device {name}"),
                    string.Empty,
                    ErrorCategory.ObjectNotFound,
                    null));
                return;
            }
            var result = new Hashtable(StringComparer.OrdinalIgnoreCase);
            foreach (var property in properties)
            {
                var friendlyKey = StringParsingUtils.GetPropertyNameFromKey(property.Key);
                if (ValueTypeInfo)
                {
                    result.Add(friendlyKey, property.ValueTypeInfos);
                }
                else
                {
                    result.Add(friendlyKey, RawValues ? property.Value : property.GetDisplayValue());
                }
            }
            if (result.Count > 0)
            {
                WriteObject(result);
            }
        }
    }
}

