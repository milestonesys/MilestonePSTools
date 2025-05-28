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

using System;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Commands
{
    [Cmdlet(VerbsCommon.Get, "VmsManagementServer")]
    [Alias("Get-ManagementServer")]
    [OutputType(typeof(ManagementServer))]
    [RequiresVmsConnection(false)]
    public class GetVmsManagementServer : ConfigApiCmdlet
    {
        protected override void ProcessRecord()
        {
            if (MyInvocation.InvocationName.Equals("Get-ManagementServer", StringComparison.CurrentCultureIgnoreCase))
            {
                WriteWarning("The Get-ManagementServer command is deprecated. For compatibility purposes it is temporarily aliased to Get-VmsManagementServer.");
            }

            if (Connection != null)
            {
                WriteObject(Connection.ManagementServer);
            }
            else
            {
                WriteError(new ErrorRecord(
                    new InvalidOperationException("Not connected to a Management Server."),
                    "Not connected to a Management Server",
                    ErrorCategory.InvalidOperation,
                    null));
            }
        }
    }
}

