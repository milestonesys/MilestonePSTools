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
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Data;
using VideoOS.Platform.Live;
using VideoOS.Platform.Metadata;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{
    public class MetadataRecordCommandBase : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(Camera))]
        public Camera Camera { get; set; }

        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(Metadata))]
        public Metadata Metadata { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Id))]
        public Guid Id { get; set; }

        [Parameter()]
        public SwitchParameter Raw { get; set; }

        internal void WriteRecord(MetadataPlaybackData data)
        {
            if (Raw)
            {
                WriteObject(data);
            }
            else
            {
                WriteObject(data.Content);
            }
        }

        internal void WriteRecord(MetadataLiveContent data)
        {
            if (Raw)
            {
                WriteObject(data);
            }
            else
            {
                WriteObject(data.Content);
            }
        }

        internal Item ResolveMetadataItem()
        {
            Item metadata = null;
            switch (ParameterSetName)
            {
                case nameof(Camera):
                    var path = Camera.ClientSettingsFolder.ClientSettings.First().Related.Split(',')
                        .Select(d => new ConfigurationItemPath(d))
                        .Where(p => p.ItemType == nameof(Metadata));
                    if (!path.Any())
                    {
                        throw new InvalidOperationMIPException($"No related metadata found for camera {Camera.Name}.");
                    }
                    else if (path.Count() > 1)
                    {
                        throw new InvalidOperationMIPException($"There is more than one related metadata device for camera {Camera.Name}. Provide the metadata device or ID instead.");
                    }
                    metadata = Configuration.Instance.GetItem(new Guid(path.First().Id), Kind.Metadata);
                    if (metadata == null)
                    {
                        throw new PathNotFoundMIPException($"Related metadata not found. It may be disabled.");
                    }
                    break;

                case nameof(Metadata):
                    metadata = Configuration.Instance.GetItem(new Guid(Metadata.Id), Kind.Metadata);
                    if (metadata == null)
                    {
                        throw new PathNotFoundMIPException($"Metadata not found. It may be disabled.");
                    }
                    break;
                case nameof(Id):
                    metadata = Configuration.Instance.GetItem(Id, Kind.Metadata);
                    if (metadata == null)
                    {
                        throw new PathNotFoundMIPException($"Metadata not found. It may be disabled.");
                    }
                    break;
                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} not implemented.");
            }
            return metadata;
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsMetadataLiveRecord", DefaultParameterSetName = nameof(Metadata))]
    [OutputType(typeof(MetadataContent))]
    [RequiresVmsConnection()]
    public class GetMetadataLiveRecordCommand : MetadataRecordCommandBase
    {
        [Parameter()]
        public DateTime Until { get; set; } = DateTime.Now.AddMinutes(1);

        [Parameter()]
        [ValidateRange(1, int.MaxValue)]
        public int Count { get; set; } = 1;

        private readonly ConcurrentQueue<Exception> _errors = new ConcurrentQueue<Exception>();
        private readonly ConcurrentQueue<MetadataLiveContent> _content = new ConcurrentQueue<MetadataLiveContent>();
        protected override void ProcessRecord()
        {
            var metadata = ResolveMetadataItem();
            var source = new MetadataLiveSource(metadata);
            try
            {
                source.LiveContentEvent += LiveContentEventHandler;
                source.ErrorEvent += ErrorEventHandler;
                source.Init();
                source.LiveModeStart = true;
                var recordsReturned = 0;
                if (MyInvocation.BoundParameters.ContainsKey(nameof(Until)))
                {
                    do
                    {
                        while (DateTime.Now < Until && _errors.TryDequeue(out var ex))
                        {
                            WriteError(new ErrorRecord(ex, ex.Message, ErrorCategory.MetadataError, source));
                        }
                        while (DateTime.Now < Until && _content.TryDequeue(out var data))
                        {
                            WriteRecord(data);
                            recordsReturned++;
                            if (MyInvocation.BoundParameters.ContainsKey(nameof(Count)) && recordsReturned >= Count){
                                break;
                            }
                        }
                        if (MyInvocation.BoundParameters.ContainsKey(nameof(Count)) && recordsReturned >= Count){
                            break;
                        }
                    } while (DateTime.Now < Until);
                }
                else
                {
                    
                    while (recordsReturned < Count)
                    {
                        while (_errors.TryDequeue(out var ex))
                        {
                            WriteError(new ErrorRecord(ex, ex.Message, ErrorCategory.MetadataError, source));
                        }
                        while (_content.TryDequeue(out var data))
                        {
                            WriteRecord(data);
                            if (++recordsReturned >= Count)
                            {
                                break;
                            }
                        }
                    }
                }
            }
            finally
            {
                source.LiveContentEvent -= LiveContentEventHandler;
                source.ErrorEvent -= ErrorEventHandler;
                source.LiveModeStart = false;
                source.Close();
                source = null;
            }
        }

        private void ErrorEventHandler(MetadataLiveSource source, Exception exception)
        {
            if (exception == null) return;
            _errors.Enqueue(exception);
        }

        private void LiveContentEventHandler(MetadataLiveSource source, MetadataLiveContent arg)
        {
            if (arg == null) return;
            _content.Enqueue(arg);
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsMetadataRecord", DefaultParameterSetName = nameof(Metadata))]
    [OutputType(typeof(MetadataContent))]
    [RequiresVmsConnection()]
    public class GetMetadataRecordCommand : MetadataRecordCommandBase
    {
        [Parameter()]
        public DateTime Timestamp { get; set; } = DateTime.Now;

        [Parameter()]
        public DateTime Until { get; set; }

        [Parameter()]
        [ValidateRange(1, int.MaxValue)]
        public int Count { get; set; } = 1;

        protected override void ProcessRecord()
        {
            var metadata = ResolveMetadataItem();
            var source = new MetadataPlaybackSource(metadata);
            try
            {
                var recordsReturned = 0;
                source.Init();
                MetadataPlaybackData data = null;
                data = source.GetNearest(Timestamp.ToUniversalTime());
                if (data == null) return;

                WriteRecord(data);
                recordsReturned++;

                if (MyInvocation.BoundParameters.ContainsKey(nameof(Until)))
                {
                    Until = Until.ToUniversalTime();
                    while (data.NextDateTime != null && data.NextDateTime < Until)
                    {
                        data = source.GetNext();
                        if (data == null) break;
                        WriteRecord(data);
                    }
                }
                else
                {
                    while (data.NextDateTime != null && recordsReturned < Count)
                    {
                        data = source.GetNext();
                        if (data == null) break;
                        WriteRecord(data);
                        recordsReturned++;
                    }
                }
            }
            catch (Exception ex)
            {
                object obj = null;
                switch (ParameterSetName)
                {
                    case nameof(Camera):
                        obj = Camera;
                        break;
                    
                    case nameof(Metadata):
                        obj = Metadata;
                        break;

                    case nameof(Id):
                        obj = Id;
                        break;

                    default:
                        throw new NotImplementedException($"ParameterSetName {ParameterSetName} not implemented.");
                }
                WriteError(new ErrorRecord(ex, ex.Message, ErrorCategory.MetadataError, obj));
            }
            finally
            {
                source.Close();
            }
        }
    }
}

