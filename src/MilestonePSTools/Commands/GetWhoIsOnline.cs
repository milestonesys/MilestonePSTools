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

namespace MilestonePSTools.Commands
{
    /// <summary>
    /// <para type="synopsis">Gets the response to the MIP message 'MessageCommunication.WhoAreOnlineRequest'</para>
    /// <para type="description">The MIP SDK provides the MessageCommunication.WhoAreOnlineRequest and MessageCommunication.WhoAreOnlineResponse
    /// messages for getting a list of endpoint FQID's which can then potentially be used as destination addresses for other MIP messages.
    ///
    /// Each EndPointIdentityData object provides an 'IdentityName' property with the format 'Administrator  (0.0.0.0)' which can be used
    /// to get a general idea of who is connected to the Management Server and from which network location.
    ///
    /// Note that this is not meant as a perfect user session monitoring solution and you may see duplicate entries including entries
    /// representing the Milestone services themselves such as for the Event Server or Log Server.</para>
    /// <example>
    ///     <code>C:\PS>Get-WhoIsOnline</code>
    ///     <para>Get a list of user sessions with a default timeout value of 10 seconds</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-WhoIsOnline -Timeout 2</code>
    ///     <para>Get a list of user sessions with a custom timeout value of 2 seconds</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "WhoIsOnline")]
    [OutputType(typeof(EndPointIdentityData))]
    [RequiresVmsConnection()]
    public class GetWhoIsOnline : ConfigApiCmdlet
    {
        private readonly object _lock = new object();
        private BlockingCollection<EndPointIdentityData> _endpoints;
        private Timer _timer;
        private bool _responseReceived;

        /// <summary>
        /// <para type="description">Time, in seconds, to wait for the first result.</para>
        /// </summary>
        [Parameter(Position = 1)]
        public double Timeout { get; set; } = 10;

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            _endpoints = new BlockingCollection<EndPointIdentityData>();
            MessageCommunication mc = null;
            object obj = null;
            try
            {
                MessageCommunicationManager.Start(Connection.CurrentSite.FQID.ServerId);
                mc = MessageCommunicationManager.Get(Connection.CurrentSite.FQID.ServerId);

                obj = mc.RegisterCommunicationFilter(WhoAreOnlineResponseHandler,
                    new CommunicationIdFilter(MessageCommunication.WhoAreOnlineResponse));
                mc.TransmitMessage(new Message(MessageCommunication.WhoAreOnlineRequest), null, null, null);
                _timer = new Timer(CompleteEndpointsCollection, null, TimeSpan.FromSeconds(Timeout), TimeSpan.Zero);
                foreach (var endpoint in _endpoints.GetConsumingEnumerable())
                {
                    WriteObject(endpoint);
                }

                if (!_responseReceived)
                {
                    WriteError(new ErrorRecord(
                        new TimeoutException(
                            $"Timeout of {Timeout} seconds reached before '{MessageCommunication.WhoAreOnlineResponse}' message received."),
                        "The timeout was reached before a response was received.", ErrorCategory.OperationTimeout,
                        null));
                }
            }
            catch (PipelineStoppedException)
            {
                throw;
            }
            catch (Exception e)
            {
                WriteError(
                    new ErrorRecord(
                        e, e.Message, ErrorCategory.InvalidResult, null));
            }
            finally
            {
                _timer.Dispose();
                mc?.UnRegisterCommunicationFilter(obj);
                mc?.Dispose();
                MessageCommunicationManager.Stop(Connection.CurrentSite.FQID.ServerId);
            }
        }

        private void CompleteEndpointsCollection(object state)
        {
            lock (_lock)
            {
                if (!_endpoints.IsCompleted)
                {
                    _endpoints.CompleteAdding();
                }
            }
        }

        private object WhoAreOnlineResponseHandler(Message message, FQID destination, FQID sender)
        {
            lock (_lock)
            {
                if (!(message.Data is Collection<EndPointIdentityData> endpoints)) return null;
                _responseReceived = true;
                _timer.Change(TimeSpan.FromMilliseconds(-1), TimeSpan.FromMilliseconds(-1));
                foreach (var endpoint in endpoints)
                {
                    _endpoints.Add(endpoint);
                }
                _endpoints.CompleteAdding();
                return null; 
            }
        }
    }
}

