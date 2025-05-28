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
    /// <summary>
    /// <para type="synopsis">Copies an existing Evidence Lock by creating a new Evidence Lock record with the same parameters.</para>
    /// <para type="description">At the time of making this cmdlet, 2019-06-05, an evidence lock record on the Management Server doesn't necessarily mean that same evidence lock is known by the Recording Server.
    /// There are various situations in which this data might be out of sync and a user might believe data is evidence locked but in fact the Recording Server disagrees.</para>
    /// <para type="description">The purpose of this cmdlet is to create a copy of an existing Evidence Lock record so that we know it exists on the Recording Server, assuming no error is thrown when creating the copy.</para>
    /// <example>
    ///     <code>C:\PS>$records = Get-EvidenceLock; $records[0] | Copy-EvidenceLock</code>
    ///     <para>Retrieves all evidence locks into $records, and creates a copy of the first record in that list. You could do Get-EvidenceLock | Copy-EvidenceLock but I suspect this may result in a unending loop. Best to get all locks into a single array that you can then enumerate.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Copy, "EvidenceLock")]
    [OutputType(typeof(MarkedDataResult))]
    [RequiresVmsConnection()]
    [RequiresVmsFeature("EvidenceLock")]
    public class CopyEvidenceLock : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="Specifies an Evidence Lock object usually obtained through a Get-EvidenceLock command."></para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true)] 
        public MarkedData Source { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            var deviceIds = Source.DeviceIds;
            var retentionOption = Source.RetentionOption;
            var client = ServerCommandService;
            var reference = client.MarkedDataGetNewReference(CurrentToken, deviceIds, true);
            var result = client.MarkedDataCreate(
                CurrentToken,
                Guid.NewGuid(),
                deviceIds,
                Source.StartTime,
                Source.TagTime,
                Source.EndTime,
                reference.Reference,
                Source.Header,
                Source.Description,
                2,
                true,
                Source.RetentionExpire,
                retentionOption
            );
            if (result.Status != ResultStatus.Success)
            {
                foreach (var deviceResult in result.FaultDevices)
                {
                    WriteError(
                        new ErrorRecord(
                            new ApplicationException(
                                $"{result.Status}: Device '{deviceResult.DeviceId}', Message: {deviceResult.Message}"),
                            deviceResult.Message,
                            ErrorCategory.InvalidOperation,
                            null));
                }
            }

            WriteObject(result);
        }
    }
}

