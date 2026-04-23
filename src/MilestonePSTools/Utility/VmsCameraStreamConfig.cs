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

using MilestonePSTools.Connection;
using MilestonePSTools.Extensions;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Windows.Forms;
using VideoOS.Platform.ConfigurationItems;

#pragma warning disable CS0618 // Type or member is obsolete
// Record property is only obsolete on 2023 R2 and newer. Still used on older versions.
namespace MilestonePSTools
{
    public class VmsCameraStreamConfig
    {
        #region Static Members
        private static readonly Dictionary<string, bool> _dirtyStreamDefinition = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, bool> _dirtyDriverSettings = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, StreamDefinition> _streamDefinitions = new Dictionary<string, StreamDefinition>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, DeviceDriverSettings> _driverSettings = new Dictionary<string, DeviceDriverSettings>(StringComparer.OrdinalIgnoreCase);
        private static readonly Dictionary<string, RecordingTracks> RecordingTrackFromId = new Dictionary<string, RecordingTracks>
        {
            { string.Empty, RecordingTracks.None },
            { "16ce3aa1-5f93-458a-abe5-5c95d9ed1372", RecordingTracks.Primary },
            { "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0", RecordingTracks.Secondary }
        };
        private static readonly Dictionary<RecordingTracks, string> RecordingTrackToId = new Dictionary<RecordingTracks, string>
        {
            { RecordingTracks.None, string.Empty },
            { RecordingTracks.Primary, "16ce3aa1-5f93-458a-abe5-5c95d9ed1372" },
            { RecordingTracks.Secondary, "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0" }
        };

        internal static void Reset()
        {
            _streamDefinitions.Clear();
            _driverSettings.Clear();
            _dirtyStreamDefinition.Clear();
            _dirtyDriverSettings.Clear();
        }
        #endregion

        #region Properties
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

        public string RecordingTrackName
        {
            get
            {
                if (SupportsSecondaryRecording())
                {
                    return RecordingTrackFromId[GetStreamUsage()?.RecordTo ?? string.Empty].ToString();
                }
                else
                {
                    return RecordingTrackFromId[
                        GetStreamUsage()?.Record ?? false
                        ? RecordingTrackToId[RecordingTracks.Primary]
                        : RecordingTrackToId[RecordingTracks.None
                        ]].ToString();
                }
            }
        }

        public bool PlaybackDefault
        {
            get
            {
                var usage = GetStreamUsage();
                if (usage == null) return true; // If there is no stream usage, default to true because super old drivers might not have stream usages but still record.
                if (SupportsSecondaryRecording())
                {
                    return usage.DefaultPlayback;
                }
                else
                {
                    return usage.Record;
                }
            }
            set
            {
                var streamUsage = GetStreamUsage();
                // There are no stream usages to configure
                if (streamUsage == null) return; 
                // The value is already set to the provided value
                if (streamUsage.DefaultPlayback == value) return;
                // The RecordTo property is not set, so this is probably a version without Primary/Secondary tracks
                if (string.IsNullOrEmpty(streamUsage.RecordTo)) return;
                streamUsage.DefaultPlayback = value;
                if (value)
                {
                    FindStreamUsage(u => u.DefaultPlayback).DefaultPlayback = false;
                }
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }
        
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

        public bool Dirty => _dirtyDriverSettings[Camera.Id] || _dirtyStreamDefinition[Camera.Id];

        public Hashtable Settings => GetStream().Properties.ToHashtable(UseRawValues);

        public Hashtable ValueTypeInfo => GetStream().Properties.ConvertFromValueTypeInfoCollection();

        [Hidden()]
        public bool Recorded
        {
            get
            {
                return SupportsSecondaryRecording()
                    ? GetStreamUsage()?.RecordTo.Equals(GetStreamUsage().RecordToValues["Primary recording"]) ?? false
                    : GetStreamUsage()?.Record ?? false;
            }
            set
            {
                var streamUsage = GetStreamUsage();
                if (streamUsage == null) return;
                if (SupportsSecondaryRecording())
                {
                    if (value == streamUsage.RecordTo.Equals(RecordingTrackToId[RecordingTracks.Primary]))
                    {
                        return;
                    }
                    RecordingTrack = RecordingTrackToId[RecordingTracks.Primary];
                }
                else
                {
                    if (value == streamUsage.Record) return;
                    var otherUsage = FindStreamUsage(u => u.Record);
                    if (value && otherUsage != null)
                    {
                        otherUsage.Record = false;
                    }
                    streamUsage.Record = value;
                }
                PlaybackDefault = value;
                _dirtyStreamDefinition[Camera.Id] = true;
            }
        }

        [Hidden()]
        public string RecordingTrack
        {
            get
            {
                if (SupportsSecondaryRecording())
                {
                    return GetStreamUsage()?.RecordTo ?? string.Empty;
                }
                else
                {
                    return GetStreamUsage()?.Record == true
                        ? RecordingTrackToId[RecordingTracks.Primary]
                        : string.Empty;
                }
            }
            set
            {
                // Accepts None, Primary, Secondary as well as the actual IDs
                if (Enum.GetNames(typeof(RecordingTracks)).Contains(value, StringComparer.OrdinalIgnoreCase))
                {
                    value = RecordingTrackToId[(RecordingTracks)Enum.Parse(typeof(RecordingTracks), value, true)];
                }
                if (SupportsSecondaryRecording())
                {
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
                else if (value.Equals(RecordingTrackToId[RecordingTracks.Secondary], StringComparison.OrdinalIgnoreCase))
                {
                    throw new NotSupportedException("Secondary recording is not supported. This may be because the XProtect VMS version is older than 2023 R2.");
                }
                else
                {
                    Recorded = value.Equals(RecordingTrackToId[RecordingTracks.Primary], StringComparison.OrdinalIgnoreCase);
                }
            }
        }

        [Hidden()]
        public Guid StreamReferenceId => Guid.Parse(GetStream().StreamReferenceId);

        [Hidden()]
        public Camera Camera { get; }

        [Hidden()]
        public bool UseRawValues { get; set; }

        [Hidden()]
        public Dictionary<string, string> RecordToValues => GetStreamUsage()?.RecordToValues ?? new Dictionary<string, string>();
        #endregion

        #region Constructors
        public VmsCameraStreamConfig(StreamChildItem stream, Camera camera, bool showRawValues)
        {
            Name = stream.DisplayName;
            Camera = camera;
            UseRawValues = showRawValues;
            GetStreamDefinition();
            GetDeviceDriverSettings();
        }

        public static IEnumerable<VmsCameraStreamConfig> GetStreams(Camera camera, bool showRawValues)
        {
            var deviceDriverSettings = camera.DeviceDriverSettingsFolder.DeviceDriverSettings.First();
            foreach (var stream in deviceDriverSettings.StreamChildItems)
            {
                yield return new VmsCameraStreamConfig(stream, camera, showRawValues);
            }
        }
        #endregion

        #region Public Methods
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
            if (SupportsSecondaryRecording())
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
        #endregion

        #region Private Methods
        private bool SupportsSecondaryRecording()
        {
            return MilestoneConnection.Instance.SystemLicense.IsFeatureEnabled("MultistreamRecording");
        }

        private StreamUsageChildItem FindStreamUsage(Func<StreamUsageChildItem, bool> predicate)
        {
            return GetStreamDefinition().StreamUsageChildItems
                .Where(u => u.StreamReferenceId.ToLower() != StreamReferenceId.ToString().ToLower())
                .FirstOrDefault(predicate);
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
        #endregion

        internal enum RecordingTracks
        {
            None,
            Primary,
            Secondary
        }
    }
}
#pragma warning restore CS0618 // Type or member is obsolete
