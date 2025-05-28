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
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Net.Sockets;
using System.Text;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.EventCommands
{
    /// <summary>
    /// <para type="synopsis">Sends a TCP or UDP message to the Event Server to trigger a Generic Event</para>
    /// <para type="description">Generic Events are a way to receive predefined strings or patterns as strings
    /// over TCP/UDP in order to trigger events, which can then be used as a trigger for a rule to perform
    /// some action.</para>
    /// <para type="description">This command simplifies testing of generic events by automatically retrieving
    /// the correct host/ip and port, appending the 'separator bytes' if defined in the Data Source configuration
    /// in Management Client under Tools > Options > Generic Events, and parsing the response in the event the
    /// Data Source is configured to echo 'Statistics'.</para>
    /// <para type="description">For debugging, try adding -Verbose and reviewing some of the details provided.</para>
    /// <example>
    ///     <code>C:\PS> Send-GenericEvent "Hello World"</code>
    ///     <para>Sends the string "Hello World" to the first enabled Generic Event Data Source, which is usually
    /// named "Compatible" and listens on TCP port 1234.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS> Send-GenericEvent "Hello World" CustomDataSource</code>
    ///     <para>Sends the string "Hello World" a Data Source named CustomDataSource. The port and protocol would be
    /// defined in that data source but you can see those values in the output when you provide the -Verbose switch.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html">MIP SDK Documentation</para>
    /// </summary>
    [Cmdlet(VerbsCommunications.Send, nameof(GenericEvent))]
    [OutputType(typeof(string))]
    [RequiresVmsConnection()]
    public class SendGenericEvent : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the GenericEventDataSource to send the EventString to</para>
        /// <para type="description">If omitted, the first enabled data source will be used.</para>
        /// </summary>
        [Parameter]
        public GenericEventDataSource DataSource { get; set; }

        /// <summary>
        /// <para type="description">Specifies the string to send to the Event Server</para>
        /// </summary>
        [Parameter(Mandatory = true, Position = 1)]
        public string EventString { get; set; }

        /// <summary>
        /// <para type="description">Specifies the name of the GenericEventDataSource to send the EventString to</para>
        /// <para type="description">If omitted, the first enabled data source will be used.</para>
        /// </summary>
        [Parameter(Position = 2)]
        public string DataSourceName { get; set; }

        /// <summary>
        /// <para type="description">Specifies the timeout in milliseconds to wait for a response when Echo is not "None" and the protocol is not UDP.</para>
        /// <para type="description">Default is 2000ms</para>
        /// </summary>
        [Parameter(Position = 3)]
        [ValidateRange(1, 60000)]
        public int ReadTimeout { get; set; } = 2000;

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            var dataSource = DataSource ?? GetDataSource();
            WriteVerbose($"Selecting Generic Event Data Source named \"{dataSource.DisplayName}\"");
            WriteVerbose($"There are {dataSource.DataSourceAllowed.Split(new []{';'}, StringSplitOptions.RemoveEmptyEntries).Count(s => !string.IsNullOrWhiteSpace(s))} external IPv4 addresses allowed to send Generic Events");
            WriteVerbose($"There are {dataSource.DataSourceAllowed6.Split(new []{';'}, StringSplitOptions.RemoveEmptyEntries).Count(s => !string.IsNullOrWhiteSpace(s))} external IPv6 addresses allowed to send Generic Events");
            var encoding = Encoding.GetEncoding(dataSource.DataSourceEncoding);
            WriteVerbose($"Encoding EventString using {encoding.EncodingName} encoding");
            var separatorChars = GetSeparatorChars(dataSource);
            if (separatorChars.Length > 0)
            {
                WriteVerbose($"Appending {separatorChars.Length} separator characters as defined in the Generic Event Data Source configuration");
            }
            var uri = GetEventServerUri();
            var response = SendAndReceive(
                EventString, 
                separatorChars,
                encoding,
                uri.Host, 
                dataSource.DataSourcePort,
                dataSource.DataSourceProtocol,
                dataSource.DataSourceEcho != "None");
            ProcessResponse(response, dataSource.DataSourceEcho);
        }

        private GenericEventDataSource GetDataSource()
        {
            var dataSources = new GenericEventDataSourceFolder().GenericEventDataSources;
            var dataSource = string.IsNullOrEmpty(DataSourceName) 
                    ? dataSources.FirstOrDefault(s => s.Enabled)
                    : dataSources.FirstOrDefault(s => s.Name.Equals(DataSourceName, StringComparison.OrdinalIgnoreCase));
            return dataSource 
                   ?? throw new InvalidOperationException("No Data Source found");
        }

        private char[] GetSeparatorChars(GenericEventDataSource dataSource)
        {
            var separators = new char[0];
            if (!string.IsNullOrWhiteSpace(dataSource.DataSourceSeparator))
            {
                var separatorStrings = dataSource.DataSourceSeparator.Split(new[] {','}, StringSplitOptions.RemoveEmptyEntries);
                separators = separatorStrings.Select(s => (char) int.Parse(s)).ToArray();
            }

            return separators;
        }

        private Uri GetEventServerUri()
        {
            var evsList = Configuration.Instance.GetRegisteredServiceUriInfo(Configuration.MAPServiceType,
                Connection.CurrentSite.FQID.ServerId);
            if (evsList.Count == 0)
            {
                throw new InvalidOperationException("No Event Server found");
            }
            return new Uri(evsList[0].UriArray.First());
        }

        private string SendAndReceive(string content, char[] delimiters, Encoding encoding, string host, int port, string protocol, bool waitForResponse)
        {
            if (protocol.Equals("Udp"))
            {
                SendAndReceiveOverUdp(content, delimiters, encoding, host, port);
                return null;
            }
            WriteVerbose($"Sending EventString to {host}:{port} over TCP");
            using (var client = new TcpClient(host, port))
            using (var stream = client.GetStream())
            using (var sw = new StreamWriter(stream, encoding))
            {
                sw.Write(content);
                sw.Write(delimiters);
                sw.Flush();
                WriteVerbose("Bytes sent.");
                if (waitForResponse && delimiters.Length == 0)
                {
                    WriteWarning("This data source is configured to echo, but there are no separator bytes configured. This means the Event Server can only process the generic event message after the connection is closed.");
                    WriteWarning("Add \"13,10\" as your Data Source's separator bytes. This is equivalent to \\r\\n and these will automatically be appended to your message when you use this command.");
                }
                else if (waitForResponse)
                {
                    WriteVerbose($"Awaiting response. Timeout = {ReadTimeout}ms");
                    stream.ReadTimeout = ReadTimeout;
                    var buffer = new byte[client.Client.ReceiveBufferSize];
                    var bytesRead = stream.Read(buffer, 0, buffer.Length);
                    if (bytesRead > 0)
                    {
                        WriteVerbose($"Received {bytesRead} byte response");
                        var receivedData = new byte[bytesRead];
                        Array.Copy(buffer, receivedData, bytesRead);
                        return encoding.GetString(receivedData);
                    }
                    else
                    {
                        WriteWarning("Response expected and not received");
                    }
                }
            }

            return null;
        }

        private void SendAndReceiveOverUdp(string content, char[] delimiters, Encoding encoding, string host, int port)
        {
            WriteVerbose($"Sending EventString to {host}:{port} over UDP");
            using (var client = new UdpClient())
            {
                client.Connect(host, port);
                var bytes = encoding.GetBytes(content);
                var bytesSent = client.Send(bytes, bytes.Length);
                bytes = encoding.GetBytes(delimiters);
                bytesSent += client.Send(bytes, bytes.Length);
                WriteVerbose($"Sent {bytesSent} bytes");
            }
        }

        private void ProcessResponse(string response, string echoValue)
        {
            if (string.IsNullOrEmpty(response)) return;
            if (response.Equals("No access"))
                WriteWarning($"Event Server responded with '{response}'. This is normally because the IP address of the system sending the message is not added to the list of allowed external addresses for Generic Events.");
            if (echoValue.Equals("Statistics"))
            {
                try
                {
                    var parts = response.Split(new[] { ',' }, 4);
                    var obj = new PSObject();
                    obj.Members.Add(new PSNoteProperty("RequestNumber", int.Parse(parts[0])));
                    obj.Members.Add(new PSNoteProperty("Length", int.Parse(parts[1])));
                    obj.Members.Add(new PSNoteProperty("MatchCount", int.Parse(parts[2])));
                    obj.Members.Add(new PSNoteProperty("MatchedEvent", parts.Length == 4 ? parts[3] : ""));
                    WriteObject(obj);
                }
                catch (Exception ex)
                {
                    WriteObject(response);
                    WriteError(new ErrorRecord(ex, "Error parsing statistics in response", ErrorCategory.InvalidResult, response));
                }
            }
            else
            {
                WriteObject(response);
            }
        }
    }
}
