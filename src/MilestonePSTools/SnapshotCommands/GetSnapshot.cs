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
using System.Threading;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Data;
using VideoOS.Platform.Live;

namespace MilestonePSTools.SnapshotCommands
{
    [Cmdlet(VerbsCommon.Get, "Snapshot", DefaultParameterSetName = "FromLive")]
    [OutputType(typeof(LiveSourceContent), ParameterSetName = new []{"FromLive"})]
    [OutputType(typeof(JPEGData), ParameterSetName = new []{"FromPlayback"})]
    [RequiresVmsConnection()]
    public class GetSnapshot : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true)]
        public Camera Camera { get; set; }

        [Parameter(Position = 1)]
        public Guid CameraId { get; set; }

        [Parameter(Position = 2, ParameterSetName = "FromLive")]
        public SwitchParameter Live { get; set; }

        [Parameter(Position = 3, ParameterSetName = "FromPlayback")]
        public DateTime Timestamp { get; set; }

        [Parameter(ParameterSetName = "FromPlayback")]
        public DateTime EndTime { get; set; }

        [Parameter(ParameterSetName = "FromPlayback")]
        public double Interval { get; set; }

        [Parameter(Position = 4, ParameterSetName = "FromPlayback")]
        [ValidateSet("GetBegin", "GetEnd", "GetNearest")]
        public string Behavior { get; set; } = "GetNearest";

        [Parameter]
        public SwitchParameter Save { get; set; }

        [Parameter(Position = 6)]
        public string Path { get; set; } = Environment.CurrentDirectory;

        [Parameter(Position = 7)]
        public string FileName { get; set; }

        [Parameter]
        public SwitchParameter LocalTimestamp { get; set; }

        [Parameter]
        public int Width { get; set; }

        [Parameter]
        public int Height { get; set; }

        [Parameter]
        public SwitchParameter KeepAspectRatio { get; set; }

        [Parameter]
        public SwitchParameter IncludeBlackBars { get; set; }

        [Parameter]
        public SwitchParameter UseFriendlyName { get; set; }

        [Parameter]
        public SwitchParameter LiftPrivacyMask { get; set; }

        [Parameter] [ValidateRange(1, 100)]
        public int Quality { get; set; } = 75;

        [Parameter]
        [ValidateRange(1, 30000)]
        public int LiveTimeoutMS { get; set; } = 2000;

        protected override void ProcessRecord()
        {
            ValidateParameters();
            if (Live)
            {
                GetLiveSnapshot();
            }
            else
            {
                GetRecordedSnapshot();
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

        private readonly ManualResetEventSlim _liveDataSignal = new ManualResetEventSlim();
        private void GetLiveSnapshot()
        {
            JPEGLiveSource src = null;
            var cameraId = Camera == null ? CameraId : new Guid(Camera.Id);
            try
            {
                var item = Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, cameraId, Kind.Camera);
                item.FQID.ServerId.UserContext.SetPrivacyMaskLifted(LiftPrivacyMask);
                if (item == null)
                {
                    WriteWarning($"Configuration not available for camera with ID {cameraId}. It might be disabled.");
                    return;
                }
                src = new JPEGLiveSource(item)
                {
                    Width = Width,
                    Height = Height,
                    Compression = Quality,
                    SendInitialImage = false
                };
                src.SetKeepAspectRatio(KeepAspectRatio, IncludeBlackBars);
                src.LiveContentEvent += SrcOnLiveContentEvent;
                src.Init();
                src.LiveModeStart = true;
                var liveImageArrived = _liveDataSignal.Wait(TimeSpan.FromMilliseconds(LiveTimeoutMS));
                src.LiveContentEvent -= SrcOnLiveContentEvent;
                src.LiveModeStart = false;
                if (!liveImageArrived)
                {
                    WriteWarning($"No live image available for {src.Item.Name} after -{nameof(LiveTimeoutMS)} value of {LiveTimeoutMS}.");
                }
                else
                {
                    var snapshot = new JPEGData { Bytes = _liveContent.Content, DateTime = _liveContent.EndTime };
                    if (Save) SaveSnapshot(snapshot, src.Item);
                }
                WriteObject(_liveContent);
                _liveDataSignal.Reset();
            }
            catch (PipelineStoppedException)
            {
                throw;
            }
            catch (CommunicationMIPException)
            {
                WriteWarning($"Unable to connect to {src.Item.Name} with ID {src.Item.FQID.ObjectId}");
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.ConnectionError,
                        src));
            }
            finally
            {
                src?.Close();
            }
        }

        private readonly object _liveContentLock = new object();
        private LiveSourceContent _liveContent;
        private void SrcOnLiveContentEvent(object sender, EventArgs e)
        {
            lock (_liveContentLock)
            {
                if (_liveDataSignal.IsSet || !(e is LiveContentEventArgs liveContent)) return;
                if (liveContent.Exception != null) return;
                _liveContent = liveContent.LiveContent;
                _liveDataSignal.Set();
            }
        }

        private void GetRecordedSnapshot()
        {
            Timestamp = Timestamp.ToUniversalTime();
            EndTime = EndTime.ToUniversalTime();
            JPEGVideoSource src = null;
            var cameraId = Camera == null ? CameraId : new Guid(Camera.Id);
            try
            {
                var item = Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, cameraId, Kind.Camera);
                item.FQID.ServerId.UserContext.SetPrivacyMaskLifted(LiftPrivacyMask);
                if (item == null)
                {
                    WriteWarning($"Configuration not available for camera with ID {cameraId}. It might be disabled.");
                    return;
                }
                src = new JPEGVideoSource(item);
                src.SetKeepAspectRatio(KeepAspectRatio, IncludeBlackBars);
                src.Init(Width, Height);
                src.Compression = Quality;
                JPEGData snapshot = null;
                switch (Behavior.ToLower())
                {
                    case "getbegin":
                    {
                        snapshot = src.GetBegin();
                        WriteObject(snapshot);
                        if (Save) SaveSnapshot(snapshot, src.Item);
                        break;
                    }
                    case "getend":
                    {
                        snapshot = src.GetEnd();
                        WriteObject(snapshot);
                        if (Save) SaveSnapshot(snapshot, src.Item);
                        break;
                    }
                    case "getnearest":
                    {
                        var nextTimestamp = Timestamp;
                        var duration = EndTime <= Timestamp ? TimeSpan.Zero : EndTime - Timestamp;
                        var lastProgress = 0;
                        do
                        {
                            if (duration > TimeSpan.Zero)
                            {
                                var progressPercent =
                                    Convert.ToInt32((nextTimestamp - Timestamp).TotalSeconds / duration.TotalSeconds * 100);
                                if (progressPercent > lastProgress)
                                {
                                    WriteProgress(new ProgressRecord(0, $"Retrieving snapshot(s) for {(Camera?.Name ?? CameraId.ToString())}", $"Retrieving snapshot from {nextTimestamp.ToLocalTime()}") { PercentComplete = progressPercent });
                                    lastProgress = progressPercent;
                                }
                            }
                            snapshot = src.GetNearest(nextTimestamp) as JPEGData;
                            if (snapshot?.Bytes == null || snapshot.Bytes.Length == 0)
                            {
                                throw new InvalidDataException("Received empty snapshot");
                            }

                            if (snapshot.DateTime >= Timestamp || EndTime == DateTime.MinValue)
                            {
                                WriteObject(snapshot);
                                if (Save) SaveSnapshot(snapshot, src.Item);
                            }

                            if (!snapshot.IsNextAvailable) break;

                            nextTimestamp = Interval < 0.016 ? snapshot.NextDateTime : snapshot.DateTime.AddSeconds(Interval);
                            if (nextTimestamp < snapshot.NextDateTime)
                            {
                                nextTimestamp = snapshot.NextDateTime;
                            }
                        } while (nextTimestamp <= EndTime);
                        break;
                    }
                }
            }
            catch (CommunicationMIPException)
            {
                WriteWarning($"Unable to connect to {src?.Item.Name} with ID {src?.Item.FQID.ObjectId}");
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.ConnectionError,
                        src));
            }
            finally
            {
                WriteProgress(new ProgressRecord(0, $"Retrieving snapshot(s) for {(Camera?.Name ?? CameraId.ToString())}", "Completed") { PercentComplete = 100, RecordType = ProgressRecordType.Completed });
                src?.Close();
            }
        }

        private void SaveSnapshot(JPEGData snapshot, Item item)
        {
            if (snapshot == null) return;
            var timestamp = LocalTimestamp ? snapshot.DateTime.ToLocalTime() : snapshot.DateTime;
            var fileName = FileName ?? $"{(UseFriendlyName ? item.Name : item.FQID.ObjectId.ToString())}_{timestamp:yyyy-MM-dd_HH-mm-ss.fff}.jpg";
            System.IO.Path.GetInvalidFileNameChars().ToList().ForEach(c => fileName = fileName.Replace(c, '-'));
            System.IO.Path.GetInvalidPathChars().ToList().ForEach(c => Path.Replace(c, '-'));
            try
            {
                var path = System.IO.Path.Combine(Path, fileName);
                File.WriteAllBytes(path, snapshot.Bytes);
                File.SetLastWriteTimeUtc(path, snapshot.DateTime);
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.WriteError,
                        snapshot));
            }
        }
    }
}

