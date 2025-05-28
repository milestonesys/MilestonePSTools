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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Text.RegularExpressions;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Add, "VmsLprMatchListEntry", DefaultParameterSetName = nameof(Name), SupportsShouldProcess = true)]
    [RequiresVmsConnection()]
    public class AddLprMatchListEntryCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public LprMatchList InputObject { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Name))]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        [Alias("MatchList")]
        public string Name { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true)]
        public string RegistrationNumber { get; set; }

        [Parameter()]
        public Hashtable CustomFields { get; set; }

        [Parameter()]
        public SwitchParameter Force { get; set; }

        protected override void ProcessRecord()
        {
            if (ParameterSetName != nameof(InputObject))
            {
                InputObject = Connection.ManagementServer.LprMatchListFolder?.LprMatchLists.FirstOrDefault(l => l.Name.Equals(Name, StringComparison.CurrentCultureIgnoreCase));
                if (InputObject == null)
                {
                    throw new ItemNotFoundException($"LprMatchList with name \"{Name}\" not found.");
                }
            }

            if (InputObject.Path.Equals("LprMatchList[322b1e5f-7ee4-423e-8df4-10e27bfd3036]", StringComparison.InvariantCultureIgnoreCase))
            {
                var ex = new ArgumentException($"You can not add entries to the default {InputObject.Name} match list.");
                WriteError(
                    new ErrorRecord(
                        ex, "ReadOnlyMatchList", ErrorCategory.InvalidOperation, InputObject));
                return;
            }

            ServerTask result;
            if ((CustomFields?.Count ?? 0) > 0)
            {
                // Add registration numbers with custom fields
                if (Force && ShouldProcess(InputObject.Name, "Add custom fields"))
                {
                    // Add new custom fields if they don't exist already
                    var customFields = new List<string>(InputObject.CustomFieldsList);
                    foreach (var key in CustomFields.Keys)
                    {
                        if (!customFields.Any(f => f.Equals(key.ToString(), StringComparison.CurrentCultureIgnoreCase)))
                        {
                            WriteVerbose($"Adding new custom field \"{key}\" to LprMatchList {InputObject.Name}");
                            customFields.Add(key.ToString());
                        }
                    }
                    InputObject.CustomFieldsList = customFields;
                    InputObject.Save();
                }
                else
                {
                    // Warn if CustomFields contains keys that don't match an existing custom field
                    foreach (var key in CustomFields.Keys)
                    {
                        if (!InputObject.CustomFieldsList.Any(f => f.Equals(key.ToString(), StringComparison.CurrentCultureIgnoreCase)))
                        {
                            WriteWarning($"Custom field \"{key}\" does not exist on LprMatchList {InputObject.Name}. Use -Force to automatically create new custom fields.");
                        }
                    }
                }
                var regex = new Regex(@"(?<!\\),");
                var record = new StringBuilder(RegistrationNumber);
                foreach (var field in InputObject.CustomFieldsList)
                {
                    // If the value of a field contains a comma, it must be escaped or
                    // Management Server will consider it the value for the next field.
                    var fieldValue = regex.Replace(CustomFields[field]?.ToString() ?? string.Empty, @"\,");
                    record.Append(",");
                    record.Append(fieldValue);
                }
                if (ShouldProcess(InputObject.Name, "Add or edit registration numbers with custom fields"))
                {
                    result = InputObject.MethodIdAddOrEditRegistrationNumbersInfo(record.ToString());
                    if (result.State != StateEnum.Success)
                    {
                        WriteError(new ErrorRecord(
                            new Exception($"Operation failed: {result.ErrorText}"), result.ErrorText, ErrorCategory.ProtocolError, result));
                    }
                }
            }
            else
            {
                // Add just the registration numbers
                if (ShouldProcess(InputObject.Name, "Add or edit registration numbers with custom fields"))
                {
                    result = InputObject.MethodIdAddOrEditRegistrationNumbersInfo(RegistrationNumber);
                    if (result.State != StateEnum.Success)
                    {
                        WriteError(new ErrorRecord(
                            new Exception($"Operation failed: {result.ErrorText}"), result.ErrorText, ErrorCategory.ProtocolError, result));
                    }
                }
            }
        }
    }
}
