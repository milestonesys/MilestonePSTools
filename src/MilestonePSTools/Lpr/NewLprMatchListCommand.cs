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
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.New, "VmsLprMatchList", SupportsShouldProcess = true)]
    [RequiresVmsConnection()]
    [OutputType(typeof(LprMatchList))]
    public class NewLprMatchListCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipelineByPropertyName = true)]
        [Alias("MatchList")]
        public string Name { get; set; }

        [Parameter()]
        public string[] TriggerEvent { get; set; }

        protected override void ProcessRecord()
        {
            if (Connection.ManagementServer.LprMatchListFolder == null)
            {
                throw new VmsFeatureNotAvailableException($"{nameof(LprMatchListFolder)} not available on the current site.");
            }
            if (!ShouldProcess(Name, "Create LPR Match List")) return;

            var result = Connection.ManagementServer.LprMatchListFolder.MethodIdAddLprMatchList(Name);

            if (result.State != StateEnum.Success)
            {
                WriteError(new ErrorRecord(
                    new Exception($"Operation failed: {result.ErrorText}"), result.ErrorText, ErrorCategory.ProtocolError, result));
                return;                    
            }

            if ((TriggerEvent?.Length ?? 0) > 0)
            {
                var list = new LprMatchList(Connection.CurrentSite.FQID.ServerId, result.Path);
                list.TriggerEventList = string.Join(",", TriggerEvent.Select(t =>
                {
                    try
                    {
                        var path = new ConfigurationItemPath(t);
                        return $"{path.ItemType}[{path.Id.ToString().ToUpper()}]";
                    }
                    catch (Exception ex)
                    {
                        throw new ArgumentException("Invalid Configuration API item path", nameof(TriggerEvent), ex);
                    }
                }));
                list.Save();
            }
            WriteObject(new LprMatchList(Connection.CurrentSite.FQID.ServerId, result.Path));
        }

        protected override void EndProcessing()
        {
            Connection.ManagementServer.LprMatchListFolder?.ClearChildrenCache();
        }
    }
}

