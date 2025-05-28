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
using System.Diagnostics;
using System.Management.Automation;
using System.Threading;
using System.Threading.Tasks;
using VideoOS.Platform;
using VideoOS.Platform.Messaging;

namespace MilestonePSTools.Messaging
{
    /// <summary>
    /// <para type="synopsis">Sends a custom MIP message and optionally awaits the response.</para>
    /// <para type="description">Messaging is a core feature and component of the MIP SDK. Almost all actions and queries are
    /// handled through messaging. This cmdlet provides a mechanism for interacting with the messaging framework from
    /// PowerShell which gives you a fairly low-level interface into the VMS. As such, it can be complex to use and
    /// you should consult the MIP SDK documentation to better understand the available messages and how to use them.</para>
    /// <example>
    ///     <code>C:\PS>Send-MipMessage -MessageId Control.TriggerCommand -DestinationEndpoint $presets[0].FQID -UseEnvironmentManager</code>
    ///     <para>Activates a PTZ preset using the Control.TriggerCommand message. The DestinationEndpoint should be the FQID of a
    /// PtzPreset object. To get a list of PtzPreset items for a camera, you could do
    /// $presets = $camera.PtzPresetFolder.PtzPresets | Get-PlatformItem</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommunications.Send, "MipMessage")]
    [OutputType(typeof(string))]
    [RequiresVmsConnection()]
    public class SendMipMessage : ConfigApiCmdlet
    {
        private Timer _timer;
        private BlockingCollection<Message> _responseMessages;
        private bool _responseReceived;
        private MessageCommunication _mc;

        /// <summary>
        /// <para type="description">MessageId string to send.</para>
        /// </summary>
        [Parameter(Position = 1, Mandatory = true)]
        public string MessageId { get; set; }

        /// <summary>
        /// <para type="description">Defines the FQID of the device or item related to the provided MessageId.</para>
        /// </summary>
        [Parameter(Position = 2)]
        public FQID RelatedFqid { get; set; }

        /// <summary>
        /// <para type="description">Some MessageIds such as those related to PTZ are accompanied by some kind of object.
        /// Reference the MIP SDK documentation for more information about expected objects.</para>
        /// </summary>
        [Parameter(Position = 3)]
        public object Data { get; set; }

        /// <summary>
        /// <para type="description">Specifies the reason the message is being sent. Not commonly used.</para>
        /// </summary>
        [Parameter(Position = 4)]
        public string Reason { get; set; }

        /// <summary>
        /// <para type="description">Defines the FQID of the destination client or server endpoint for this message.</para>
        /// </summary>
        [Parameter(Position = 5)]
        public FQID DestinationEndpoint { get; set; }

        /// <summary>
        /// <para type="description">Defines the FQID of an object on the DestinationEndpoint to receive this message.</para>
        /// </summary>
        [Parameter(Position = 6)]
        public FQID DestinationObject { get; set; }

        /// <summary>
        /// <para type="description">Defines the FQID of the sender (or null if the recipients don't care)</para>
        /// </summary>
        [Parameter(Position = 7)]
        public FQID Source { get; set; }

        /// <summary>
        /// <para type="description">Defines the MessageId to listen for as a response to this message. Optional.</para>
        /// </summary>
        [Parameter(Position = 8)]
        public string ResponseMessageId { get; set; }

        /// <summary>
        /// <para type="description">Time, in seconds, to wait for a response. If ResponseMessageId is null or whitespace,
        /// then a response is not expected and this cmdlet will return immediately after sending the message.
        ///
        /// Default is 10 seconds.</para>
        /// </summary>
        [Parameter(Position = 9)]
        public double Timeout { get; set; } = 10;

        /// <summary>
        /// <para type="description">Specifies that the message should be sent using EnvironmentManager.Instance instead
        /// of MessageCommunicationManager.
        ///
        /// Some MIP SDK messages are only delivered correctly when sent using the EnvironmentManager.</para>
        /// </summary>
        [Parameter(Position = 10)]
        public SwitchParameter UseEnvironmentManager { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            _responseMessages = new BlockingCollection<Message>();
            object obj = null;
            try
            {
                if (!string.IsNullOrWhiteSpace(ResponseMessageId))
                {
                    obj = RegisterFilter();
                    _timer = new Timer(TimeoutReached, null, TimeSpan.FromSeconds(Timeout), TimeSpan.FromMilliseconds(-1));
                }
                else
                {
                    _responseMessages.CompleteAdding();
                }

                var message = new Message(MessageId, RelatedFqid, Data, Reason);
                if (UseEnvironmentManager.IsPresent)
                {
                    var result = EnvironmentManager.Instance.SendMessage(message, DestinationEndpoint, Source);
                    if (result != null && result.Count > 0)
                    {
                        foreach (var o in result)
                        {
                            WriteObject(o);
                        }
                    }
                }
                else
                {
                    _mc = _mc ?? GetMessageCommunication();
                    _mc.TransmitMessage(message, DestinationEndpoint, DestinationObject, Source);
                }
                

                foreach (var response in _responseMessages.GetConsumingEnumerable())
                {
                    WriteObject(response);
                }

                if (!string.IsNullOrWhiteSpace(ResponseMessageId) && !_responseReceived)
                {
                    WriteError(new ErrorRecord(new TimeoutException($"Timeout of {Timeout} seconds reached before '{ResponseMessageId}' message received."), "The timeout was reached before a response was received.", ErrorCategory.OperationTimeout, null));
                }
            }
            catch (Exception e)
            {
                WriteError(
                    new ErrorRecord(
                        e, e.Message, ErrorCategory.InvalidResult, null));
            }
            finally
            {
                _timer?.Dispose();
                if (obj != null)
                {
                    UnregisterFilter(obj);
                }
            }
        }

        private void UnregisterFilter(object obj)
        {
            if (UseEnvironmentManager)
            {
                EnvironmentManager.Instance.UnRegisterReceiver(obj);
            }
            else
            {
                _mc?.UnRegisterCommunicationFilter(obj);
                _mc?.Dispose();
                MessageCommunicationManager.Stop(Connection.CurrentSite.FQID.ServerId);
            }
        }

        private object RegisterFilter()
        {
            object obj = null;
            var filter = new CommunicationIdFilter(ResponseMessageId);
            if (UseEnvironmentManager)
            {
                obj = EnvironmentManager.Instance.RegisterReceiver(ResponseHandler, new MessageIdFilter(ResponseMessageId));
            }
            else
            {
                _mc = _mc ?? GetMessageCommunication();
                obj = _mc.RegisterCommunicationFilter(ResponseHandler, filter);
                _mc.WaitForCommunicationFilterRegistration(filter, TimeSpan.FromSeconds(Timeout));
            }
            
            return obj;
        }

        private MessageCommunication GetMessageCommunication()
        {
            var sw = Stopwatch.StartNew();
            MessageCommunicationManager.Start(Connection.CurrentSite.FQID.ServerId);
            _mc = MessageCommunicationManager.Get(Connection.CurrentSite.FQID.ServerId);
            while (!_mc.IsConnected)
            {
                WriteWarning("Waiting for MessageCommunication connection . . .");
                if (sw.Elapsed.TotalSeconds > Timeout)
                {
                    throw new TimeoutException("Timeout while waiting for MessageCommunication connection.");
                }
                Task.Delay(TimeSpan.FromSeconds(1)).Wait();
            }
            sw.Stop();
            return _mc;
        }

        private void TimeoutReached(object state)
        {
            _responseMessages.CompleteAdding();
        }

        private object ResponseHandler(Message message, FQID destination, FQID sender)
        {
            _timer.Change(TimeSpan.FromMilliseconds(-1), TimeSpan.FromMilliseconds(-1));
            _responseReceived = true;
            _responseMessages.Add(message);
            _responseMessages.CompleteAdding();
            return null;
        }
    }
}
