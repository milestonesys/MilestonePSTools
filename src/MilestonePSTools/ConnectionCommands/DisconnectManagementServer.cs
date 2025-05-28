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

using MilestonePSTools.Connection;
using System;
using System.Management.Automation;

namespace MilestonePSTools.ConnectionCommands
{
    /// <summary>
    /// <para type="synopsis">Disconnects from all Milestone XProtect Management Servers currently logged into.</para>
    /// <para type="description">The Disconnect-ManagementServer cmdlet should be called after you finish working
    /// with your VMS. Gracefully closing the connection will help ensure resources are released both locally and remotely.</para>
    /// <para type="description">Note: You cannot selectively disconnect from one out of many Management Servers.</para>
    /// <example>
    ///     <code>C:\PS>Disconnect-ManagementServer</code>
    ///     <para>Disconnect from the current Management Server and all child sites if applicable.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommunications.Disconnect, "ManagementServer")]
    [RequiresVmsConnection(false)]
    public class DisconnectManagementServer : PSCmdlet
    {
        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                if (MilestoneConnection.Instance != null)
                {
                    WriteVerbose($"Disconnecting from current site and any child sites if present.");
                    MilestoneConnection.Instance.Dispose();
                    MilestoneConnection.Instance = null;
                }
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.InvalidOperation,
                        null));
            }
        }
    }
}

