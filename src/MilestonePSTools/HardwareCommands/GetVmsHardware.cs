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

using MilestonePSTools.Utility;
using System;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.HardwareCommands
{
    [Cmdlet(VerbsCommon.Get, "VmsHardware", DefaultParameterSetName = "All")]
    [RequiresVmsConnection()]
    [Alias("Get-Hardware")]
    [OutputType(typeof(Hardware))]
    public class GetHardware : ConfigApiCmdlet
    {
        [Parameter(Position = 1, ParameterSetName = "All")]
        public SwitchParameter All { get; set; }

        [Parameter(ValueFromPipeline = true, ParameterSetName = "Filtered")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<RecordingServer>))]
        [MipItemTransformation(typeof(RecordingServer))]
        public RecordingServer RecordingServer { get; set; }

        [Parameter(ParameterSetName = "Filtered")]
        [Alias("HardwareId")]
        public Guid Id { get; set; }

        [Parameter(ParameterSetName = "Filtered")]
        public Guid RecorderId { get; set; }

        [Parameter(ParameterSetName = "Filtered", Position = 0)]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Hardware>))]
        [SupportsWildcards]
        public string Name { get; set; }

        [Parameter(ParameterSetName = "All")]
        [Parameter(ParameterSetName = "Filtered")]
        public EnableFilter EnableFilter { get; set; } = EnableFilter.Enabled;

        [Parameter(Position = 50)]
        public SwitchParameter CaseSensitive { get; set; }

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            if (!MyInvocation.InvocationName.StartsWith("Get-Vms", StringComparison.CurrentCultureIgnoreCase))
            {
                WriteWarning($"The default behavior of {MyInvocation.MyCommand.Name} is to return only enabled hardware, but while using the alias '{MyInvocation.InvocationName}', the behavior matches the previous version of the command by returning disabled hardware too.");
                EnableFilter = EnableFilter.All;
            }
        }

        protected override void ProcessRecord()
        {
            var recorderFolder = Connection.ManagementServer.RecordingServerFolder;
            bool IsEnabledMatch(Hardware hardware)
            {
                return EnableFilter switch
                {
                    EnableFilter.All => true,
                    EnableFilter.Enabled => hardware.Enabled,
                    EnableFilter.Disabled => !hardware.Enabled,
                    _ => true
                };
            }
            switch (ParameterSetName)
            {
                case "Filtered":
                    var nameFilter = new WildcardPattern(Name ?? "*", CaseSensitive ? WildcardOptions.None : WildcardOptions.IgnoreCase);
                    if (Id != Guid.Empty)
                    {
                        var hw = new Hardware(Connection.CurrentSite.FQID.ServerId, $"Hardware[{Id}]");
                        if (IsEnabledMatch(hw))
                        {
                            WriteObject(hw);
                        }
                    }
                    else if (RecordingServer != null || RecorderId != Guid.Empty)
                    {
                        var rec = RecordingServer ?? new RecordingServer(Connection.CurrentSite.FQID.ServerId, $"RecordingServer[{RecorderId}]");
                        foreach (var hw in rec.HardwareFolder.Hardwares.Where(h => nameFilter.IsMatch(h.Name)))
                        {
                            if (IsEnabledMatch(hw))
                            {
                                WriteObject(hw);
                            }
                        }
                    }
                    else
                    {
                        foreach (var rs in recorderFolder.RecordingServers)
                        foreach (var hw in rs.HardwareFolder.Hardwares.Where(h => nameFilter.IsMatch(h.Name)))
                        {
                            if (IsEnabledMatch(hw))
                            {
                                WriteObject(hw);
                            }
                        }
                    }

                    break;
                default:
                    foreach (var rs in recorderFolder.RecordingServers)
                    foreach (var hw in rs.HardwareFolder.Hardwares)
                    {
                        if (IsEnabledMatch(hw))
                        {
                            WriteObject(hw);
                        }
                    }
                    break;
            }
        }
    }
}
