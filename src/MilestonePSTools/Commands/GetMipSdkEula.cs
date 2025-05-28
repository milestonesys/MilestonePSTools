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

using System.IO;
using System.Management.Automation;

namespace MilestonePSTools.Commands
{
    /// <summary>
    /// <para type="synopsis">Returns the MIP SDK end-user license agreement as a string</para>
    /// <para type="description">This module is built upon Milestone's MIP SDK and requires the use of the
    /// redistributable MIP SDK binaries. As such, it is required for the user of this module to accept the
    /// agreement prior to use.</para>
    /// <para type="description">This command will open the MIPSDK_EULA.txt file included with MilestonePSTools in
    /// the default viewer, and return the contents as a plain text string.</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "MipSdkEula")]
    [RequiresVmsConnection(false)]
    public class GetMipSdkEula : PSCmdlet
    {
        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            var directoryName = Path.GetDirectoryName(GetType().Assembly.Location);
            if (directoryName == null) throw new DirectoryNotFoundException($"Failed to locate assembly path for {GetType().FullName}");
            var modulePath = Path.Combine(directoryName, @"..");
            var eulaPath = Path.Combine(modulePath, "assets\\" , "MIPSDK_EULA.txt");
            var eulaContent = File.ReadAllText(eulaPath);
            WriteObject(eulaContent);
        }
    }
}

