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

using MilestonePSTools.Helpers;
using System;
using System.Management.Automation;
using VideoOS.ConfigurationAPI;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.EventCommands
{
    [Cmdlet(VerbsCommon.Remove, "GenericEvent", SupportsShouldProcess = true, DefaultParameterSetName = "GenericEvent")]
    [RequiresVmsConnection()]
    public class RemoveGenericEvent : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, ParameterSetName = "GenericEvent")]
        public GenericEvent GenericEvent { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Id))]
        public Guid Id { get; set; }

        protected override void ProcessRecord()
        {
            var itemPath = GenericEvent?.Path ?? $"GenericEvent[{Id}]";
            
            if (!ShouldProcess($"{GenericEvent?.Name ?? itemPath}", "Remove"))
            {
                return;
            }
            var folder = new GenericEventFolder(Connection.CurrentSite.FQID.ServerId, $"/{ItemTypes.GenericEventFolder}");
            var task = new ServerTaskProgressWriter(this, folder.RemoveGenericEvent(itemPath),
                new ProgressRecord(0, "Remove-GenericEvent", "Removing generic event"));
            var result = task.MonitorProgress();
            if (result.State == StateEnum.Success) return;

            WriteError(
                new ErrorRecord(
                    new InvalidOperationException(result.ErrorText),
                    result.ErrorText,
                    ErrorCategory.InvalidOperation,
                    GenericEvent));
        }
    }
}
