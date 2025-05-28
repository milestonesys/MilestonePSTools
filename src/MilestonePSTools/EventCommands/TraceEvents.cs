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
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Threading;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Data;
using VideoOS.Platform.Messaging;

namespace MilestonePSTools.EventCommands
{
    /// <summary>
    /// <para type="synopsis">Subscribes to Milestone events from the Event Server</para>
    /// <para type="description">Subscribes to events from the Event Server. By default only
    /// MessageId.Server.NewEventsIndication events are subscribed to, but you can either
    /// manually supply your own MessageId's in the Message parameter or you can use the built-in
    /// switches to include configuration changes and failover event messages.</para>
    /// <para type="description">Events are transposed to a more PowerShell-friendly shape by
    /// default but with the -Raw switch you can get the original event objects which will have
    /// far more detail. For example, you can dig in to analytic events to retrieve information
    /// like plate # and confidence value.</para>
    /// <example>
    ///     <code>C:\PS> Trace-Events -MaxEvents 10 -Timeout (New-Timespan -Seconds 60)</code>
    ///     <para>Captures up to 10 events and times out after 60 seconds if less than 10 events are received.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html">MIP SDK Documentation</para>
    /// </summary>
    [Cmdlet(VerbsDiagnostic.Trace, "Events")]
    [OutputType(typeof(TraceEventsMessage))]
    [RequiresVmsConnection()]
    public class TraceEvents : ConfigApiCmdlet
    {
        private BlockingCollection<MessageQueueMessage> _messageQueue;
        private int _eventsReceived;
        private Timer _interEventTimer;

        /// <summary>
        /// <para type="description">Optional user-defined MessageId values to register a listener for</para>
        /// </summary>
        [Parameter]
        public string[] Message { get; set; } = new string[0];

        /// <summary>
        /// <para type="description">Filter the NewEventIndication messages to include only those with the designated Event Header Type.</para>
        /// </summary>
        [Parameter]
        [ValidateSet(
            EventHeaderTypes.AccessControlSystemEventType,
            EventHeaderTypes.LPREventType,
            EventHeaderTypes.LPRServerEventType,
            EventHeaderTypes.LPRVideoSourceEventType,
            EventHeaderTypes.SystemAlarmType,
            EventHeaderTypes.SystemEventType,
            EventHeaderTypes.SystemMADType)]
        public string EventHeaderType { get; set; } = null;

        /// <summary>
        /// <para type="description">Filter the NewEventIndication messages to include only those with the a message value matching a specific value. Only valid if EventHeaderType is null.</para>
        /// </summary>
        [Parameter]
        [ValidateNotNullOrEmpty]
        public string EventHeaderMessage { get; set; } = null;

        /// <summary>
        /// <para type="description">Specifies that you wish to receive events sent about configuration changes</para>
        /// </summary>
        [Parameter]
        public SwitchParameter IncludeConfigurationChanged { get; set; }

        /// <summary>
        /// <para type="description">Specifies that you wish to receive events sent about Recording Server failovers</para>
        /// </summary>
        [Parameter]
        public SwitchParameter IncludeFailover { get; set; }

        /// <summary>
        /// <para type="description">Specifies that you wish not to see NewEventsIndication messages. Use this if you're looking for more specific events and you know the MessageId for those events</para>
        /// </summary>
        [Parameter]
        public SwitchParameter ExcludeNewEventsIndication { get; set; }

        /// <summary>
        /// <para type="description">Specifies that you want to listen for events from all sites in a Milestone Federated Hierarchy.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter TraceAllSites { get; set; }

        /// <summary>
        /// <para type="description">Specifies that you want to receive an unaltered copy of the event indications from the Event Server. The event will be wrapped in a MessageQueueMessage object which contains the Message and a datetime value named TimeReceived which represents the time the message was received in this PowerShell session. The TimeReceived may be a few seconds older than the time the event is written to the pipeline since there may be some event queuing in the local session depending on how long your event post-processing takes.</para>
        /// </summary>
        [Parameter] 
        public SwitchParameter Raw { get; set; }

        /// <summary>
        /// <para type="description">Specifies that you want to stop listening for events after a given number of events have been received. If the value is less than 1, there will be no limit imposed and you may need to interrupt the trace manually to stop it with CTRL+C</para>
        /// </summary>
        [Parameter]
        public int MaxEvents { get; set; } = -1;

        /// <summary>
        /// <para type="description">Specifies that you want to listen for events for a limited time. There is no Timeout by default.</para>
        /// </summary>
        [Parameter]
        public TimeSpan Timeout { get; set; } = TimeSpan.FromMilliseconds(-1);

        /// <summary>
        /// <para type="description">Specifies a TimeSpan to wait between events before stopping the trace. There is no limit by default.</para>
        /// </summary>
        [Parameter]
        public TimeSpan MaxInterEventDelay { get; set; } = TimeSpan.FromMilliseconds(-1);

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            _messageQueue?.Dispose();
            _messageQueue = new BlockingCollection<MessageQueueMessage>();
            if (Timeout.TotalMilliseconds > int.MaxValue)
            {
                WriteWarning($"Timeout will be reduced as it cannot be greater than {int.MaxValue} milliseconds.");
                Timeout = TimeSpan.FromMilliseconds(int.MaxValue);
            }
            if (MaxInterEventDelay.TotalMilliseconds > int.MaxValue)
            {
                WriteWarning($"MaxInterEventDelay will be reduced as it cannot be greater than {int.MaxValue} milliseconds.");
                MaxInterEventDelay = TimeSpan.FromMilliseconds(int.MaxValue);
            }

            var filters = new Dictionary<ServerId, List<object>>();
            var serverIds = new List<ServerId>();
            var commManagers = new List<MessageCommunication>();
            var messages = new List<string>(Message);
            if (!ExcludeNewEventsIndication) messages.Add(MessageId.Server.NewEventsIndication);
            if (IncludeConfigurationChanged) messages.AddRange(new []{ MessageId.Server.ConfigurationChangedIndication, VideoOS.Platform.Messaging.MessageId.System.SystemConfigurationChangedIndication});
            if (IncludeFailover) messages.Add(MessageId.Server.RecorderFQIDChangedIndication);
            
            if (TraceAllSites)
            {
                serverIds.AddRange(Connection.GetSites().Select(s => s.FQID.ServerId));
            }
            else
            {
                serverIds.Add(Connection.CurrentSite.FQID.ServerId);
            }
            try
            {
                serverIds.ForEach(serverId =>
                {
                    MessageCommunicationManager.Start(serverId);
                    var msg = MessageCommunicationManager.Get(serverId);
                    commManagers.Add(msg);
                    filters.Add(serverId, new List<object>());
                    messages.ForEach(messageId =>
                    {
                        WriteVerbose($"Registering communication filter for MessageId '{messageId}' on site {serverId.Uri}");
                        if (messageId.Equals(MessageId.Server.NewEventsIndication))
                        {
                            
                            filters[serverId]
                                .Add(msg.RegisterCommunicationFilter(Receiver, new CommunicationIdFilter(messageId, EventHeaderType, EventHeaderMessage)));
                        }
                        else
                        {
                            filters[serverId]
                                .Add(msg.RegisterCommunicationFilter(Receiver, new CommunicationIdFilter(messageId)));
                        }
                    });
                });

                using (new Timer(TimeoutCallback, null, Timeout, TimeSpan.FromMilliseconds(-1)))
                using (_interEventTimer = new Timer(TimeoutCallback, null, TimeSpan.FromMilliseconds(-1), TimeSpan.FromMilliseconds(-1)))
                {
                    Listen();
                }
            }
            finally
            {
                foreach (var mgr in commManagers)
                {
                    filters[mgr.ServerId].ForEach(mgr.UnRegisterCommunicationFilter);
                    MessageCommunicationManager.Stop(mgr.ServerId);
                }
            }
        }

        private void TimeoutCallback(object state)
        {
            _messageQueue.CompleteAdding();
        }

        private void Listen()
        {
            foreach (var messageQueueMessage in _messageQueue.GetConsumingEnumerable())
            {
                var message = messageQueueMessage.Message;
                if (_messageQueue.Count > 1)
                {
                    WriteWarning($"Events in queue: {_messageQueue.Count}");
                }
                if (Raw)
                {
                    _eventsReceived++;
                    WriteObject(messageQueueMessage);
                }
                else
                {
                    switch (message.MessageId)
                    {
                        case MessageId.Server.NewEventsIndication:
                            {
                                foreach (var baseEvent in (IEnumerable<BaseEvent>)message.Data)
                                {
                                    _eventsReceived++;
                                    var msg = new TraceEventsMessage
                                    {
                                        Timestamp = baseEvent.EventHeader.Timestamp,
                                        Message = baseEvent.EventHeader.Message,
                                        MessageId = message.MessageId,
                                        SourceId = baseEvent.EventHeader.Source.FQID.ObjectId,
                                        SourceName = baseEvent.EventHeader.Source.Name,
                                    };

                                    try
                                    {
                                        msg.SourceUri = baseEvent.EventHeader.Source.FQID.ServerId.Uri?.ToString();
                                    }
                                    catch (Exception ex)
                                    {
                                        WriteVerbose("Error parsing Source.FQID.ServerId.Uri: " + ex.Message);
                                    }
                                    WriteObject(msg);
                                }
                                break;
                            }
                        case MessageId.Server.ConfigurationChangedIndication:
                            {
                                _eventsReceived++;
                                var item = Configuration.Instance.GetItem(message.RelatedFQID);
                                if (item == null) break;
                                var msg = new TraceEventsMessage
                                {
                                    Timestamp = DateTime.UtcNow,
                                    Message = "ConfigurationChangedIndication",
                                    MessageId = message.MessageId,
                                    SourceId = item.FQID.ObjectId,
                                    SourceName = item.Name,
                                    SourceUri = item.FQID.ServerId.Uri.ToString()
                                };
                                WriteObject(msg);
                                break;
                            }
                        case "System.SystemConfigurationChangedIndication":
                            {
                                _eventsReceived++;
                                var item = Configuration.Instance.GetItem(message.RelatedFQID);
                                if (item == null) break;
                                var msg = new TraceEventsMessage
                                {
                                    Timestamp = DateTime.UtcNow,
                                    Message = "SystemConfigurationChangedIndication",
                                    MessageId = message.MessageId,
                                    SourceId = item.FQID.ObjectId,
                                    SourceName = item.Name,
                                    SourceUri = item.FQID.ServerId.Uri.ToString()
                                };
                                WriteObject(msg);
                                break;
                            }
                        case MessageId.Server.RecorderFQIDChangedIndication:
                            {
                                _eventsReceived++;
                                var msg = new TraceEventsMessage
                                {
                                    Timestamp = DateTime.UtcNow,
                                    Message = "Failover",
                                    MessageId = message.MessageId,
                                    SourceId = message.RelatedFQID.ServerId.Id,
                                };
                                try
                                {
                                    msg.SourceUri = message.RelatedFQID.ServerId.Uri.ToString();
                                    var recorder = new RecordingServer(message.RelatedFQID.ServerId,
                                        $"RecordingServer[{message.RelatedFQID.ServerId.Id}]");
                                    msg.SourceName = recorder.Name;
                                }
                                catch (UriFormatException)
                                {
                                    WriteVerbose($"{nameof(UriFormatException)}: Invalid URI on {msg.Message} event.");
                                }
                                catch (Exception)
                                {
                                    msg.SourceName = "Unknown";
                                }
                                WriteObject(msg);
                                break;
                            }
                        default:
                            {
                                _eventsReceived++;
                                var msg = new TraceEventsMessage
                                {
                                    Timestamp = DateTime.UtcNow,
                                    Message = message.MessageId,
                                    MessageId = message.MessageId,
                                    SourceId = message.RelatedFQID.ServerId.Id,
                                };
                                try
                                {
                                    msg.SourceUri = message.RelatedFQID.ServerId.Uri?.ToString();
                                }
                                catch (UriFormatException)
                                {
                                    WriteVerbose($"{nameof(UriFormatException)}: Invalid URI on {msg.Message} event.");
                                }
                                WriteObject(msg);
                                break;
                            }
                    }
                }
                
                if (!_messageQueue.IsAddingCompleted && MaxEvents > 0 && _eventsReceived >= MaxEvents)
                {
                    WriteVerbose($"Ending trace after receiving {_eventsReceived} with a MaxEvents value of {MaxEvents}");
                    _messageQueue.CompleteAdding();
                }
            }
        }

        private object Receiver(Message message, FQID destination, FQID sender)
        {
            _messageQueue.Add(new MessageQueueMessage(message));
            _interEventTimer.Change(MaxInterEventDelay, TimeSpan.FromMilliseconds(-1));
            return null;
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void StopProcessing()
        {
            if (!_messageQueue.IsAddingCompleted)
            {
                _messageQueue.CompleteAdding();
            }
        }

        protected override void EndProcessing()
        {
            if (!_messageQueue.IsAddingCompleted)
            {
                _messageQueue.CompleteAdding();
            }
        }
    }
}

