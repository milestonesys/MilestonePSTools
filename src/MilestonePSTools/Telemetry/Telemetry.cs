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

using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.ApplicationInsights.Extensibility.Implementation;
using MilestonePSTools.Connection;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using VideoOS.Common.Proxy.Server.WCF;
using VideoOS.Platform;
using VideoOS.Platform.Login;

namespace MilestonePSTools.Telemetry
{
    public enum TelemetryType
    {
        NewSession,
        NewVmsConnection,
        VmsInfo,
        CloseVmsConnection,
        InvokeCommand,
        FailedCommand
    }

    internal class NameObscurerTelemetryInitializer : ITelemetryInitializer
    {
        private const string _notavailable = "na";

        public void Initialize(ITelemetry telemetry)
        {
            telemetry.Context.Cloud.RoleName = _notavailable;
            telemetry.Context.Cloud.RoleInstance = _notavailable;
            telemetry.Context.User.AuthenticatedUserId = _notavailable;
            telemetry.Context.GetInternalContext().NodeName = _notavailable;
        }
    }
    internal class LogFileTelemetryChannel : ITelemetryChannel
    {
        private readonly JsonSerializerOptions _serializerOptions = new JsonSerializerOptions { WriteIndented = true };

        public bool? DeveloperMode { get; set; }
        public string EndpointAddress { get; set; }

        public LogFileTelemetryChannel()
        {
            DeveloperMode = false;
        }

        public LogFileTelemetryChannel(bool developerMode, string endpointAddress)
        {
            DeveloperMode = developerMode;
            EndpointAddress = endpointAddress;
        }

        public void Dispose()
        {
            return;
        }

        public void Flush()
        {
            return;
        }

        public void Send(ITelemetry item)
        {
            EnvironmentManager.Instance.Log(false, System.Reflection.MethodBase.GetCurrentMethod().Name, System.Text.Json.JsonSerializer.Serialize(item, _serializerOptions));
        }
    }
    public static class AppInsightsTelemetry
    {
        private static readonly TelemetryClient _telemetryClient;
        private static Guid _defaultUserId = new Guid("16f8f754-9fdc-4360-8e87-b36f8ae64af2");
        private static int _startupTelemetrySent = 0;
        private static Task _task;

        private static Guid UserId { get; }
        public static Guid SessionId { get; }
        public static bool CanSendTelemetry { get; private set; } = false;
        public static bool HasDisplayedTelemetryNotice
        {
            get
            {
                return File.Exists(Path.Combine(Module.AppDataDirectory, "telemetry_notice_displayed.txt"));
            }
        }

        internal static TelemetryClient TelemetryClient { get => _telemetryClient; }

        static AppInsightsTelemetry()
        {
            CanSendTelemetry = Module.Settings.ApplicationInsights.Enabled;
            
            // AppInsights is disabled
            if (!CanSendTelemetry) return;

            // AppInsights key is invalid
            if (string.IsNullOrWhiteSpace(Module.Settings.ApplicationInsights.ConnectionString))
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, $"ApplicationInsights.ConnectionString is empty.");
                return;
            }

            UserId = GetUuid("telemetry.uuid");
            SessionId = Guid.NewGuid();

            var telemetryConfig = new TelemetryConfiguration
            {
                ConnectionString = Module.Settings.ApplicationInsights.ConnectionString
            };
            if (Module.Settings.ApplicationInsights.IncludeInLogs)
            {
                telemetryConfig.TelemetrySinks.Add(new TelemetrySink(telemetryConfig, new LogFileTelemetryChannel()));
            }
            
            telemetryConfig.TelemetryInitializers.Add(new NameObscurerTelemetryInitializer());

            _telemetryClient = new TelemetryClient(telemetryConfig);
            _telemetryClient.Context.Component.Version = Module.AssemblyVersion;
            _telemetryClient.Context.Session.Id = SessionId.ToString();
            _telemetryClient.Context.User.Id = UserId.ToString();
        }

        internal static void DisableTelemetry()
        {
            CanSendTelemetry = false;
        }

        internal static void SendStartupTelemetry()
        {
            if (Interlocked.CompareExchange(ref _startupTelemetrySent, 1, 0) == 1)
            {
                return;
            }

            if (!CanSendTelemetry)
            {
                return;
            }

            var properties = new Dictionary<string, string>
            {
                { "AssemblyVersion", Module.AssemblyVersion },
                { "SessionId", SessionId.ToString() },
                { "UUID", UserId.ToString() },
                { "OSDescription", RuntimeInformation.OSDescription },
                { "FrameworkDescription", RuntimeInformation.FrameworkDescription }
            };

            var parameters = new Dictionary<string, double>
            {
                { "ProcessorCount", Environment.ProcessorCount },
                { "PrivateBytes", GetPrivateBytes() }
            };

            try
            {
                TelemetryClient.TrackEvent(TelemetryType.NewSession.ToString(), properties, parameters);
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
            }
        }

        private static Guid GetUuid(string fileName)
        {
            var uuidPath = Path.Combine(Module.AppDataDirectory, fileName);
            if (TryGetIdentifier(uuidPath, out Guid id))
            {
                return id;
            }

            try {
                using (var mutex = new Mutex(true, "VMS_CreateUniqueUserId"))
                {
                    mutex.WaitOne();
                    try
                    {
                        return CreateUserIdAndFile(uuidPath);
                    }
                    finally
                    {
                        mutex.ReleaseMutex();
                    }
                }
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
            }

            CanSendTelemetry = false;
            return id;
        }

        private static bool TryGetIdentifier(string uuidPath, out Guid id)
        {
            try
            {
                if (File.Exists(uuidPath))
                {
                    id = new Guid(File.ReadAllBytes(uuidPath));
                    return true;
                }
            }
            catch (Exception)
            {
                
            }
            id = Guid.Empty;
            return false;
        }

        private static Guid CreateUserIdAndFile(string uuidPath)
        {
            if (TryGetIdentifier(uuidPath, out Guid id))
            {
                return id;
            }

            var attemptFileCreation = true;
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(uuidPath));
            }
            catch
            {
                attemptFileCreation = false;
            }


            if (attemptFileCreation)
            {
                try
                {
                    id = Guid.NewGuid();
                    File.WriteAllBytes(uuidPath, id.ToByteArray());
                    return id;
                }
                catch (Exception ex)
                {
                    EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                }
            }

            // all attempts to create an identifier have failed, so use the default node id.
            id = _defaultUserId;
            return id;
        }

        private static readonly HashSet<string> _invokedCommands = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        public static void SendInvokeCommandTelemetry(InvocationInfo myInvocation, string parameterSetName = "na")
        {
            // Do not send telemetry if the user has opted out
            if (!CanSendTelemetry)
            {
                return;
            }

            // Do not send telemetry for commands invoked by the module itself
            if (myInvocation.CommandOrigin == CommandOrigin.Internal &&
                myInvocation.PSScriptRoot.StartsWith(Module.ModuleDirectory, StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            // Only send event once per command per session
            if (_invokedCommands.Contains(myInvocation.MyCommand.Name))
            {
                return;
            }

            var properties = new Dictionary<string, string>
            {
                { "Command", myInvocation.MyCommand.Name },
                { "ParameterSet", parameterSetName },
            };

            try
            {
                TelemetryClient.TrackEvent(TelemetryType.InvokeCommand.ToString(), properties);
                _invokedCommands.Add(myInvocation.MyCommand.Name);
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
            }
        }

        public static void SendNewVmsConnectionTelemetry()
        {
            if (!CanSendTelemetry)
            {
                return;
            }
            _task = Task.Run(() =>
            {
                try
                {
                    var loginSettings = LoginSettingsCache.GetLoginSettings(Configuration.Instance.ServerFQID);
                    var scs = ConfigApiCmdlet.GetProxyClient<IServerCommandService>();
                    var config = scs.GetConfiguration(loginSettings.Token);
                    var site = EnvironmentManager.Instance.GetSiteItem(Configuration.Instance.ServerFQID);
                    var encryptionEnabled = loginSettings.Uri.Scheme.Equals("https", StringComparison.CurrentCultureIgnoreCase);
                    var notAvailable = "na";
                    var properties = new Dictionary<string, string>
                    {
                        { "uuid", UserId.ToString() },
                        { "SessionId", SessionId.ToString() },
                        { "SiteId", GetUuid($"site-{site.FQID.ObjectId}.uuid").ToString() },
                        { "AssemblyVersion", Module.AssemblyVersion },
                        { "ProductName", scs.GetProductInfo().ProductName },
                        { "ProductVersion", scs.GetServerVersion() },
                        { "UserType", loginSettings?.UserInformation.Type.ToString() ?? notAvailable },
                        { "IsOAuthConnection", loginSettings?.IsOAuthConnection.ToString() ?? notAvailable },
                        { "EncryptionEnabled", encryptionEnabled.ToString() }
                    };
                    
                    var parameters = new Dictionary<string, double>
                    {
                        { "ChildSites", site.GetChildren().Count },
                        { "Recorders", config.Recorders.Length },
                        { "HardwareCount", config.Recorders.Sum(r => r.Hardware.Length) },
                        { "CameraCount", config.Recorders.Sum(r => r.Cameras.Length) },
                        { "MicrophoneCount", config.Recorders.Sum(r => r.Microphones.Length) },
                        { "SpeakerCount", config.Recorders.Sum(r => r.Speakers.Length) },
                        { "MetadataCount", config.Recorders.Sum(r => r.MetadataDevices.Length) },
                        { "InputCount", config.Recorders.Sum(r => r.Inputs.Length) },
                        { "OutputCount", config.Recorders.Sum(r => r.Outputs.Length) }
                    };
                    TelemetryClient.TrackEvent(TelemetryType.NewVmsConnection.ToString(), properties, parameters);
                }
                catch (Exception ex)
                {
                    EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                }
            });
        }

        public static void SendCloseVmsConnectionTelemetry()
        {
            if (!CanSendTelemetry)
            {
                return;
            }

            try
            {
                _task.Wait(TimeSpan.FromSeconds(1));
                _task.Dispose();
                var site = EnvironmentManager.Instance.GetSiteItem(Configuration.Instance.ServerFQID);
                var properties = new Dictionary<string, string>
                {
                    { "uuid", UserId.ToString() },
                    { "SessionId", SessionId.ToString() },
                    { "SiteId", GetUuid($"site-{site.FQID.ObjectId}.uuid").ToString() }
                };
                var parameters = new Dictionary<string, double>
                {
                    { "ConnectionDuration", MilestoneConnection.Instance.Duration.TotalSeconds },
                    { "PrivateBytes", GetPrivateBytes() },
                };
                foreach (var apiCounter in Configuration.Instance.ConfigurationApiManager.ApiCounters)
                {
                    parameters[nameof(apiCounter.GetItem)] = apiCounter.GetItem;
                    parameters[nameof(apiCounter.GetItems)] = apiCounter.GetItems;
                    parameters[nameof(apiCounter.PutItem)] = apiCounter.PutItem;
                    parameters[nameof(apiCounter.Patch)] = apiCounter.Patch;
                    parameters[nameof(apiCounter.Post)] = apiCounter.Post;
                    parameters[nameof(apiCounter.Delete)] = apiCounter.Delete;
                }
                TelemetryClient.TrackEvent(TelemetryType.CloseVmsConnection.ToString(), properties, parameters);
                TelemetryClient.Flush();
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
            }
        }

        private static long GetPrivateBytes()
        {
            using (var process = Process.GetCurrentProcess())
            {
                return process.PrivateMemorySize64;
            }
        }
    }
}

