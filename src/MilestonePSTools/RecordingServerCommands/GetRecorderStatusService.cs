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
using VideoOS.Platform.SDK.Proxy.Status2;

namespace MilestonePSTools.RecordingServerCommands
{
    [Cmdlet(VerbsCommon.Get, nameof(RecorderStatusService2), DefaultParameterSetName = "FromRecordingServer")]
    [OutputType(typeof(RecorderStatusService2))]
    [RequiresVmsConnection(false)]
    public class GetRecorderStatusService2 : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "FromRecordingServer")]
        public RecordingServer RecordingServer { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = "FromUri")]
        [ValidateNotNull()]
        public Uri Uri { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                if (ParameterSetName == "FromRecordingServer") {
                    var server = VideoOS.Platform.Configuration.Instance.GetItem(new Guid(RecordingServer.Id), VideoOS.Platform.Kind.Server);
                    Uri = server?.FQID.ServerId.Uri;
                }
                if (Uri == null) {
                    throw new ArgumentException();
                }
                var svc = new RecorderStatusService2(Uri);
                WriteObject(svc);
            }
            catch (ArgumentException)
            {
                    WriteError(new ErrorRecord(
                        new ArgumentException("Recording Server URI is invalid or missing.", nameof(RecordingServer)),
                        "InvalidRecordingServerUri",
                        ErrorCategory.InvalidArgument,
                        RecordingServer)
                    );
            }
            catch (Exception ex)
            {
                WriteExceptionError(ex);
            }
        }
    }
}

