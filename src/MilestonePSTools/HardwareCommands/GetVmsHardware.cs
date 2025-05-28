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
        public RecordingServer RecordingServer { get; set; }

        [Parameter(ParameterSetName = "Filtered")]
        [ArgumentCompleter(typeof(MipItemIdCompleter<Hardware>))]
        [Alias("HardwareId")]
        public Guid Id { get; set; }

        [Parameter(ParameterSetName = "Filtered")]
        public Guid RecorderId { get; set; }

        [Parameter(ParameterSetName = "Filtered")]
        [ArgumentCompleter(typeof(MipItemNameCompleter<Hardware>))]
        [SupportsWildcards]
        public string Name { get; set; }

        [Parameter(Position = 50)]
        public SwitchParameter CaseSensitive { get; set; }

        protected override void ProcessRecord()
        {
            var recorderFolder = Connection.ManagementServer.RecordingServerFolder;
            switch (ParameterSetName)
            {
                case "Filtered":
                    var nameFilter = new WildcardPattern(Name ?? "*", CaseSensitive ? WildcardOptions.None : WildcardOptions.IgnoreCase);
                    if (Id != Guid.Empty)
                    {
                        WriteObject(new Hardware(Connection.CurrentSite.FQID.ServerId, $"Hardware[{Id}]"));
                    }
                    else if (RecordingServer != null || RecorderId != Guid.Empty)
                    {
                        var rec = RecordingServer ?? new RecordingServer(Connection.CurrentSite.FQID.ServerId, $"RecordingServer[{RecorderId}]");
                        foreach (var hw in rec.HardwareFolder.Hardwares.Where(h => nameFilter.IsMatch(h.Name)))
                        {
                            WriteObject(hw);
                        }
                    }
                    else
                    {
                        foreach (var rs in recorderFolder.RecordingServers)
                        foreach (var hw in rs.HardwareFolder.Hardwares.Where(h => nameFilter.IsMatch(h.Name)))
                        {
                            WriteObject(hw);
                        }
                    }

                    break;
                default:
                    foreach (var rs in recorderFolder.RecordingServers)
                    foreach (var hw in rs.HardwareFolder.Hardwares)
                    {
                        WriteObject(hw);
                    }
                    break;
            }
        }
    }
}

