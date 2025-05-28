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

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Set, "VmsLprMatchList", DefaultParameterSetName = nameof(InputObject), SupportsShouldProcess = true)]
    [RequiresVmsConnection()]
    [OutputType(typeof(LprMatchList))]
    public class SetLprMatchListCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public LprMatchList InputObject { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Name))]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        public string Name { get; set; }

        [Parameter()]
        public string NewName { get; set; }

        [Parameter()]
        public string[] TriggerEvent { get; set; }

        [Parameter()]
        public SwitchParameter PassThru { get; set; }

        protected override void ProcessRecord()
        {
            var dirty = false;
            if (ParameterSetName != nameof(InputObject))
            {
                InputObject = Connection.ManagementServer.LprMatchListFolder?.LprMatchLists.FirstOrDefault(l => l.Name.Equals(Name, StringComparison.CurrentCultureIgnoreCase));
                if (InputObject == null)
                {
                    throw new ItemNotFoundException($"LprMatchList with name \"{Name}\" not found.");
                }
            }

            if (MyInvocation.BoundParameters.ContainsKey(nameof(NewName)))
            {
                if (!InputObject.Name.Equals(NewName) && ShouldProcess(InputObject.Name, $"Change name to {NewName}"))
                {
                    InputObject.Name = NewName;
                    dirty = true;
                }
            }
            
            if (MyInvocation.BoundParameters.ContainsKey(nameof(TriggerEvent)))
            {
                var newEventList = string.Join(",", TriggerEvent);
                if (!InputObject.TriggerEventList.Equals(newEventList) && ShouldProcess(InputObject.Name, $"Set TriggerEventList to {NewName}"))
                {
                    InputObject.TriggerEventList = newEventList;
                    dirty = true;
                }
            }

            try
            {
                if (dirty)
                {
                    InputObject.Save();
                }

                if (PassThru)
                {
                    WriteObject(InputObject);
                }
            }
            catch (ValidateResultException ex)
            {
                foreach (var result in ex.ValidateResult.ErrorResults)
                {
                    WriteError(
                    new ErrorRecord(
                        ex, result.ErrorText, ErrorCategory.InvalidData, InputObject));
                }
            }
        }
    }
}

