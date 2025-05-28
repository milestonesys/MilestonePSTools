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

using System.Linq;
using System.Management.Automation;
using VideoOS.Platform;

namespace MilestonePSTools.ConnectionCommands
{
    [Cmdlet(VerbsCommon.Get, "VmsSite")]
    [Alias("Get-Site")]
    [OutputType(typeof(Item))]
    [RequiresVmsConnection()]
    public class GetSite : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Gets all sites available to the current logon session.</para>
        /// </summary>
        [Parameter()]
        public SwitchParameter ListAvailable { get; set; }

        /// <summary>
        /// <para type="description">Specifies the friendly name of the site Item to get. Wildcard characters can be used.</para>
        /// </summary>
        [Parameter(Position = 0)]
        public string Name { get; set; }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ListAvailable || MyInvocation.BoundParameters.ContainsKey("Name"))
            {
                bool matchFound = false;
                var pattern = new WildcardPattern(Name ?? "*", WildcardOptions.IgnoreCase);
                foreach (var siteItem in Connection.GetSites().Where(s => pattern.IsMatch(s.Name)))
                {
                    matchFound = true;
                    WriteObject(siteItem);
                }
                if (!matchFound && !WildcardPattern.ContainsWildcardCharacters(Name))
                {
                    WriteError(
                    new ErrorRecord(
                        new ItemNotFoundException($"Site not found with Name matching '{Name}'"),
                        "Site not found",
                        ErrorCategory.ObjectNotFound,
                        null));
                }
            }
            else
            {
                WriteObject(Connection.CurrentSite);
            }
        }
    }
}

