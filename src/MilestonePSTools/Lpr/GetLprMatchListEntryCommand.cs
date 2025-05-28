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
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Get, "VmsLprMatchListEntry", DefaultParameterSetName = nameof(InputObject))]
    [RequiresVmsConnection()]
    [OutputType(typeof(PSCustomObject))]
    public class GetLprMatchListEntryCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public LprMatchList[] InputObject { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true, Position = 0, ParameterSetName = nameof(Name))]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        public string Name { get; set; } = "*";

        [Parameter()]
        public string RegistrationNumber { get; set; } = "*";

        protected override void ProcessRecord()
        {
            if (ParameterSetName != nameof(InputObject))
            {
                var namePattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
                InputObject = Connection.ManagementServer.LprMatchListFolder.LprMatchLists.Where(l => namePattern.IsMatch(l.Name)).ToArray();
                
                if (!WildcardPattern.ContainsWildcardCharacters(Name) && InputObject.Length == 0)
                {
                    // No results found when using a Name property without any wildcard characters
                    throw new ItemNotFoundException($"No LPR Match List found matching \"{Name}\"");
                }
            }

            var regPattern = new WildcardPattern(RegistrationNumber, WildcardOptions.IgnoreCase);
            foreach (var list in InputObject)
            {
                foreach (var result in list.MethodIdGetRegistrationNumbersInfoWithResult().RegistrationNumbersWithCustomFields)
                {
                    var record = new PSObject();
                    var columns = result.ToArray();
                    if (!regPattern.IsMatch(columns[0])) continue;
                    record.Properties.Add(new PSNoteProperty("MatchList", list.Name));
                    record.Properties.Add(new PSNoteProperty(nameof(RegistrationNumber), columns[0]));
                    
                    if (columns.Length > 1)
                    {
                        var fields = list.CustomFields.ToArray();
                        for (var columnNumber = 1; columnNumber < columns.Length; columnNumber++)
                        {
                            record.Properties.Add(new PSNoteProperty(fields[columnNumber - 1], columns[columnNumber]));
                        }
                    }
                    WriteObject(record);
                }
            }
        }
    }
}

