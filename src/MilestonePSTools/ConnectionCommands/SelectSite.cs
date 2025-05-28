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

namespace MilestonePSTools.ConnectionCommands
{
    [Cmdlet(VerbsCommon.Select, "VmsSite")]
    [Alias("Select-Site")]
    [RequiresVmsConnection()]
    public class SelectSite : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "Site")]
        [Alias("SiteItem")]
        public Item Site { get; set; }

        [Parameter(Position = 0, ParameterSetName = "ByName")]
        [SupportsWildcards()]
        public string Name { get; set; } = "*";

        [Parameter(ParameterSetName = "MainSite")]
        [Alias("MasterSite")]
        public SwitchParameter MainSite { get; set; }

        protected override void ProcessRecord()
        {
            switch (ParameterSetName)
            {
                case "Site":
                    {
                        Connection.CurrentSite = Site;
                        break;
                    }

                case "ByName":
                    {
                        var pattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
                        var item = Connection.GetSites().FirstOrDefault(s => pattern.IsMatch(s.Name));
                        if (item == null)
                        {
                            WriteWarning($"Site not found. Current site will not be changed.");
                        }
                        else if (VideoOS.Platform.SDK.Environment.IsLoggedIn(item.FQID.ServerId.Uri))
                        {
                            Connection.CurrentSite = item;
                        }
                        else
                        {
                            WriteWarning($"Not logged in to {item.Name}. Site not changed.");
                        }
                        break;
                    }

                case "MainSite":
                    {
                        Connection.CurrentSite = Connection.MainSite;
                        break;
                    }

                default:
                    {
                        var notImplemented = new NotImplementedException($"ParameterSetName {ParameterSetName} not implemented.");
                        WriteError(new ErrorRecord(notImplemented, notImplemented.Message, ErrorCategory.InvalidOperation, null));
                        return;
                    }
            }
            ClearProxyClientCache();
        }
    }
}

