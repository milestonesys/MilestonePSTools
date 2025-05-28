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

namespace MilestonePSTools.ConfigApiCommands
{
    /// <summary>
    /// <para type="synopsis">Gets a translation table mapping internal property keys or guids to a language-specific display name</para>
    /// <para type="description">Gets a translation table mapping internal property keys or guids to a language-specific display name.</para>
    /// <para type="description">This is specifically useful when you need to get a display name, or a non-English translation, for a property where a translationId is present.</para>
    /// <para type="description">Note that the GetTranslations command appears to fall back to en-US when no matching language code is available.</para>
    /// <example>
    ///     <code>C:\PS> Get-Translations es-ES</code>
    ///     <para>Invokes the AddUserDefinedEvent method which returns a ConfigurationItem of type InvokeInfo. Fill out the Name property of this ConfigurationItem and resend to the Invoke-Method command to create a new User Defined Event.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&amp;tree=tree_4.html">MIP SDK Configuration API docs</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "Translations")]
    [OutputType(typeof(PSObject))]
    [RequiresVmsConnection()]
    public class GetTranslations : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the language ID string such as en-US, in order to retrieve the appropriate translations</para>
        /// </summary>
        [Parameter(Position = 1)]
        public string LanguageId { get; set; } = "en-US";

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            for (int errors = 0; errors < 2; errors++)
            {
                try
                {
                    var obj = new PSObject();
                    foreach (var translation in ConfigurationService.GetTranslations(LanguageId))
                    {
                        obj.Members.Add(new PSNoteProperty(translation.Key, translation.Value));
                    }
                    WriteObject(obj);
                    break;
                }
                catch (System.ServiceModel.CommunicationException)
                {
                    if (errors > 0)
                    {
                        throw;
                    }
                    WriteVerbose($"Get-Translations threw a CommunicationException. The operation will be retried after clearing the proxy client cache.");
                    ClearProxyClientCache();
                }
            }
        }
    }
}

