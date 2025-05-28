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
using System.Reflection;
using VideoOS.ConfigurationApi.ClientService;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{
    public class GetDeviceCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(Hardware), Position = 0)]
        public Hardware[] Hardware { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Id), Position = 0)]
        public Guid[] Id { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Path), Position = 0)]
        public string[] Path { get; set; }

        [Parameter(ParameterSetName = nameof(QueryItems), Position = 0)]
        [Parameter(ParameterSetName = nameof(Hardware), Position = 1)]
        public string Name { get; set; } = string.Empty;

        [Parameter(ParameterSetName = nameof(QueryItems), Position = 1)]
        [Parameter(ParameterSetName = nameof(Hardware), Position = 2)]
        public string Description { get; set; } = string.Empty;

        [Parameter(ParameterSetName = nameof(QueryItems), Position = 2)]
        [Parameter(ParameterSetName = nameof(Hardware), Position = 3)]
        public int[] Channel { get; set; }

        [Parameter(ParameterSetName = nameof(QueryItems), Position = 3)]
        [Parameter(ParameterSetName = nameof(Hardware), Position = 4)]
        public EnableFilter EnableFilter { get; set; } = EnableFilter.Enabled;
        
        [Parameter(ParameterSetName = nameof(QueryItems), Position = 4)]
        [Parameter(ParameterSetName = nameof(Hardware), Position = 5)]
        public Operator Comparison { get; set; } = Operator.Contains;

        [Parameter(ParameterSetName = nameof(QueryItems), Position = 5)]
        public int MaxResults { get; set; } = int.MaxValue;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            if (!MyInvocation.InvocationName.StartsWith("Get-Vms", StringComparison.CurrentCultureIgnoreCase))
            {
                WriteWarning($"The default behavior of {MyInvocation.MyCommand.Name} is to return only enabled devices, but while using the alias '{MyInvocation.InvocationName}', the behavior matches the previous version of the command by returning disabled devices too.");
                EnableFilter = EnableFilter.All;
            }
        }

        internal IEnumerable<T> FindDevices<T>() where T : IConfigurationItem
        {
            var parameterSet = ParameterSetName;
            if (Id?.Length > 0)
            {
                parameterSet = nameof(Id);
            }
            switch (parameterSet)
            {
                case nameof(Hardware):
                    var allowedEnabledStates = new List<bool>();
                    switch (EnableFilter)
                    {
                        case EnableFilter.All:
                            allowedEnabledStates.Add(true);
                            allowedEnabledStates.Add(false);
                            break;
                        case EnableFilter.Enabled:
                            allowedEnabledStates.Add(true);
                            break;
                        case EnableFilter.Disabled:
                            allowedEnabledStates.Add(false);
                            break;
                        default:
                            break;
                    }
                    
                    Name = AddWildcards(Name, Comparison);
                    Description = AddWildcards(Description, Comparison);
                    var nameFilter = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
                    var descriptionFilter = new WildcardPattern(Description, WildcardOptions.IgnoreCase);
                    var folderProperty = typeof(Hardware).GetProperties().First(prop => prop.Name.Equals($"{typeof(T).Name}Folder"));
                    foreach (var hw in Hardware)
                    {
                        if (!hw.Enabled && EnableFilter == EnableFilter.Enabled) continue;
                        var folder = (IConfigurationItem)folderProperty.GetValue(hw);
                        var devicesProperty = folder.GetType().GetProperties().First(prop => prop.Name.Equals($"{typeof(T).Name}s"));
                        foreach (T device in ((List<T>)devicesProperty.GetValue(folder)).OrderBy(d => int.Parse(d.GetProperty(nameof(Channel)))))
                        {
                            if (!allowedEnabledStates.Any(state => state == ((dynamic)device).Enabled)) continue;
                            if (MyInvocation.BoundParameters.ContainsKey(nameof(Channel)) && !Channel.Any(ch => ch == ((dynamic)device).Channel)) continue;
                            if (!nameFilter.IsMatch(device.Name)) continue;
                            if (!descriptionFilter.IsMatch(device.Description)) continue;

                            yield return device;
                        }
                    }
                    break;

                case nameof(Id):
                    foreach (var deviceId in Id)
                    {
                        yield return (T)Activator.CreateInstance(typeof(T), Connection.ManagementServer.ServerId, $"{typeof(T).Name}[{deviceId}]");
                    }
                    break;

                case nameof(Path):
                    foreach (var pathInfo in Path.Select(p => new ConfigurationItemPath(p)))
                    {
                        if (pathInfo.ItemType != typeof(T).Name)
                        {
                            throw new ArgumentException($"Invalid Configuration Item path received. Expected \"{typeof(T).Name}\" and received \"{pathInfo.ItemType}\".");
                        }
                        yield return (T)Activator.CreateInstance(typeof(T), Connection.ManagementServer.ServerId, $"{typeof(T).Name}[{pathInfo.Id}]");
                    }
                    break;

                case nameof(QueryItems):

                    if (Version.Parse(Connection.ManagementServer.Version) < new Version(20, 2))
                    {
                        throw new NotSupportedException($"The QueryItems parameter set requires XProtect version 20.2 or greater. To retrieve hardware child devices from XProtect version {Connection.ManagementServer.Version} you must supply the Hardware parameter.");
                    }
                    var filters = new[]
                    {
                        new PropertyFilter(nameof(Name), Comparison, Name),
                        new PropertyFilter(nameof(Description), Comparison, Description)
                    };
                    var itemFilter = new ItemFilter(typeof(T).Name, filters, EnableFilter);
                    var service = new QueryItems(Connection.CurrentSite.FQID.ServerId);
                    foreach (var result in service.Query(itemFilter, MaxResults))
                    {
                        if (MyInvocation.BoundParameters.ContainsKey(nameof(Channel)) && !Channel.Any(c => c == int.Parse(result.GetProperty(nameof(Channel)))))
                        {
                            continue;
                        }
                        yield return (T)result;
                    }
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} not implemented.");
            }
        }

        private static string AddWildcards(string text, Operator comparison)
        {
            switch (comparison)
            {
                case Operator.Equals:
                    break;
                case Operator.NotEquals:
                    break;
                case Operator.LessThan:
                    break;
                case Operator.GreaterThan:
                    break;
                case Operator.Contains:
                    text = $"*{text.Trim('*')}*";
                    break;
                case Operator.BeginsWith:
                    text = $"{text.Trim('*')}*";
                    break;
            }
            if (string.IsNullOrWhiteSpace(text))
            {
                text = "*";
            }
            return text;
        }

        public void ProcessDeviceRecord<T>(string deviceTypeName)
            where T : IConfigurationItem
        {
            try
            {
                foreach (var device in FindDevices<T>())
                {
                    WriteObject(device);
                }
            }
            catch (TargetInvocationException ex)
            {
                var inner = ex.InnerException;
                while (inner != null)
                {
                    if (inner.GetType().Name == "PathNotFoundMIPException")
                    {
                        string msg;
                        if (Id != null && Id.Length > 0)
                        {
                            msg = $"No {deviceTypeName} device found with the specified Id of '{string.Join(", ", Id)}'.";
                        }
                        else if (Path != null && Path.Length > 0)
                        {
                            msg = $"No {deviceTypeName} device found with the specified Path of '{string.Join(", ", Path)}'.";
                        }
                        else
                        {
                            msg = inner.Message;
                        }
                        var errorRecord = new ErrorRecord(
                            new ItemNotFoundException(msg),
                            "DeviceNotFound",
                            ErrorCategory.ObjectNotFound,
                            null
                        );
                        WriteError(errorRecord);
                        return;
                    }
                    inner = inner.InnerException;
                }
                throw;
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsCamera", DefaultParameterSetName = nameof(QueryItems))]
    [Alias("Get-Camera")]
    [OutputType(typeof(Camera))]
    [RequiresVmsConnection()]
    public class GetCameraCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<Camera>("Camera");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsMicrophone", DefaultParameterSetName = nameof(QueryItems))]
    [Alias("Get-Microphone")]
    [OutputType(typeof(Microphone))]
    [RequiresVmsConnection()]
    public class GetMicrophoneCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<Microphone>("Microphone");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsSpeaker", DefaultParameterSetName = nameof(QueryItems))]
    [Alias("Get-Speaker")]
    [OutputType(typeof(Speaker))]
    [RequiresVmsConnection()]
    public class GetSpeakerCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<Speaker>("Speaker");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsMetadata", DefaultParameterSetName = nameof(QueryItems))]
    [OutputType(typeof(Metadata))]
    [RequiresVmsConnection()]
    public class GetMetadataDeviceCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<Metadata>("Metadata");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsInput", DefaultParameterSetName = nameof(QueryItems))]
    [Alias("Get-Input")]
    [OutputType(typeof(InputEvent))]
    [RequiresVmsConnection()]
    public class GetInputDeviceCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<InputEvent>("Input");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsOutput", DefaultParameterSetName = nameof(QueryItems))]
    [Alias("Get-Output")]
    [OutputType(typeof(Output))]
    [RequiresVmsConnection()]
    public class GetOutputDeviceCommand : GetDeviceCommand
    {
        protected override void ProcessRecord()
        {
            ProcessDeviceRecord<Output>("Output");
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsDevice", DefaultParameterSetName = nameof(QueryItems))]
    [OutputType(typeof(IConfigurationItem))]
    [RequiresVmsConnection()]
    public class GetAnyDeviceCommand : GetDeviceCommand
    {
        [Parameter(ParameterSetName = nameof(QueryItems))]
        [Parameter(ParameterSetName = nameof(Hardware))]
        [ValidateSet("Camera", "Microphone", "Speaker", "Metadata", "Input", "Output")]
        public string[] Type { get; set; } = new string[] { "Camera", "Microphone", "Speaker", "Metadata", "Input", "Output" };

        static readonly Dictionary<string, Type> DeviceTypeMap = new Dictionary<string, Type>(StringComparer.InvariantCultureIgnoreCase)
        {
            { "Hardware",   typeof(Hardware) },
            { "Camera",     typeof(Camera) },
            { "Microphone", typeof(Microphone) },
            { "Speaker",    typeof(Speaker) },
            { "Metadata",   typeof(Metadata) },
            { "Input",      typeof(InputEvent) },
            { "InputEvent", typeof(InputEvent) },
            { "Output",     typeof(Output) }
        };

        private readonly System.Reflection.MethodInfo _findDevicesMethod = typeof(GetDeviceCommand).GetMethod("FindDevices", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

        protected override void ProcessRecord()
        {
            if (ParameterSetName == nameof(Path))
            {
                if (!MyInvocation.BoundParameters.ContainsKey(nameof(Id)))
                {
                    MyInvocation.BoundParameters.Add(nameof(Id), null);
                }
                foreach (var path in Path.Select(str => new ConfigurationItemPath(str)))
                {
                    Id = new Guid[] { new Guid(path.Id) };
                    if (!InvokeFindDevices(path.ItemType, stopAfterFirst: true))
                    {
                        ThrowDeviceNotFoundError(path.ItemType, nameof(Path), path.Path);
                    }
                }
                return;
            }

            if (ParameterSetName == nameof(Id))
            {
                var originalIds = Id;
                foreach (var id in originalIds)
                {
                    Id = new Guid[] { id };
                    bool foundForThisId = false;
                    foreach (var deviceType in Type.Distinct())
                    {
                        if (InvokeFindDevices(deviceType, stopAfterFirst: true))
                        {
                            foundForThisId = true;
                            break; // Stop after first match for this Id
                        }
                    }
                    if (!foundForThisId)
                    {
                        ThrowDeviceNotFoundError(string.Join(", ", Type.Distinct()), nameof(Id), id.ToString());
                    }
                }
                Id = originalIds; // Restore original Id array
                return;
            }

            // Default: query mode, return all matches
            foreach (var deviceType in Type.Distinct())
            {
                InvokeFindDevices(deviceType, stopAfterFirst: false);
            }
            // No error thrown here if nothing is found in query mode
        }

        private readonly Dictionary<Type, System.Reflection.MethodInfo> _genericMethods = new Dictionary<Type, System.Reflection.MethodInfo>();
        private bool InvokeFindDevices(string deviceType, bool stopAfterFirst)
        {
            var type = DeviceTypeMap[deviceType];
            if (!_genericMethods.ContainsKey(type))
            {
                _genericMethods.Add(type, _findDevicesMethod.MakeGenericMethod(type));
            }

            bool found = false;
            try
            {
                foreach (var device in (IEnumerable<IConfigurationItem>)_genericMethods[type].Invoke(this, null))
                {
                    if (device == null) continue;
                    WriteObject(device);
                    found = true;
                    if (stopAfterFirst) break;
                }
            }
            catch (TargetInvocationException ex)
            {
                var inner = ex.InnerException;
                while (inner != null)
                {
                    if (inner.GetType().Name == "PathNotFoundMIPException")
                        return false; // Suppress this error for this type
                    inner = inner.InnerException;
                }
                throw;
            }
            return found;
        }

        private void ThrowDeviceNotFoundError(string deviceType, string paramName, string paramValue)
        {
            var msg = $"No device found with the specified {paramName} of '{paramValue}'.";
            var errorRecord = new ErrorRecord(
                new ItemNotFoundException(msg),
                "DeviceNotFound",
                ErrorCategory.ObjectNotFound,
                deviceType
            );
            WriteError(errorRecord);
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsParentItem", DefaultParameterSetName = nameof(InputObject))]
    [OutputType(typeof(IConfigurationItem))]
    [RequiresVmsConnection()]
    public class GetParentItemCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = nameof(InputObject))]
        public IConfigurationItem[] InputObject { get; set; }

        [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(ParentItemPath))]
        [Alias("ParentPath")]
        public string[] ParentItemPath { get; set; }

        private readonly Assembly _configItemAssembly = typeof(ManagementServer).Assembly;

        protected override void ProcessRecord()
        {
            ConfigurationItemPath path;
            switch (ParameterSetName)
            {
                case nameof(InputObject):
                    foreach (var obj in InputObject)
                    {
                        path = new ConfigurationItemPath(obj.ParentItemPath);
                        CreateInstance(path);
                    }
                    break;
                case nameof(ParentItemPath):
                    foreach (var parentPath in ParentItemPath)
                    {
                        path = new ConfigurationItemPath(parentPath);
                        CreateInstance(path);
                    }
                    break;
                default:
                    throw new InvalidOperationException($"ParameterSetName {ParameterSetName} not implemented.");
            }            
        }

        private readonly Dictionary<string, Type> _typesByName = new Dictionary<string, Type>();
        private void CreateInstance(ConfigurationItemPath path)
        {
            var itemType = path.ItemType == "System" ? nameof(ManagementServer) : path.ItemType;
            if (!_typesByName.ContainsKey(itemType))
            {
                try
                {
                    _typesByName.Add(itemType, _configItemAssembly.GetType($"VideoOS.Platform.ConfigurationItems.{itemType}", true));
                }
                catch (TypeLoadException ex)
                {
                    try
                    {
                        WriteObject(ConfigurationService.GetItem(path.Path));
                        return;
                    }
                    catch
                    {
                        throw new ItemNotFoundException($"Item with Configuration API path \"{path.Path}\" not found.", ex);
                    }
                }
            }
            WriteObject(Activator.CreateInstance(_typesByName[itemType], Connection.ManagementServer.ServerId, path.Path));
        }
    }

    
}
    
