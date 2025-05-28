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
    /// <para type="synopsis">Invokes a method or command on a given ConfigurationItem</para>
    /// <para type="description">Some ConfigurationItem objects have MethodIds defining commands that can be invoked. The
    /// response to an Invoke-Method command may be a ConfigurationItem of type 'InvokeInfo' which may have one or more
    /// properties that need to be filled out before sending the updated InvokeInfo item to the Invoke-Method command again.
    /// Alternatively, if no additional information or Invoke-Method call is needed, the result may be of type InvokeResult.</para>
    /// <para type="description">The result may also be a Task, indicating the operation may take some time. You can then poll
    /// periodically for task status until the State property is 'Completed'.</para>
    /// <example>
    ///     <code>C:\PS> Get-ConfigurationItem -Path /UserDefinedEventFolder | Invoke-Method -MethodId AddUserDefinedEvent</code>
    ///     <para>Invokes the AddUserDefinedEvent method which returns a ConfigurationItem of type InvokeInfo. Fill out the Name property of this ConfigurationItem and resend to the Invoke-Method command to create a new User Defined Event.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&amp;tree=tree_4.html">MIP SDK Configuration API docs</para>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Invoke, "Method")]
    [OutputType(typeof(ConfigurationItem))]
    [RequiresVmsConnection()]
    public class InvokeMethod : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the source ConfigurationItem on which the given MethodId will be invoked</para>
        /// </summary>
        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public ConfigurationItem ConfigurationItem { get; set; }

        /// <summary>
        /// <para type="description">Specifies the MethodId string to invoke on the ConfigurationItem</para>
        /// </summary>
        [Parameter(Mandatory = true, Position = 1)]
        public string MethodId { get; set; }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            for (int errors = 0; errors < 2; errors++)
            {
                try
                {
                    WriteObject(ConfigurationService.InvokeMethod(ConfigurationItem, MethodId));
                    break;
                }
                catch (System.ServiceModel.CommunicationException)
                {
                    if (errors > 0)
                    {
                        throw;
                    }
                    WriteVerbose($"Invoke-Method threw a CommunicationException. The operation will be retried after clearing the proxy client cache.");
                    ClearProxyClientCache();
                }
            }
        }
    }
}

