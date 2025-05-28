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
    /// <para type="synopsis">Gets MethodId's and their display names along with the TranslationId value to lookup language-specific display names.</para>
    /// <para type="description">Gets MethodId's and their display names along with the TranslationId value to lookup language-specific display names.</para>
    /// <example>
    ///     <code>C:\PS> Get-MethodInfo</code>
    ///     <para>Gets all possible MethodInfo objects</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS> Get-MethodInfo RemoveAlarmDefinition</code>
    ///     <para>Gets the MethodInfo for the RemoveAlarmDefinition MethodId</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&amp;tree=tree_4.html">MIP SDK Configuration API docs</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(MethodInfo))]
    [OutputType(typeof(MethodInfo))]
    [RequiresVmsConnection()]
    public class GetMethodInfo : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the MethodId property for the MethodInfo to retrieve. This would usually come from the MethodIds property of a ConfigurationItem object.</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true, Position = 1)]
        public string MethodId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            if (!string.IsNullOrEmpty(MethodId))
            {
                WriteObject(ConfigurationService.GetMethodInfo(MethodId));
            }
            else
            {
                foreach (var methodInfo in ConfigurationService.GetMethodInfos())
                {
                    WriteObject(methodInfo);
                }
            }
        }
    }
}
