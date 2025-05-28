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
using System.Linq;
using System.Management.Automation;
using System.Threading.Tasks;
using VideoOS.Common.Proxy.Server.WCF;
using VideoOS.Platform;
using VideoOS.Platform.Data;
using MilestonePSTools.Utility;

namespace MilestonePSTools.ExportCommands
{
    /// <summary>
    /// <para type="synopsis">Starts exporting audio/video from specified devices in the specified format.</para>
    /// <para type="description">This command performs AVI, MKV and Database exports of video and audio. It can
    /// take a list of camera, microphone, and speaker device ID's, or it can receive an Evidence Lock object as
    /// pipeline input.</para>
    /// <example>
    ///     <code>C:\PS>Start-Export -CameraIds $id -Format DB -StartTime '2019-06-04 14:00:00' -EndTime '2019-06-04 14:15:00' -Path C:\Exports -Name Sample</code>
    ///     <para>Exports 15 minutes of video from camera with ID $id in the native Milestone Database format, starting at 2:15 PM local time, and saving to a folder at C:\Exports\Sample.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Start, "Export", DefaultParameterSetName = "MKV")]
    [RequiresVmsConnection()]
    public class StartExport : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the evidence lock record to use as a source for the camera and audio device ID's, start and end timestamps, and export name.</para>
        /// <para type="description">Note 1: If -Name is not supplied, the Header value of the evidence lock will be used to specify the folder or file name where the export is stored.</para>
        /// <para type="description">Note 2: If exporting in anything but DB format, only the first device will be exported, and the order is not guaranteed. As such it is recommended only to pipe Evidence Locks into this command when you know there is only one device in the evidence lock.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI", ValueFromPipeline = true)]
        [Parameter(ParameterSetName = "DB", ValueFromPipeline = true)]
        [Parameter(ParameterSetName = "MKV", ValueFromPipeline = true)]
        public MarkedData EvidenceLock { get; set; }

        /// <summary>
        /// <para type="description">Specifies the ID of one or more cameras using the GUID-based identifier typical of objects in a Milestone configuration. Multiple IDs should be separated by a comma.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public Guid[] CameraIds { get; set; }

        /// <summary>
        /// <para type="description">Specifies the ID of one or more microphones using the GUID-based identifier typical of objects in a Milestone configuration. Multiple IDs should be separated by a comma.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public Guid[] MicrophoneIds { get; set; }

        /// <summary>
        /// <para type="description">Specifies the ID of one or more speakers using the GUID-based identifier typical of objects in a Milestone configuration. Multiple IDs should be separated by a comma.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public Guid[] SpeakerIds { get; set; }

        /// <summary>
        /// <para type="description">Specifies the start of the range of media to be exported. Time must always be interpreted internally as UTC, so if you supply an ambiguously formatted timestamp, it is likely to be interpreted as local time and will be adjusted to UTC.</para>
        /// <para type="description">Example: This timestamp will be interpreted as 5PM local time - '2019-06-07 17:00:00'</para>
        /// <para type="description">Example: This timestamp will be interpreted as 5PM local time - '2019-06-07 5:00:00 PM'</para>
        /// <para type="description">Example: This timestamp will be interpreted as 5PM UTC time - '2019-06-07 17:00:00Z'</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public DateTime StartTime { get; set; }

        /// <summary>
        /// <para type="description">Specifies the end of the range of media to be exported. Timestamps will be parsed in the same way as StartTime.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public DateTime EndTime { get; set; }

        /// <summary>
        /// <para type="description">Specifies the directory where the export will be placed. AVI and MKV's will be saved as a file in this directory while DB exports will be saved in a subfolder in this directory.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public string Path { get; set; } = ".\\";

        /// <summary>
        /// <para type="description">Specifies the name of the resulting AVI or MKV file, or the subfolder for the DB export.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public string Name { get; set; }

        /// <summary>
        /// <para type="description">Specifies the desired format for the export. AVI and MKV files can contain only one camera and only the first device supplied will be exported.</para>
        /// <para type="description">Note: MKV will almost always be a better option than AVI. MKV exports are much faster, require fewer resources to produce, and have the best quality. 
        /// AVI exports require transcoding from the original codec to a new codec. There will be loss of quality, high CPU resource utilization and the time required is substantially higher than either MKV or DB.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        [ValidateSet(validValues: new[] { "AVI", "MKV", "DB" }, IgnoreCase = true)]
        public string Format { get; set; } = "MKV";

        /// <summary>
        /// <para type="description">Encrypt the Database export</para>
        /// </summary>
        [Parameter(ParameterSetName = "DB")]
        public SwitchParameter UseEncryption { get; set; }

        /// <summary>
        /// <para type="description">Ignore communication errors with recording servers by removing any devices on unresponsive servers from the overall export and proceeding without error.</para>
        /// <para type="description">Omitting this flag will result in a complete export failure in the event one or more devices cannot be reached due to a recording server not responding.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [Parameter(ParameterSetName = "DB")]
        [Parameter(ParameterSetName = "MKV")]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// <para type="description">Specifies the password to be used for encrypting and decrypting the database export when UseEncryption is specified.</para>
        /// </summary>
        [Parameter(ParameterSetName = "DB")]
        public string Password { get; set; }

        /// <summary>
        /// <para type="description">Add a digital signature to the database export which can help verify the authenticity of an export.</para>
        /// </summary>
        [Parameter(ParameterSetName = "DB")]
        public SwitchParameter AddSignature { get; set; }

        /// <summary>
        /// <para type="description">Disallow recipients of a database export from performing a new export of their own.</para>
        /// </summary>
        [Parameter(ParameterSetName = "DB")]
        public SwitchParameter PreventReExport { get; set; }

        /// <summary>
        /// <para type="description">Specifies the codec to use to encode video in an AVI export.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        [ArgumentCompleter(typeof(AviCodecArgumentCompleter))]
        public string Codec { get; set; }

        /// <summary>
        /// <para type="description">Some exports can be very large in size. AVI exports can be split into multiple files. Default MaxAviSizeInBytes is 512MB or 536870912 bytes.</para>
        /// </summary>
        [Parameter(ParameterSetName = "AVI")]
        public int MaxAviSizeInBytes { get; set; } = 512 * 1024 * 1024;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            if (Format.Equals("AVI", StringComparison.InvariantCultureIgnoreCase) && MyInvocation.BoundParameters.ContainsKey(nameof(Codec)))
            {
                ValidateCodec(Codec);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            StartTime = StartTime.ToUniversalTime();
            EndTime = EndTime.ToUniversalTime();
            var exporter = GetExporter();
            
            var progress = new ProgressRecord(1, "Exporting", $"Creating {Format.ToUpper()} export");
            try
            {
                var startTime = EvidenceLock?.StartTime ?? StartTime;
                var endTime = EvidenceLock?.EndTime ?? EndTime;
                WriteVerbose(
                    $"Exporting data from {startTime} to {endTime}");
                var isStarted = exporter.StartExport(startTime, endTime);
                if (isStarted)
                {
                    do
                    {
                        progress.PercentComplete = exporter.Progress;
                        WriteProgress(progress);
                        Task.Delay(500).Wait();
                    } while (exporter.Progress < 100);
                    if (exporter.LastError > 0 || exporter.LastDetailedError > 0)
                        WriteError(new ErrorRecord(new Exception(exporter.LastErrorString), exporter.LastErrorString, ErrorCategory.NotSpecified, exporter));
                    if (exporter is AVIExporter aviExporter && !string.IsNullOrEmpty(Codec) && aviExporter.Codec != Codec)
                    {
                        WriteWarning($"The AviExporter MIP SDK component was unable to use the codec '{Codec}' and defaulted to '{aviExporter.Codec}' instead.");
                    }
                }
                else
                {
                    WriteError(
                        new ErrorRecord(
                            new Exception(exporter.LastErrorString),
                            exporter.LastErrorString,
                            ErrorCategory.InvalidResult,
                            exporter));
                }
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex, ex.ToString(), ErrorCategory.InvalidOperation, exporter));
            }
            finally
            {
                exporter.EndExport();
                exporter.Close();
                progress.PercentComplete = 100;
                progress.RecordType = ProgressRecordType.Completed;
                WriteProgress(progress);
            }
        }

        private IExporter GetExporter()
        {
            IExporter exporter;
            switch (Format.ToLower())
            {
                case "avi":
                    {
                        exporter = new AVIExporter
                        {
                            Filename = Name,
                            Path = Path,
                            Codec = Codec,
                            MaxAVIFileSize = MaxAviSizeInBytes
                        };
                        break;
                    }
                case "db":
                    {
                        exporter = new DBExporter(true)
                        {
                            Path = Path,
                            Encryption = UseEncryption,
                            Password = Password,
                            SignExport = AddSignature,
                            PreventReExport = PreventReExport
                        };

                        // Use evidence lock header as the folder name if no -Name is provided
                        // and if this is not an export from evidence lock, use Name in the path if it's provided
                        if (EvidenceLock != null && string.IsNullOrEmpty(Name))
                        {
                            var subFolder = EvidenceLock.Header.Trim();
                            System.IO.Path.GetInvalidPathChars().ToList().ForEach(c => subFolder = subFolder.Replace(c, '-'));
                            exporter.Path = System.IO.Path.Combine(exporter.Path, subFolder);
                        }
                        else if (!string.IsNullOrEmpty(Name))
                        {
                            exporter.Path = System.IO.Path.Combine(exporter.Path, Name);
                        }
                        break;
                    }
                case "mkv":
                    {
                        exporter = new MKVExporter
                        {
                            Filename = Name,
                            Path = Path
                        };
                        break;
                    }
                default:
                    throw new ArgumentException(nameof(Format));
            }
            exporter.Init();
            
            var cameraList = new List<Item>();
            cameraList.AddRange(
                EvidenceLock?.DeviceIds.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Camera))
                .Where(item => item != null)
                ?? CameraIds?.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Camera))
                ?? new Item[0]);
            exporter.CameraList = cameraList;

            var audioList = new List<Item>();
            audioList.AddRange(
                EvidenceLock?.DeviceIds.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Microphone))
                .Where(item => item != null)
                ?? MicrophoneIds?.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Microphone))
                ?? new Item[0]);

            audioList.AddRange(
                EvidenceLock?.DeviceIds.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Speaker))
                .Where(item => item != null)
                ?? SpeakerIds?.Select(id => Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, id, Kind.Speaker))
                ?? new Item[0]);
            exporter.AudioList = audioList;

            foreach (var item in exporter.CameraList)
            {
                WriteVerbose($"{Kind.DefaultTypeToNameTable[item.FQID.Kind]}: {item.Name}");
            }

            foreach (var item in exporter.AudioList)
            {
                WriteVerbose($"{Kind.DefaultTypeToNameTable[item.FQID.Kind]}: {item.Name}");
            }
            return exporter;
        }

        private void ValidateCodec(string codec)
        {
            AVIExporter exporter = null;
            try
            {
                exporter = new AVIExporter();
                if (!exporter.CodecList.Any(c => c.Equals(codec)))
                {
                    throw new ArgumentException("The specified codec is not available.", nameof(Codec));
                }
            }
            finally
            {
                exporter?.Close();
            }
        }
    }
}