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

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Clear, "VmsLprMatchList", DefaultParameterSetName = nameof(Name), SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.High)]
    [RequiresVmsConnection()]
    [OutputType(typeof(LprMatchList))]
    public class ClearLprMatchListCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public LprMatchList[] InputObject { get; set; }

        [Parameter(Mandatory = true, Position = 0, ParameterSetName = nameof(Name))]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        public string Name { get; set; }

        [Parameter()]
        public SwitchParameter PassThru { get; set; }

        protected override void ProcessRecord()
        {
            if ((InputObject?.Length ?? 0) == 0)
            {
                InputObject = Connection.ManagementServer.LprMatchListFolder?.LprMatchLists.Where(l => l.Name.Equals(Name, StringComparison.CurrentCultureIgnoreCase)).ToArray();
                if ((InputObject?.Length ?? 0) == 0)
                {
                    throw new ItemNotFoundException($"LprMatchList with name \"{Name}\" not found.");
                }
            }

            foreach (var list in InputObject)
            {
                if (ShouldProcess(list.Name, "Delete all registration numbers"))
                {
                    var result = list.MethodIdDeleteAllRegistrationNumbers();
                    if (result.State != StateEnum.Success)
                    {
                        WriteError(new ErrorRecord(
                            new Exception($"Operation failed: {result.ErrorText}"), result.ErrorText, ErrorCategory.ProtocolError, result));
                    }
                    else if (PassThru)
                    {
                        WriteObject(list);
                    }
                }
            }
        }
    }
}

