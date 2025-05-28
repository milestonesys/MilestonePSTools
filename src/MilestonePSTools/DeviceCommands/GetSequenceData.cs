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
using VideoOS.Platform;
using VideoOS.Platform.Data;

namespace MilestonePSTools.DeviceCommands
{
    /// <summary>
    /// <para type="synopsis">Get sequence data defining the start and end time of a motion or recording sequence.</para>
    /// <para type="description">Use this command to discover all the the time ranges where recordings and/or motion are present
    /// for a device. This can be useful to generate a report showing the percentage of time a device has been recording, or to
    /// look for unusual patterns where there is a much higher or lower than usual percentage of motion/recordings.</para>
    /// <example>
    ///     <code>C:\PS>$camera | Get-SequenceData -SequenceType MotionSequence -StartTime ([DateTime]::UtcNow).AddDays(-7)</code>
    ///     <para>Gets an array of SequenceData objects representing motion sequences beginning or ending within the last 7 days. The EventSequence property of the SequenceData object contains a StartDateTime and EndDateTime property.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(SequenceData))]
    [OutputType(typeof(SequenceData))]
    [RequiresVmsConnection()]
    public class GetSequenceData : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies an object with a Path property in the format ItemType[00000000-0000-0000-0000-000000000000]. This could be a Camera object, or a generic ConfigurationItem object received from Get-ConfigurationItem.</para>
        /// <para type="description">Example: Camera[724b4f96-6e45-432f-abb2-a71fc87f1c20]</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public string Path { get; set; }

        /// <summary>
        /// <para type="description">UTC time representing the start of the sequence search period. Default is 24 hours ago.</para>
        /// </summary>
        [Parameter(Position = 2)]
        public DateTime StartTime { get; set; } = DateTime.UtcNow - TimeSpan.FromDays(1);

        /// <summary>
        /// <para type="description">UTC time representing the end of the sequence search period. Default is "now".</para>
        /// </summary>
        [Parameter(Position = 3)]
        public DateTime EndTime { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// <para type="description">Specifies whether to search for recording sequences or motion sequences.</para>
        /// </summary>
        [Parameter(Position = 4)]
        [ValidateSet(nameof(DataType.SequenceTypeGuids.MotionSequence),
            nameof(DataType.SequenceTypeGuids.RecordingSequence),
            nameof(DataType.SequenceTypeGuids.RecordingWithTriggerSequence), IgnoreCase = false)]
        public string SequenceType { get; set; } = nameof(DataType.SequenceTypeGuids.RecordingSequence);

        /// <summary>
        /// <para type="description">Crop the StartDateTime and EndDateTime to the provided StartTime and EndTime
        /// parameters. By default a sequence with an EndDateTime on or after StartTime, or a StartDateTime on or
        /// before EndTime will be returned even if most of the sequence falls outside the bounds of StartTime and
        /// EndTime. For example, if you are recording always, a RecordingSequence may be several days or weeks
        /// long, even though you may only be interested in a specific day or hour timespan. Using this switch can
        /// save you some effort when you're generating a report by adding up the duration of all sequences in a
        /// given time period.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter CropToTimeSpan { get; set; }

        /// <summary>
        /// <para type="description">Specifies the time in seconds before this command times out while searching for the camera item associated with the given Path. On a very large system (10k+ devices) this may take several seconds, though it is believed to be a quick search because the Path string defines the device by type and ID.</para>
        /// <para type="description">Default is 10 seconds.</para>
        /// </summary>
        [Parameter]
        public int TimeoutSeconds { get; set; } = 10;

        /// <summary>
        /// <para type="description">A larger page size may result in a longer wait for the first set of results, but overall shorter processing time. Default is 1000.</para>
        /// </summary>
        [Parameter]
        public int PageSize { get; set; } = 1000;

        private readonly DateTime _minimumStartTime = new DateTime(1601, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        /// <summary>
        ///
        /// </summary>
        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            StartTime = StartTime < _minimumStartTime
                ? _minimumStartTime.ToUniversalTime()
                : StartTime.ToUniversalTime();
            EndTime = EndTime.ToUniversalTime();
            
            var items = Configuration.Instance.GetItemsBySearch(Path, 1, TimeoutSeconds, out var result);
            if (result == SearchResult.Error || items == null || items.Count != 1)
            {
                WriteError(
                    new ErrorRecord(
                        new PathNotFoundMIPException("Device not found"),
                        "DeviceNotFound",
                        ErrorCategory.ObjectNotFound,
                        null));
                return;
            }
            var sds = new SequenceDataSource(items.First());
            try
            {
                sds.Init();
                var time = StartTime;
                do
                {
                    var sequences = sds.GetData(
                        time,
                        TimeSpan.Zero,
                        0,
                        EndTime - time,
                        PageSize,
                        _sequenceTypeMap[SequenceType]).Cast<SequenceData>();
                    var sequenceCount = 0;
                    SequenceData lastSequence = null;
                    foreach (var sequenceData in sequences)
                    {
                        if (CropToTimeSpan)
                        {
                            sequenceData.EventSequence.StartDateTime =
                                sequenceData.EventSequence.StartDateTime < StartTime
                                    ? StartTime
                                    : sequenceData.EventSequence.StartDateTime;
                            sequenceData.EventSequence.EndDateTime =
                                sequenceData.EventSequence.EndDateTime > EndTime
                                    ? EndTime
                                    : sequenceData.EventSequence.EndDateTime;
                        }
                        sequenceCount++;
                        lastSequence = sequenceData;
                        WriteObject(sequenceData);
                    }

                    if (sequenceCount < PageSize)
                    {
                        break;
                    }

                    time = lastSequence?.EventSequence.EndDateTime.AddTicks(1) ?? EndTime;
                } while (time <= EndTime);
            }
            finally
            {
                sds.Close();
            }
        }

        private readonly Dictionary<string, Guid> _sequenceTypeMap = new Dictionary<string, Guid>
        {
            {nameof(DataType.SequenceTypeGuids.MotionSequence), DataType.SequenceTypeGuids.MotionSequence},
            {nameof(DataType.SequenceTypeGuids.RecordingSequence), DataType.SequenceTypeGuids.RecordingSequence},
            {nameof(DataType.SequenceTypeGuids.RecordingWithTriggerSequence), DataType.SequenceTypeGuids.RecordingWithTriggerSequence},
        };
    }
}

