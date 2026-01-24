using MilestonePSTools.Extensions;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools
{
    public class VmsCameraStreamConfig
    {
        internal enum RecordingTracks
        {
            None,
            Primary,
            Secondary
        }

        private static Dictionary<RecordingTracks, string> RecordingTrackToId = new Dictionary<RecordingTracks, string>
        {
            { RecordingTracks.None, string.Empty },
            { RecordingTracks.Primary, "16ce3aa1-5f93-458a-abe5-5c95d9ed1372" },
            { RecordingTracks.Secondary, "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0" }
        };

        private static Dictionary<string, RecordingTracks> RecordingTrackFromId = new Dictionary<string, RecordingTracks>
        {
            { string.Empty, RecordingTracks.None },
            { "16ce3aa1-5f93-458a-abe5-5c95d9ed1372", RecordingTracks.Primary },
            { "84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0", RecordingTracks.Secondary }
        };

        public static EventHandler<string> StreamModified;
        public bool Dirty { get; private set; }
        public string Name => _stream.DisplayName;
        public string DisplayName
        {
            get => _streamUsageChildItem?.Name ?? string.Empty;
            set
            {
                if (_streamUsageChildItem != null)
                {
                    _streamUsageChildItem.Name = value;
                    Dirty = true;
                }
            }
        }
        public bool Enabled
        {
            get => _streamUsageChildItem != null;
            set
            {
                if (value == Enabled) return;
                if (value)
                {
                    var result = _streamUsages.AddStream();
                    if (result.State != StateEnum.Success)
                    {
                        throw new Exception($"Error adding stream usage: {result.ErrorText}");
                    }
                }
                else
                {
                    var result = _streamUsages.RemoveStream(StreamReferenceId.ToString());
                    if (result.State != StateEnum.Success)
                    {
                        throw new Exception($"Error removing stream usage: {result.ErrorText}");
                    }
                }
                // Must update immediately as calling add/removestream clears the local streamusage records
                Update();
            }
        }

        public string LiveMode
        {
            get => _streamUsageChildItem?.LiveMode ?? string.Empty;
            set
            {
                if (_streamUsageChildItem == null) return;
                if (_streamUsageChildItem?.LiveMode == value) return;
                _streamUsageChildItem.LiveMode = value;
                Dirty = true;
            }
        }
        public bool LiveDefault
        {
            get => _streamUsageChildItem?.LiveDefault ?? false;
            set
            {
                if (_streamUsageChildItem == null) return;
                if (_streamUsageChildItem?.LiveDefault == value) return;
                _streamUsageChildItem.LiveDefault = value;
                if (value)
                {
                    _streamUsages.StreamUsageChildItems
                        .First(u => u.LiveDefault && !u.StreamReferenceId.Equals(StreamReferenceId.ToString(), StringComparison.InvariantCultureIgnoreCase))
                        .LiveDefault = false;
                }
                Dirty = true;
            }
        }

        public bool Recorded => _streamUsageChildItem?.RecordTo.Equals(_streamUsageChildItem.RecordToValues["Primary recording"]) ?? false;
        public string RecordingTrack
        {
            get => _streamUsageChildItem?.RecordTo ?? string.Empty;
            set
            {
                // Accepts None, Primary, Secondary as well as the actual IDs
                if (Enum.GetNames(typeof(RecordingTracks)).Contains(value, StringComparer.InvariantCultureIgnoreCase))
                {
                    value = RecordingTrackToId[(RecordingTracks)Enum.Parse(typeof(RecordingTracks), value, true)];
                }
                if (_streamUsageChildItem == null) return;
                if (_streamUsageChildItem?.RecordTo.Equals(value, StringComparison.InvariantCultureIgnoreCase) ?? true) return;
                
                _streamUsageChildItem.RecordTo = value;
                if (value != RecordingTrackToId[RecordingTracks.None])
                {
                    _streamUsages.StreamUsageChildItems
                        .First(u => u.RecordTo == value && !u.StreamReferenceId.Equals(StreamReferenceId.ToString(), StringComparison.InvariantCultureIgnoreCase))
                        .RecordTo = RecordingTrackToId[RecordingTracks.None];
                }
                Dirty = true;
            }
        }

        public string RecordingTrackName => RecordingTrackFromId[_streamUsageChildItem?.RecordTo ?? string.Empty].ToString();

        public bool PlaybackDefault
        {
            get => _streamUsageChildItem?.DefaultPlayback ?? false;
            set
            {
                if (_streamUsageChildItem == null) return;
                if (_streamUsageChildItem?.DefaultPlayback == value) return;
                _streamUsageChildItem.DefaultPlayback = value;
                if (value)
                {
                    FindStreamUsage(u => u.DefaultPlayback).DefaultPlayback = false;
                }
                Dirty = true;
            }
        }

        private StreamUsageChildItem FindStreamUsage(Func<StreamUsageChildItem, bool> predicate)
        {
            return _streamUsages.StreamUsageChildItems
                .Where(u => u.StreamReferenceId.ToLower() != StreamReferenceId.ToString().ToLower())
                .First(predicate);
        }

        public Hashtable Settings
        {
            get => _stream.Properties.ToHashtable(UseRawValues);
            set
            {
                var currentSettings = Settings;
                foreach (var key in value.Keys)
                {
                    if (currentSettings.ContainsKey(key)) continue;
                }
            }
        }
        public Guid StreamReferenceId => Guid.Parse(_stream.StreamReferenceId);
        public bool UseEdge
        {
            get => _streamUsageChildItem?.UseEdge ?? false;
            set
            {
                if (_streamUsageChildItem == null) return;
                if (_streamUsageChildItem?.UseEdge == value) return;
                _streamUsageChildItem.UseEdge = value;
                Dirty = true;
            }
        }
        public Hashtable ValueTypeInfo => _stream.Properties.ConvertFromValueTypeInfoCollection();
        public Camera Camera { get; }

        

        public bool UseRawValues { get; set; }

        public Dictionary<string,string> RecordToValues => _streamUsageChildItem?.RecordToValues ?? new Dictionary<string, string>();

        private StreamChildItem _stream;
        private StreamDefinition _streamUsages;
        private StreamUsageChildItem _streamUsageChildItem;

        private DeviceDriverSettings _deviceDriverSettings;


        public VmsCameraStreamConfig(StreamChildItem stream, Camera camera, bool showRawValues)
        {
            Camera = camera;
            UseRawValues = showRawValues;

            _deviceDriverSettings = camera.DeviceDriverSettingsFolder.DeviceDriverSettings.First();
            _stream = _deviceDriverSettings.StreamChildItems.First(s => s.DisplayName == stream.DisplayName);
            _streamUsages = Camera.StreamFolder.Streams.FirstOrDefault();
            _streamUsageChildItem = _streamUsages.StreamUsageChildItems
                    .Where(u => u.StreamReferenceId.Equals(u.StreamReferenceIdValues[Name]))
                    .FirstOrDefault();
            StreamModified += OnStreamModified;
        }

        private void OnStreamModified(object sender, string cameraId)
        {
            if (sender == this) return;
            if (!cameraId.Equals(Camera.Id, StringComparison.InvariantCultureIgnoreCase)) return;
            // Changes were made to another streamUsage on the same camera so this instance may be stale
            UpdateStreamUsageFields();
        }

        public bool SetValue(string name, string value)
        {
            name = _stream.Properties.GetResolvedName(name);
            value = _stream.Properties.GetResolvedValue(name, value);
            if (_stream.Properties.GetValue(name) == value) return false;

            _stream.Properties.SetValue(name, value);
            Dirty = true;
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
            _streamUsages?.Save();
            _deviceDriverSettings.Save();
            Dirty = false;
        }

        public void Update()
        {
            Camera.DeviceDriverSettingsFolder.ClearChildrenCache();
            _deviceDriverSettings = Camera.DeviceDriverSettingsFolder.DeviceDriverSettings.First();
            _stream = _deviceDriverSettings.StreamChildItems.First(s => s.DisplayName == _stream.DisplayName);
            
            Camera.StreamFolder.ClearChildrenCache();
            UpdateStreamUsageFields();
            StreamModified?.Invoke(this, Camera.Id);
        }

        private void UpdateStreamUsageFields()
        {
            _streamUsages = Camera.StreamFolder.Streams.FirstOrDefault();
            _streamUsageChildItem = _streamUsages.StreamUsageChildItems
                    .Where(u => u.StreamReferenceId.Equals(u.StreamReferenceIdValues[Name]))
                    .FirstOrDefault();
        }
    }
}
