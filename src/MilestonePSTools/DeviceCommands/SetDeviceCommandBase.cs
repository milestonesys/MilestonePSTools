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
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{
    public enum MeasurementSystem
    {
        Metric,
        Imperial
    }

    public class SetDeviceCommandBase : ConfigApiCmdlet
    {
        internal Type RequiredType;

        [Parameter(Mandatory = true, ValueFromPipeline = true, Position = 0)]
        [ValidateNotNull()]
        [Alias("Camera", "Microphone", "Speaker", "Metadata", "InputEvent", "Output")]
        public IConfigurationItem[] InputObject { get; set; }

        [Parameter(Position = 1)]
        public string Name { get; set; }

        [Parameter(Position = 2)]
        public string ShortName { get; set; }

        [Parameter(Position = 3)]
        public string Description { get; set; }

        [Parameter(Position = 4)]
        public bool Enabled { get; set; }

        [Parameter(Position = 5)]
        public string GisPoint { get; set; }

        [Parameter(Position = 6)]
        [ValidateCoordinates()]
        [AllowNull()]
        [AllowEmptyString()]
        public string Coordinates { get; set; }

        [Parameter(Position = 7)]
        public double CoverageDirection { get; set; }

        [Parameter(Position = 8)]
        [ValidateRange(0, 360)]
        public double Direction { get; set; }

        [Parameter(Position = 9)]
        public double CoverageFieldOfView { get; set; }

        [Parameter(Position = 10)]
        [ValidateRange(0, 360)]
        public double FieldOfView { get; set; }

        [Parameter(Position = 11)]
        public double CoverageDepth { get; set; }

        [Parameter(Position = 12)]
        [ValidateRange(0, double.MaxValue)]
        public double Depth { get; set; }

        [Parameter(Position = 13)]        
        public MeasurementSystem Units { get; set; }

        [Parameter(Position = 14)]
        public SwitchParameter PassThru { get; set; }

        private static readonly string[] commonSettings = new[] { "Name", "ShortName", "Description", "Enabled", "GisPoint", "CoverageDirection", "CoverageFieldOfView", "CoverageDepth" };
        private static readonly string[] recordingSettings = new[] { "PrebufferSeconds", "PrebufferInMemory", "PrebufferEnabled", "EdgeStorageEnabled", "ManualRecordingTimeoutMinutes", "RecordingEnabled", "EdgeStoragePlaybackEnabled", "ManualRecordingTimeoutEnabled" };
        private static readonly string[] cameraSettings = new[] { "RecordKeyframesOnly", "RecordOnRelatedDevices", "RecordingFramerate" };
        private static readonly Regex recordingItemType = new Regex(@"Camera|Microphone|Speaker|Metadata");

        private const double METERS_IN_FOOT = 0.30480000000122;
        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            if (MyInvocation.BoundParameters.ContainsKey(nameof(Coordinates)))
            {
                GisPoint = Coordinates.ToGisPoint();
                MyInvocation.BoundParameters[nameof(GisPoint)] = GisPoint;
            }

            if (MyInvocation.BoundParameters.ContainsKey(nameof(Direction)))
            {
                CoverageDirection = Direction / 360;
                MyInvocation.BoundParameters[nameof(CoverageDirection)] = CoverageDirection;
            }

            if (MyInvocation.BoundParameters.ContainsKey(nameof(FieldOfView)))
            {
                CoverageFieldOfView = FieldOfView / 360;
                MyInvocation.BoundParameters[nameof(CoverageFieldOfView)] = CoverageFieldOfView;
            }

            if (MyInvocation.BoundParameters.ContainsKey(nameof(Depth)))
            {
                var conversionFactor = RegionInfo.CurrentRegion.IsMetric ? 1 : METERS_IN_FOOT;
                if (MyInvocation.BoundParameters.ContainsKey(nameof(Units)))
                {
                    conversionFactor = Units == MeasurementSystem.Metric ? 1 : METERS_IN_FOOT;
                }
                CoverageDepth = Depth * conversionFactor;
                MyInvocation.BoundParameters[nameof(CoverageDepth)] = CoverageDepth;
            }

            RequiredType = (GetType().GetCustomAttribute(typeof(OutputTypeAttribute)) as OutputTypeAttribute).Type.First().Type;
        }

        private bool _dirty = false;
        protected override void ProcessRecord()
        {
            foreach (var device in InputObject)
            {
                try
                {
                    if (!RequiredType.IsAssignableFrom(device.GetType()))
                    {
                        throw new ArgumentException($"Device type {device.GetType().Name} not allowed. The {MyInvocation.InvocationName} command expects devices of type {RequiredType.Name}");
                    }
                    var originalName = device.Name;
                    UpdateSettings(device, commonSettings);

                    var path = new ConfigurationItemPath(device.Path);
                    if (recordingItemType.IsMatch(path.ItemType))
                    {
                        UpdateSettings(device, recordingSettings);
                    }
                    if (path.ItemType.Equals("Camera"))
                    {
                        UpdateSettings(device, cameraSettings);
                    }

                    if (ShouldProcess(originalName, "Save changes"))
                    {
                        if (_dirty)
                        {
                            device.Save();
                        }
                        
                        if (PassThru)
                        {
                            WriteObject(device);
                        }
                    }
                }
                catch (Exception ex)
                {
                    EnvironmentManager.Instance.Log(true, MethodBase.GetCurrentMethod().Name, ex.ToString());
                    WriteError(
                        new ErrorRecord(ex, ex.Message, ErrorCategory.InvalidOperation, device));
                }
            }
        }

        internal void UpdateSettings(IConfigurationItem device, IEnumerable<string> settings)
        {
            var properties = device.GetType().GetProperties();
            foreach (var propertyName in settings)
            {
                if (!MyInvocation.BoundParameters.ContainsKey(propertyName))
                {
                    continue;
                }
                var currentProperty = properties.Where(p => p.Name == propertyName).First();
                var currentValue = currentProperty.GetValue(device);
                var newValue = MyInvocation.BoundParameters[propertyName];
                if (currentValue.ToString() != newValue.ToString())
                {
                    if (ShouldProcess(device.Name, $"Set {propertyName} = {newValue}"))
                    {
                        currentProperty.SetValue(device, newValue);
                        _dirty = true;
                    }
                }
            }
        }
    }

    public class SetRecordingDeviceCommand : SetDeviceCommandBase
    {
        [Parameter(Position = 15)]
        public bool RecordingEnabled { get; set; }

        [Parameter(Position = 16)]
        public bool ManualRecordingTimeoutEnabled { get; set; }

        [Parameter(Position = 17)]
        public int ManualRecordingTimeoutMinutes { get; set; }

        [Parameter(Position = 18)]
        public bool PrebufferEnabled { get; set; }
        
        [Parameter(Position = 19)]
        public int PrebufferSeconds { get; set; }

        [Parameter(Position = 20)]
        public bool PrebufferInMemory { get; set; }

        [Parameter(Position = 21)]
        public bool EdgeStorageEnabled { get; set; }

        [Parameter(Position = 22)]
        public bool EdgeStoragePlaybackEnabled { get; set; }        
    }

    [Cmdlet(VerbsCommon.Set, "VmsCamera", SupportsShouldProcess = true)]
    [OutputType(typeof(Camera))]
    [RequiresVmsConnection()]
    public class SetCameraDeviceCommand : SetRecordingDeviceCommand
    {
        [Parameter(Position = 23)]
        public bool RecordKeyframesOnly { get; set; }

        [Parameter(Position = 24)]
        public double RecordingFramerate { get; set; }

        [Parameter(Position = 25)]
        public bool RecordOnRelatedDevices { get; set; }
    }

    [Cmdlet(VerbsCommon.Set, "VmsMicrophone", SupportsShouldProcess = true)]
    [OutputType(typeof(Microphone))]
    [RequiresVmsConnection()]
    public class SetMicrophoneDeviceCommand : SetRecordingDeviceCommand
    {
    }

    [Cmdlet(VerbsCommon.Set, "VmsSpeaker", SupportsShouldProcess = true)]
    [OutputType(typeof(Speaker))]
    [RequiresVmsConnection()]
    public class SetSpeakerDeviceCommand : SetRecordingDeviceCommand
    {
    }

    [Cmdlet(VerbsCommon.Set, "VmsMetadata", SupportsShouldProcess = true)]
    [OutputType(typeof(Metadata))]
    [RequiresVmsConnection()]
    public class SetMetadataDeviceCommand : SetRecordingDeviceCommand
    {
    }

    [Cmdlet(VerbsCommon.Set, "VmsInput", SupportsShouldProcess = true)]
    [OutputType(typeof(InputEvent))]
    [RequiresVmsConnection()]
    public class SetInputDeviceCommand : SetDeviceCommandBase
    {
    }

    [Cmdlet(VerbsCommon.Set, "VmsOutput", SupportsShouldProcess = true)]
    [OutputType(typeof(Output))]
    [RequiresVmsConnection()]
    public class SetOutputDeviceCommand : SetDeviceCommandBase
    {
    }

    [Cmdlet(VerbsCommon.Set, "VmsDevice", SupportsShouldProcess = true)]
    [OutputType(typeof(IConfigurationItem))]
    [RequiresVmsConnection()]
    public class SetAnyDeviceCommand : SetDeviceCommandBase
    {
    }
}

