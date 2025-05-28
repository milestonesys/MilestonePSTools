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
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Data;

namespace MilestonePSTools.SnapshotCommands
{
    [Cmdlet(VerbsDiagnostic.Test, "Playback")]
    [OutputType(typeof(bool))]
    [RequiresVmsConnection()]
    public class TestPlayback : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true)]
        public Camera Camera { get; set; }

        [Parameter]
        public Guid CameraId { get; set; }

        [Parameter]
        public DateTime Timestamp { get; set; } = DateTime.Now;

        [Parameter]
        [ValidateSet(validValues: new[] {"Forward", "Reverse", "Any"}, IgnoreCase = false)]
        public string Mode { get; set; } = "Any";

        private static readonly DateTime Epoch = DateTime.SpecifyKind(DateTimeOffset.FromUnixTimeMilliseconds(0).DateTime, DateTimeKind.Utc);

        protected override void ProcessRecord()
        {
            Timestamp = Timestamp.ToUniversalTime();
            if (Timestamp < Epoch) {
                Timestamp = Epoch;
            }
            ValidateParameters();
            RawVideoSource src = null;
            try
            {
                var cameraId = Camera != null ? new Guid(Camera.Id) : CameraId;
                var item = Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, cameraId, Kind.Camera);
                if (item == null)
                {
                    WriteWarning(
                        $"Configuration not available for camera with ID {cameraId}. It might be disabled.");
                    return;
                }

                src = new RawVideoSource(item);
                src.Init();
                WriteVerbose(
                    $"Calling GoToWithResult: timestamp={Timestamp:yyyy-MM-dd HH:mm:ss.fffZ}, Mode={Mode}");
                WriteObject(src.GoToWithResult(Timestamp, Mode));
            }
            catch (CommunicationMIPException)
            {
                WriteWarning($"Unable to connect to {src?.Item.Name} with ID {src?.Item.FQID.ObjectId}");
                WriteObject(false);
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.ConnectionError,
                        src));
                WriteObject(false);
            }
            finally
            {
                src?.Close();
            }
        }

        private void ValidateParameters()
        {
            if (Camera == null && CameraId == Guid.Empty)
            {
                WriteError(
                    new ErrorRecord(
                        new ArgumentException(nameof(Camera)),
                        "Supply Camera or valid CameraId parameter",
                        ErrorCategory.InvalidArgument,
                        null));
            }
        }
    }
}

