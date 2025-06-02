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
using System.Management.Automation;

namespace MilestonePSTools.DeviceCommands
{
    /// <summary>
    /// <para type="synopsis">Gets the display name and category of a Kind by Guid, or lists all known Kinds from VideoOS.Platform.Kind</para>
    /// <para type="description">Most configuration items in the VMS are identified by "Kind" such as Camera, Server, and Microphone.
    /// Some commands will return an obscure object like an FQID which the VMS knows how to use to locate the item in the configuration
    /// but there is very little meaningful identifiable information for a user in an FQID.</para>
    /// <para type="description">The Kind property is a Guid, and the VideoOS.Platform.Kind class can convert a Kind ID into a display
    /// name describing the Kind, and a category name such as VideoIn or AudioOut.</para>
    /// <example>
    ///     <code>C:\PS> Get-ItemState | % { $name = ($_.FQID | Get-PlatformItem).Name; $kind = $_.FQID | Get-Kind; Write-Output "$name is a $($kind.DisplayName) in category $($kind.Category)"}</code>
    ///     <para>Retrieve the Item name and write the name and ItemState</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(Kind))]
    [OutputType(typeof(string))]
    [RequiresVmsConnection(false)]
    public class GetKind : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Item.FQID.Kind value as a Guid</para>
        /// </summary>
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "Convert")]
        [ArgumentCompleter(typeof(KindArgumentCompleter))]
        [KindNameTransform()]
        public Guid Kind { get; set; }

        /// <summary>
        /// <para type="description">List all known Kinds</para>
        /// </summary>
        [Parameter(Mandatory = true, Position = 3, ParameterSetName = "List")] 
        public SwitchParameter List { get; set; }



        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ParameterSetName == "Convert")
            {
                var psObj = new PSObject();
                psObj.Members.Add(new PSNoteProperty(nameof(Kind), Kind));
                psObj.Members.Add(new PSNoteProperty("DisplayName", VideoOS.Platform.Kind.DefaultTypeToNameTable[Kind]));
                psObj.Members.Add(new PSNoteProperty("Category", VideoOS.Platform.Kind.DefaultTypeToCategoryTable[Kind]));
                WriteObject(psObj);
            }
            else
            {
                foreach (var key in VideoOS.Platform.Kind.DefaultTypeToNameTable.Keys)
                {
                    var psObj = new PSObject();
                    psObj.Members.Add(new PSNoteProperty(nameof(Kind), key));
                    psObj.Members.Add(new PSNoteProperty("DisplayName", VideoOS.Platform.Kind.DefaultTypeToNameTable[key]));
                    psObj.Members.Add(new PSNoteProperty("Category", VideoOS.Platform.Kind.DefaultTypeToCategoryTable[key]));
                    WriteObject(psObj);
                }
            }
        }
    }
}

