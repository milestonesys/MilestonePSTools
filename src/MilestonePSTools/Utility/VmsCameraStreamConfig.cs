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

using MilestonePSTools.Extensions;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools
{
    public class VmsCameraStreamConfig
    {
        public enum StreamUpdateType
        {
            Full,
            StreamSettings,
            StreamUsage
        }

        internal enum RecordingTracks
        {
            None,
            Primary,
            Secondary
        }

        private static readonly Dictionary<RecordingTracks, string> RecordingTrackToId = new Dictionary<RecordingTracks, string>
        {
            { RecordingTracks.None, string.Empty },
            { RecordingTracks.Primary, "16ce3aa1-5f93-458a-abe5-5c95d9ed1372" },
            { RecordingTracks.Secondary, "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0" }
        };

        private static readonly Dictionary<string, RecordingTracks> RecordingTrackFromId = new Dictionary<string, RecordingTracks>
        {
            { string.Empty, RecordingTracks.None },
            { "16ce3aa1-5f93-458a-abe5-5c95d9ed1372", RecordingTracks.Primary },
            { "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0", RecordingTracks.Secondary }
        };

        private static readonly Dictionary<string, StreamDefinition> _streamDefinitions = new Dictionary<string, StreamDefinition>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, bool> _dirtyStreamDefinition = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, DeviceDriverSettings> _driverSettings = new Dictionary<string, DeviceDriverSettings>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, bool> _dirtyDriverSettings = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);

        public static EventHandler<Tuple<string, StreamUpdateType>> StreamModified;
        public bool Dirty => _dirtyDriverSettings[Camera.Id] || _dirtyStreamDefinition[Camera.Id];
        public string Name { get; }
        public string DisplayName
        {
            get => GetStreamUsage()?.Name ?? string.Empty;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage?.Name == value) return;
                streamUsage.Name = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }
        public bool Enabled
        {
            get => GetStreamUsage() != null;
            set
            {
                // Adding/removing stream usages clears the StreamUsageChildItems collection
                // but we handle that in GetStreamDefinition() by calling ClearChildrenCache()
                // which causes the collection to be reloaded next time it is accessed.
                if (value == Enabled) return;
                if (value)
                {
                    var result = GetStreamDefinition().AddStream();
                    if (result.State != StateEnum.Success)
                    {
                        throw new Exception($"Error adding stream usage: {result.ErrorText}");
                    }
                }
                else
                {
                    var result = GetStreamDefinition().RemoveStream(StreamReferenceId.ToString());
                    if (result.State != StateEnum.Success)
                    {
                        throw new Exception($"Error removing stream usage: {result.ErrorText}");
                    }
                }
            }
        }

        public string LiveMode
        {
            get => GetStreamUsage()?.LiveMode ?? string.Empty;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage?.LiveMode == value) return;
                streamUsage.LiveMode = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }
        public bool LiveDefault
        {
            get => GetStreamUsage()?.LiveDefault ?? false;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage?.LiveDefault == value) return;
                if (value)
                {
                    FindStreamUsage(u => u.LiveDefault).LiveDefault = false;
                }
                streamUsage.LiveDefault = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }

        public bool Recorded
        {
            get => GetStreamUsage()?.RecordTo.Equals(GetStreamUsage().RecordToValues["Primary recording"]) ?? false;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage == null) return;
                RecordingTrack = RecordingTrackToId[RecordingTracks.Primary];
                PlaybackDefault = true;
            }
        }

        public string RecordingTrack
        {
            get => GetStreamUsage()?.RecordTo ?? string.Empty;
            set
            {
                // Accepts None, Primary, Secondary as well as the actual IDs
                if (Enum.GetNames(typeof(RecordingTracks)).Contains(value, StringComparer.OrdinalIgnoreCase))
                {
                    value = RecordingTrackToId[(RecordingTracks)Enum.Parse(typeof(RecordingTracks), value, true)];
                }
                var streamUsage = GetStreamUsage();
                if (streamUsage?.RecordTo.Equals(value, StringComparison.OrdinalIgnoreCase) ?? true) return;

                // If another stream usage is designated the same recording track, set it to None
                var otherUsage = FindStreamUsage(u => u.RecordTo == value);
                if (otherUsage != null)
                {
                    otherUsage.RecordTo = RecordingTrackToId[RecordingTracks.None];
                    // The other stream usage can't be the playback default if recording track is set to None
                    otherUsage.DefaultPlayback = false;
                }
                if (FindStreamUsage(u => u.DefaultPlayback) == null)
                {
                    streamUsage.DefaultPlayback = true;
                }
                streamUsage.RecordTo = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }

        public string RecordingTrackName => RecordingTrackFromId[GetStreamUsage()?.RecordTo ?? string.Empty].ToString();

        public bool PlaybackDefault
        {
            get => GetStreamUsage()?.DefaultPlayback ?? false;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage == null) return;
                if (streamUsage?.DefaultPlayback == value) return;
                streamUsage.DefaultPlayback = value;
                if (value)
                {
                    FindStreamUsage(u => u.DefaultPlayback).DefaultPlayback = false;
                }
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }

        private StreamUsageChildItem FindStreamUsage(Func<StreamUsageChildItem, bool> predicate)
        {
            return GetStreamDefinition().StreamUsageChildItems
                .Where(u => u.StreamReferenceId.ToLower() != StreamReferenceId.ToString().ToLower())
                .FirstOrDefault(predicate);
        }

        public Hashtable Settings => GetStream().Properties.ToHashtable(UseRawValues);
        
        public Guid StreamReferenceId => Guid.Parse(GetStream().StreamReferenceId);
        public bool UseEdge
        {
            get => GetStreamUsage()?.UseEdge ?? false;
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage == null || streamUsage.UseEdge == value) return;
                streamUsage.UseEdge = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }
        public Hashtable ValueTypeInfo => GetStream().Properties.ConvertFromValueTypeInfoCollection();
        public Camera Camera { get; }

        

        public bool UseRawValues { get; set; }

        public Dictionary<string,string> RecordToValues => GetStreamUsage()?.RecordToValues ?? new Dictionary<string, string>();

        private readonly Guid _instanceId = Guid.NewGuid();
        public VmsCameraStreamConfig(StreamChildItem stream, Camera camera, bool showRawValues)
        {
            Name = stream.DisplayName;
            Camera = camera;
            UseRawValues = showRawValues;
            GetStreamDefinition();
            GetDeviceDriverSettings();
        }

        private StreamDefinition GetStreamDefinition()
        {
            if (!_streamDefinitions.ContainsKey(Camera.Id))
            {
                _streamDefinitions.Add(Camera.Id, Camera.StreamFolder.Streams.First());
                _dirtyStreamDefinition[Camera.Id] = false;
            }
            if (_streamDefinitions[Camera.Id].StreamUsageChildItems.Count == 0)
            {
                Camera.StreamFolder.ClearChildrenCache();
                _streamDefinitions[Camera.Id] = Camera.StreamFolder.Streams.First();
            }
            return _streamDefinitions[Camera.Id];
        }

        private StreamUsageChildItem GetStreamUsage()
        {
            return GetStreamDefinition().StreamUsageChildItems
                    .Where(u => u.StreamReferenceId.Equals(u.StreamReferenceIdValues[Name]))
                    .FirstOrDefault();
        }

        private DeviceDriverSettings GetDeviceDriverSettings()
        {
            if (!_driverSettings.ContainsKey(Camera.Id))
            {
                _driverSettings.Add(Camera.Id, Camera.DeviceDriverSettingsFolder.DeviceDriverSettings.First());
                _dirtyDriverSettings[Camera.Id] = false;
            }
            return _driverSettings[Camera.Id];
        }

        private StreamChildItem GetStream()
        {
            return GetDeviceDriverSettings().StreamChildItems
                .Where(s => s.DisplayName.Equals(Name, StringComparison.OrdinalIgnoreCase))
                .FirstOrDefault();
        }
        

        public bool SetValue(string name, string value)
        {
            var stream = GetStream();
            name = stream.Properties.GetResolvedName(name);
            value = stream.Properties.GetResolvedValue(name, value);
            if (stream.Properties.GetValue(name) == value) return false;

            stream.Properties.SetValue(name, value);
            _dirtyDriverSettings[Camera.Id] = true;
            return true;
        }

        public string GetRecordingTrackName()
        {
            if (RecordToValues.Count > 0)
            {
                return RecordToValues.Where(r => r.Value == RecordingTrack)
                    .Select(r => r.Key).FirstOrDefault();
            }
            else if (Recorded)
            {
                return "Primary recording";
            }
            return "No recording";
        }

        public void Save()
        {
            if (!Dirty) return;
            if (_dirtyDriverSettings[Camera.Id])
            {
                GetDeviceDriverSettings()?.Save();
                _dirtyDriverSettings[Camera.Id] = false;
            }
            if (_dirtyStreamDefinition[Camera.Id])
            {
                GetStreamDefinition()?.Save();
                _dirtyStreamDefinition[Camera.Id] = false;
            }
        }

        public void Update()
        {
            _streamDefinitions.Remove(Camera.Id);
            _driverSettings.Remove(Camera.Id);
            _dirtyStreamDefinition[Camera.Id] = false;
            _dirtyDriverSettings[Camera.Id] = false;
            Camera.DeviceDriverSettingsFolder.ClearChildrenCache();
            Camera.StreamFolder.ClearChildrenCache();
        }

        public static IEnumerable<VmsCameraStreamConfig> GetStreams(Camera camera, bool showRawValues)
        {
            var deviceDriverSettings = camera.DeviceDriverSettingsFolder.DeviceDriverSettings.First();
            foreach (var stream in deviceDriverSettings.StreamChildItems)
            {
                yield return new VmsCameraStreamConfig(stream, camera, showRawValues);
            }
        }

        internal static void Reset()
        {
            _streamDefinitions.Clear();
            _driverSettings.Clear();
            _dirtyStreamDefinition.Clear();
            _dirtyDriverSettings.Clear();
        }
    }
}
