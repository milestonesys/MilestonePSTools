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

using System.Management.Automation;
using VideoOS.ConfigurationApi.ClientService;

namespace MilestonePSTools.ConfigApiCommands
{
    /// <summary>
    /// <para type="synopsis">Store the updated ConfigurationItem including all properties and any filled childItems with Category=ChildItem</para>
    /// <para type="description">Store the updated ConfigurationItem including all properties and any filled childItems with Category=ChildItem</para>
    /// <example>
    ///     <code>C:\PS> $ms = Get-ConfigurationItem -Path "/"; $name = $ms.Properties[0] | Where-Object Key -eq "Name"; $name = "New Name"; $ms | Set-ConfigurationItem</code>
    ///     <para>Changes the Name property of the Management Server</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&amp;tree=tree_4.html">MIP SDK Configuration API docs</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, nameof(ConfigurationItem))]
    [OutputType(typeof(ValidateResult))]
    [RequiresVmsConnection()]
    public class SetConfigurationItem : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the ConfigurationItem object to be updated.</para>
        /// <para type="description">Usually you will get the ConfigurationItem object using Get-ConfigurationItem.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public ConfigurationItem ConfigurationItem { get; set; }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            for (int errors = 0; errors < 2; errors++)
            {
                try
                {
                    WriteObject(ConfigurationService.SetItem(ConfigurationItem));
                    break;
                }
                catch (System.ServiceModel.CommunicationException)
                {
                    if (errors > 0)
                    {
                        throw;
                    }
                    WriteVerbose($"Set-ConfigurationItem threw a CommunicationException. The operation will be retried after clearing the proxy client cache.");
                    ClearProxyClientCache();
                }
            }
        }
    }
}

