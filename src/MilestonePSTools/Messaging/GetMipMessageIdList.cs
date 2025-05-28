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
using VideoOS.Platform;

namespace MilestonePSTools.Messaging
{
    /// <summary>
    /// <para type="synopsis">Gets a list of all known MessageIds</para>
    /// <para type="description">Gets a list of all known MessageIds. This includes all the message id's defined by
    /// the PlatformPlugin and environment as well as for all loaded plug-ins.</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "MipMessageIdList")]
    [OutputType(typeof(string))]
    [RequiresVmsConnection(false)]
    public class GetMipMessageIdList : ConfigApiCmdlet
    {
        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            EnvironmentManager.Instance.MessageIdList.ForEach(WriteObject);
        }
    }
}

