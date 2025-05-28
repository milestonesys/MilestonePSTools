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

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Add, "Stream")]
    [OutputType(typeof(StreamUsageChildItem))]
    [RequiresVmsConnection()]
    public class AddStream : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public Camera Camera { get; set; }
        
        protected override void ProcessRecord()
        {
            var definition = Camera.StreamFolder.Streams.First();
            var task = definition.AddStream();
            if (task.State == StateEnum.Success)
            {
                var referenceId = task.GetProperty("StreamReferenceId");
                Camera.ClearChildrenCache();
                definition = Camera.StreamFolder.Streams.First();
                var streamUsage = definition.StreamUsageChildItems.First(child =>
                    child.StreamReferenceId.Equals(referenceId, StringComparison.OrdinalIgnoreCase));
                WriteObject(streamUsage);
            }
            else
            {
                WriteError(
                    new ErrorRecord(
                        new InvalidOperationException(task.ErrorText),
                        task.ErrorText,
                        ErrorCategory.InvalidResult,
                        null));
            }
        }
    }
}
