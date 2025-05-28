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
using System.Management.Automation;
using VideoOS.Common.Proxy.Server.WCF;

namespace MilestonePSTools.EvidenceLockCommands
{
    [Cmdlet(VerbsData.Update, "EvidenceLock")]
    [RequiresVmsConnection()]
    [RequiresVmsFeature("EvidenceLock")]
    public class UpdateEvidenceLock : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromMarkedData")]
        public MarkedData EvidenceLock { get; set; }

        protected override void ProcessRecord()
        {
            var result = ServerCommandService.MarkedDataUpdate(
                CurrentToken, 
                EvidenceLock.Id, 
                EvidenceLock.DeviceIds,
                EvidenceLock.StartTime,
                EvidenceLock.TagTime,
                EvidenceLock.EndTime,
                EvidenceLock.Reference,
                EvidenceLock.Header,
                EvidenceLock.Description,
                2,
                EvidenceLock.UseRetention,
                EvidenceLock.RetentionExpire,
                EvidenceLock.RetentionOption);
            if (result.Status == ResultStatus.Success)
                return;

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
}
