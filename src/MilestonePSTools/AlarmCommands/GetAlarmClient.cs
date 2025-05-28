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
using VideoOS.Platform.Proxy.AlarmClient;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Gets a working IAlarmClient for making direct calls to the Event Server.</para>
    /// <para type="description">Other Alarm cmdlets are wrappers for the commands you can send directly through
    /// the IAlarmClient interface. If you need access to additional functionality not provided in the cmdlets,
    /// this cmdlet will give you direct access to the Event Server and the ability to query/send events and alarms.
    /// Just remember to call CloseClient() when you're finished as this will not be done for you.</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(IAlarmClient))]
    [OutputType(typeof(IAlarmClient))]
    [RequiresVmsConnection()]
    public class GetAlarmClient : ConfigApiCmdlet
    {
        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteObject(new AlarmClientManager().GetAlarmClient(Connection.CurrentSite.FQID.ServerId));
        }
    }
}


