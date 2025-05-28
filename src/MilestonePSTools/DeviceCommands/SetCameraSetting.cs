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
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Set, "CameraSetting")]
    [RequiresVmsConnection()]
    public class SetCameraSetting : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "GeneralSettings")]
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "StreamSettings")]
        public Camera Camera { get; set; }

        [Parameter(ParameterSetName = "GeneralSettings", Mandatory = true)]
        public SwitchParameter General { get; set; }

        [Parameter(ParameterSetName = "StreamSettings", Mandatory = true)]
        public SwitchParameter Stream { get; set; }

        [Parameter(ParameterSetName = "StreamSettings")]
        public int? StreamNumber { get; set; }

        [Parameter(ParameterSetName = "GeneralSettings", Mandatory = true)]
        [Parameter(ParameterSetName = "StreamSettings", Mandatory = true)]
        public string Name { get; set; }

        [Parameter(ParameterSetName = "GeneralSettings", Mandatory = true)]
        [Parameter(ParameterSetName = "StreamSettings", Mandatory = true)]
        public string Value { get; set; }


        protected override void ProcessRecord()
        {
            // Deprecated on 2022-01-20
            WriteWarning("This command is deprecated. Please use Set-VmsCameraGeneralSetting or Set-VmsCameraStream instead.");

            var settings = new DeviceDriverSettings(Connection.CurrentSite.FQID.ServerId, $"DeviceDriverSettings[{Camera.Id}]");
            var nameFilter = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
            switch (ParameterSetName)
            {
                case "GeneralSettings":
                {
                    var key = settings.DeviceDriverSettingsChildItem.Properties.KeysFullName.First(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
                    settings.DeviceDriverSettingsChildItem.Properties.SetValue(key, Value);
                    try
                    {
                        settings.Save();
                    }
                    catch (ValidateResultException ex)
                    {
                        var validation = settings.ValidateItem();
                        if (!validation.ValidatedOk)
                        {
                            foreach (var error in validation.ErrorResults)
                            {
                                WriteError(
                                    new ErrorRecord(
                                        ex,
                                        $"{error.ErrorProperty}: {error.ErrorText}",
                                        ErrorCategory.InvalidData,
                                        settings));
                            }
                        }
                    }

                    break;
                }
                case "StreamSettings":
                {
                    var streams = settings.StreamChildItems.ToList();
                    if (StreamNumber.HasValue)
                    {
                        var stream = streams[StreamNumber.Value];
                        var key = stream.Properties.Keys.Single(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
                        WriteVerbose($"Setting value of '{key}' to '{Value}'");
                        stream.Properties.SetValue(key, Value);
                    }
                    else
                    {
                        foreach (var stream in streams)
                        {
                            var key = stream.Properties.Keys.Single(k => nameFilter.IsMatch(StringParsingUtils.GetPropertyNameFromKey(k)));
                            WriteVerbose($"Setting value of '{key}' to '{Value}'");
                            stream.Properties.SetValue(key, Value);
                        }
                    }
                    try
                    {
                        settings.Save();
                    }
                    catch (ValidateResultException ex)
                    {
                        var validation = settings.ValidateItem();
                        if (!validation.ValidatedOk)
                        {
                            foreach (var error in validation.ErrorResults)
                            {
                                WriteError(
                                    new ErrorRecord(
                                        ex,
                                        $"{error.ErrorProperty}: {error.ErrorText}",
                                        ErrorCategory.InvalidData,
                                        settings));
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
}

