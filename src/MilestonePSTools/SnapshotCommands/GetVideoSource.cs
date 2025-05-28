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
    /// <summary>
    /// <para type="synopsis">Gets a MIP SDK VideoSource object for a given camera which can be used to navigate the media database to retrieve images</para>
    /// <para type="description">WARNING: This is experimental and has a significant memory leak until a strategy for disposing of unused resources in a powershell environment can be determined.</para>
    /// <para type="description">Gets one of a BitmapVideoSource, JPEGVideoSource or RawVideoSource object depending on the provided Format value. The
    /// default is Raw since that puts no video decoding burden on the Recording Server.</para>
    /// <para type="description">See the MIP SDK documentation link in the related links of this help info for details on how to navigate recordings
    /// with these VideoSource objects. The objects include methods like GetBegin(), GetEnd(), GetNearest(datetime), GetNext() and GetPrevious(), and
    /// the results provide information about the timestamp, whether a next or previous image is available and what the timestamp of that image is, in
    /// addition to the image data itself.</para>
    /// <example>
    ///     <code>C:\PS> $src = $camera | Get-VideoSource -Format Jpeg; $first = $src.GetBegin(); $second = $src.GetNext()</code>
    ///     <para>Gets the first and second images in the media database for the camera referenced in the variable $camera.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html">MIP SDK Documentation</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(VideoSource))]
    [OutputType(typeof(VideoSource))]
    [RequiresVmsConnection()]
    public class GetVideoSource : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies a camera by FQID. Useful when all you have is the FQID such as when you're using
        /// a Get-ItemState result, or the output of some event header data.</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public FQID Fqid { get; set; }

        /// <summary>
        /// <para type="description">Specifies a camera object - typically the output of a Get-VmsCamera command.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true)]
        public Camera Camera { get; set; }

        /// <summary>
        /// <para type="description">Specifies the Guid value of a Camera object.</para>
        /// </summary>
        [Parameter(Position = 1)]
        public Guid CameraId { get; set; }

        /// <summary>
        /// <para type="description">Specifies the format in which data should be returned</para>
        /// </summary>
        [Parameter(Position = 2)]
        [ValidateSet("Bitmap", "Jpeg", "Raw", IgnoreCase = false)]
        public string Format { get; set; } = "Raw";

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            ValidateParameters();
            VideoSource src = null;
            try
            {
                if (Fqid != null) CameraId = Fqid.ObjectId;
                var cameraId = Camera != null ? new Guid(Camera.Id) : CameraId;
                var item = Configuration.Instance.GetItem(Connection.CurrentSite.FQID.ServerId, cameraId, Kind.Camera);
                if (item == null)
                {
                    WriteWarning(
                        $"Configuration not available for camera with ID {cameraId}. It might be disabled.");
                    return;
                }

                src = GetSpecifiedVideoSource(item, Format);
                src.Init();
                WriteObject(src);
            }
            catch (CommunicationMIPException)
            {
                WriteWarning($"Unable to connect to {src?.Item.Name} ({src?.Item.FQID.ObjectId})");
            }
            catch (Exception ex)
            {
                WriteError(
                    new ErrorRecord(
                        ex,
                        ex.Message,
                        ErrorCategory.ReadError,
                        src));
            }
        }

        private VideoSource GetSpecifiedVideoSource(Item item, string format)
        {
            switch (format)
            {
                case "Bitmap":
                    return new BitmapVideoSource(item);

                case "Jpeg":
                    return new JPEGVideoSource(item);

                case "Raw":
                    return new RawVideoSource(item);

                default:
                    return new RawVideoSource(item);
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

