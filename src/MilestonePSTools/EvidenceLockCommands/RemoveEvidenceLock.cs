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
using VideoOS.Common.Proxy.Server.WCF;
using MarkedData = VideoOS.Common.Proxy.Server.WCF.MarkedData;

namespace MilestonePSTools.EvidenceLockCommands
{
    [Cmdlet(VerbsCommon.Remove, "EvidenceLock", SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.High)]
    [RequiresVmsConnection()]
    [RequiresVmsFeature("EvidenceLock")]
    public class RemoveEvidenceLock : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromMarkedData")]
        public MarkedData[] EvidenceLocks { get; set; }

        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromId")]
        public string[] EvidenceLockIds { get; set; }

        /// <summary>
        /// <para type="description">Required in order to remove evidence locks due to the possible loss of sensitive recordings if used by mistake</para>
        /// </summary>
        [Parameter()]
        public SwitchParameter Force { get; set; }

        protected override void ProcessRecord()
        {
            var ids = ParameterSetName == "FromMarkedData" 
                ? EvidenceLocks.Select(l => l.Id).ToArray() 
                : EvidenceLockIds.Select(id => new Guid(id)).ToArray();
            if (Force && ShouldProcess($"{ids.Count()} evidence lock records", "Delete"))
            {
                var results = ServerCommandService.MarkedDataDelete(CurrentToken, ids);
                foreach (var result in results)
                {
                    if (result.Status == ResultStatus.Success) continue;
                    foreach (var fault in result.FaultDevices)
                    {
                        WriteError(
                            new ErrorRecord(
                                new ApplicationException($"{result.Status}: Device '{fault.DeviceId}', Message: {fault.Message}"),
                                fault.Message,
                                ErrorCategory.InvalidOperation,
                                null));
                    }
                }
            }
            else
            {
                WriteError(new ErrorRecord(new InvalidOperationException($"This may result in permanent loss of data. Re-issue this command with the -Force switch if you want to proceed."), "Missing Force switch parameter", ErrorCategory.InvalidOperation, null ));
            }
        }
    }
}
