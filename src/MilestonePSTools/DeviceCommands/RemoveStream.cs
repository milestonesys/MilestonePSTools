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
using System;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Remove, "Stream")]
    [RequiresVmsConnection()]
    public class RemoveStream : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public StreamUsageChildItem Stream { get; set; }

        protected override void ProcessRecord()
        {
            var referenceId = Stream.StreamReferenceId;
            var folder = new StreamFolder(Connection.CurrentSite.FQID.ServerId, Stream.ParentPath);
            try
            {
                var task = folder.Streams.First().RemoveStream(referenceId);
                WriteVerbose(ServerTasks.GetTaskPropertyReport(task, "RemoveStream Result"));
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex, 
                        ex.Message, 
                        ErrorCategory.InvalidOperation, 
                        null));
            }
            
        }
    }
}
