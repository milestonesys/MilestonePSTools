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
using VideoOS.Platform.Login;

namespace MilestonePSTools.ConnectionCommands
{
    /// <summary>
    /// <para type="synopsis">Gets list of MIP SDK Login Settings for debugging purposes.</para>
    /// <para type="description"></para>
    /// <example>
    ///     <code>C:\PS>Get-LoginSettings</code>
    ///     <para>Returns one or more LoginSettings objects - one for each site either connected or available to connect.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(LoginSettings))]
    [OutputType(typeof(LoginSettings))]
    [RequiresVmsConnection()]
    public class GetLoginSettings : ConfigApiCmdlet
    {
        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            LoginSettingsCache.LoginSettings.ForEach(WriteObject);
        }
    }
}

