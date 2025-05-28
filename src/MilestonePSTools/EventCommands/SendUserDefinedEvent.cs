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
using System.Collections.Generic;
using System.Management.Automation;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Messaging;

namespace MilestonePSTools.EventCommands
{
    [Cmdlet(VerbsCommunications.Send, nameof(UserDefinedEvent))]
    [RequiresVmsConnection()]
    public class SendUserDefinedEvent : ConfigApiCmdlet
    {
        [Parameter(Position = 1, ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromObject")]
        public UserDefinedEvent UserDefinedEvent { get; set; }

        [Parameter(Position = 2, ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromId")]
        public string Id { get; set; }

        [Parameter(Position = 3, ParameterSetName = "FromObject")]
        [Parameter(Position = 4, ParameterSetName = "FromId")]
        public Camera[] Cameras { get; set; }

        [Parameter(Position = 5, ParameterSetName = "FromObject")]
        [Parameter(Position = 6, ParameterSetName = "FromId")]
        public Microphone[] Microphones { get; set; }

        [Parameter(Position = 7, ParameterSetName = "FromObject")]
        [Parameter(Position = 8, ParameterSetName = "FromId")]
        public Speaker[] Speakers { get; set; }

        [Parameter(Position = 9, ParameterSetName = "FromObject")]
        [Parameter(Position = 10, ParameterSetName = "FromId")]
        public Metadata[] Metadatas { get; set; }

        [Parameter(Position = 11, ParameterSetName = "FromObject")]
        [Parameter(Position = 12, ParameterSetName = "FromId")]
        public InputEvent[] Inputs { get; set; }

        [Parameter(Position = 13, ParameterSetName = "FromObject")]
        [Parameter(Position = 14, ParameterSetName = "FromId")]
        public Output[] Outputs { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                var rootItem = Configuration.Instance.GetItem(Connection.CurrentSite.FQID);
                var fqid = new FQID(Connection.CurrentSite.FQID.ServerId, Connection.CurrentSite.FQID.ServerId.Id, new Guid(Id ?? UserDefinedEvent.Id), FolderType.No, Kind.TriggerEvent);
                fqid.ServerId.UserContext = rootItem.FQID.ServerId.UserContext;
                
                var relatedItemFquids = new List<FQID>();
                relatedItemFquids.AddRange(GetFqidsForKind(Cameras, Kind.Camera));
                relatedItemFquids.AddRange(GetFqidsForKind(Microphones, Kind.Microphone));
                relatedItemFquids.AddRange(GetFqidsForKind(Speakers, Kind.Speaker));
                relatedItemFquids.AddRange(GetFqidsForKind(Metadatas, Kind.Metadata));
                relatedItemFquids.AddRange(GetFqidsForKind(Inputs, Kind.InputEvent));
                relatedItemFquids.AddRange(GetFqidsForKind(Outputs, Kind.Output));
                
                EnvironmentManager.Instance.PostMessage(
                    new Message(MessageId.Control.TriggerCommand, relatedItemFquids),
                    fqid);
            }
            catch (Exception ex)
            {
                WriteExceptionError(ex);
            }
        }

        private IEnumerable<FQID> GetFqidsForKind(IReadOnlyCollection<dynamic> devices, Guid kind)
        {
            var list = new List<FQID>();
            if (devices == null || devices.Count == 0) return list;
            foreach (var device in devices)
            {
                var item = Configuration.Instance.GetItem(new Guid(device.Id), kind);
                if (item == null)
                {
                    WriteError(
                        new ErrorRecord(
                            new ArgumentException(nameof(Cameras)),
                            $"Camera {device.Name} not found",
                            ErrorCategory.InvalidArgument,
                            null));
                }
                else
                {
                    list.Add(item.FQID);
                }
            }

            return list;
        }
    }
}
