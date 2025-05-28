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
    [Cmdlet(VerbsCommon.Remove, "VmsLprMatchListEntry", DefaultParameterSetName = nameof(InputObject), SupportsShouldProcess = true)]
    [RequiresVmsConnection()]
    public class RemoveLprMatchListEntryCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public LprMatchList InputObject { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Name))]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        public string Name { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = nameof(InputObject))]
        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Name))]
        public string[] RegistrationNumber { get; set; }

        protected override void ProcessRecord()
        {
            if (ParameterSetName != nameof(InputObject))
            {
                InputObject = Connection.ManagementServer.LprMatchListFolder?.LprMatchLists.FirstOrDefault(l => l.Name.Equals(Name, StringComparison.CurrentCultureIgnoreCase));
                if (InputObject == null)
                {
                    var ex = new ItemNotFoundException($"LprMatchList with name \"{Name}\" not found.");
                    WriteError(
                        new ErrorRecord(
                            ex, ex.Message, ErrorCategory.ObjectNotFound, Name));
                    return;
                }
            }
            try
            {
                if (ShouldProcess(InputObject.Name, $"Remove registration number {string.Join(", ", RegistrationNumber)}"))
                {
                    InputObject.MethodIdDeleteRegistrationNumbers(string.Join(";", RegistrationNumber));
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

