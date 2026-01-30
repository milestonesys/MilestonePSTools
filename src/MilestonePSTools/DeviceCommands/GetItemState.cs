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
using System.Collections.Concurrent;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Threading;
using VideoOS.Platform;
using VideoOS.Platform.Messaging;

namespace MilestonePSTools.DeviceCommands
{
    /// <summary>
    /// <para type="synopsis">Gets the ItemState of all known items in the site</para>
    /// <para type="description">Sends a MessageCommunication.ProvideCurrentStateRequest message and returns the response.</para>
    /// <para type="description">The ProvideCurrentStateResponse contains a flat collection of ItemState objects
    /// representing the state of all known items in the site. Each ItemState contains an FQID, and State property.
    /// The FQID.Kind and FQID.ObjectId can be used to determine what type of object the state represents, and the ID
    /// of that object.</para>
    /// <para type="description">Most of the time, you will probably only be interested in Camera objects, so you can
    /// filter the output with the -CamerasOnly switch.</para>
    /// <example>
    ///     <code>C:\PS> Get-ItemState -CamerasOnly | Where-Object State -ne "Responding" | Foreach-Object { $camera = Get-VmsCamera -Id $_.FQID.ObjectId; Write-Warning "Camera $($camera.Name) state is $($_.State)" }</code>
    ///     <para>Write a warning for every camera found with a state that is not "Responding"</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS> Get-ItemState | % { $camera = Get-VmsCamera -Id $_.FQID.ObjectId; $hardware = $camera | Get-ConfigurationItem -ParentItem; # Do something else here}</code>
    ///     <para>Gets the associated Hardware object for every Camera ItemState result.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(ItemState))]
    [OutputType(typeof(ItemState))]
    [RequiresVmsConnection()]
    public class GetItemState : ConfigApiCmdlet
    {
        private BlockingCollection<ItemState> _itemStates;

        /// <summary>
        /// <para type="description">Filter the ItemState results to Camera items</para>
        /// </summary>
        [Parameter()]
        public SwitchParameter CamerasOnly { get; set; }

        [Parameter(Position = 1)]
        public TimeSpan Timeout { get; set; } = TimeSpan.FromSeconds(60);

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            _itemStates = new BlockingCollection<ItemState>();
            MessageCommunication mc = null;
            object obj = null;
            CancellationTokenSource cts = null;
            try
            {
                MessageCommunicationManager.Start(Connection.CurrentSite.FQID.ServerId);
                mc = MessageCommunicationManager.Get(Connection.CurrentSite.FQID.ServerId);
        
                obj = mc.RegisterCommunicationFilter(ProvideCurrentStateResponse,
                    new CommunicationIdFilter(MessageCommunication.ProvideCurrentStateResponse));
                mc.TransmitMessage(new Message(MessageCommunication.ProvideCurrentStateRequest), null, null, null);
                cts = new CancellationTokenSource(Timeout);
                foreach (var itemState in _itemStates.GetConsumingEnumerable(cts.Token))
                {
                    // Ignore Event item states
                    var kind = Kind.DefaultTypeToNameTable.ContainsKey(itemState.FQID.Kind)
                        ? Kind.DefaultTypeToNameTable[itemState.FQID.Kind].ToString()
                        : "External";
                    if (kind == "Event") continue;
                    
                    var item = Configuration.Instance.GetItem(itemState.FQID);

                    // Ignore ItemState records where no corresponding item can be found
                    // These are typically Generic Events or built-in system events
                    if (item == null && kind == "Server") continue;

                    // Enrich the ItemState with helpful properties
                    var psObj = PSObject.AsPSObject(itemState);
                    psObj.Properties.Add(new PSNoteProperty("Name", item?.Name ?? "Not available"));
                    psObj.Properties.Add(new PSNoteProperty("ItemType", kind));
                    psObj.Properties.Add(new PSNoteProperty("Id", itemState.FQID.ObjectId));
                    
                    WriteObject(psObj);
                }
            }
            catch (PipelineStoppedException)
            {
                throw;
            }
            catch (OperationCanceledException cancelledException)
            {
                WriteError(
                    new ErrorRecord(
                        cancelledException, $"The operation timed out after the Timeout delay of {Timeout}", ErrorCategory.OperationTimeout, null));
            }
            catch (Exception e)
            {
                WriteError(
                    new ErrorRecord(
                        e, e.Message, ErrorCategory.InvalidResult, null));
            }
            finally
            {
                cts?.Dispose();
                mc?.UnRegisterCommunicationFilter(obj);
                mc?.Dispose();
                MessageCommunicationManager.Stop(Connection.CurrentSite.FQID.ServerId);
            }
        }

        private object ProvideCurrentStateResponse(Message message, FQID destination, FQID sender)
        {
            try
            {
                var result = message.Data as Collection<ItemState>;
                foreach (var itemState in result ?? new Collection<ItemState>())
                {
                    if (CamerasOnly && itemState.FQID.Kind != Kind.Camera) continue;
                    _itemStates.Add(itemState);
                }
            }
            catch (Exception)
            {
                _itemStates.CompleteAdding();
            }
            finally
            {
                _itemStates.CompleteAdding();
            }
            return null;
        }
    }
}

