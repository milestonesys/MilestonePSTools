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
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsCommon.Get, "VmsLprMatchList")]
    [RequiresVmsConnection()]
    [OutputType(typeof(LprMatchList))]
    public class GetLprMatchListCommand : ConfigApiCmdlet
    {
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = true)]
        [ArgumentCompleter(typeof(MipItemNameCompleter<LprMatchList>))]
        [SupportsWildcards()]
        public string Name { get; set; } = "*";

        protected override void ProcessRecord()
        {
            var resultFound = false;
            var pattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
            foreach (var list in Connection.ManagementServer.LprMatchListFolder.LprMatchLists)
            {
                if (pattern.IsMatch(list.Name))
                {
                    resultFound = true;
                    WriteObject(list);
                }
            }
            if (!WildcardPattern.ContainsWildcardCharacters(Name) && !resultFound)
            {
                // No results found when using a Name property without any wildcard characters
                throw new ItemNotFoundException($"No LPR Match List found matching \"{Name}\"");
            }
        }
    }
}

