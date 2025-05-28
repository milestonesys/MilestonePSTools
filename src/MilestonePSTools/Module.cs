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

using Microsoft.Extensions.Configuration;
using MilestonePSTools.Connection;
using MilestonePSTools.Models;
using MilestonePSTools.Telemetry;
using System;
using System.Diagnostics;
using System.IO;
using System.Management.Automation;
using System.Text.Json;
using VideoOS.Platform;
using EnvironmentManager = VideoOS.Platform.EnvironmentManager;

namespace MilestonePSTools
{
    public static class Module
    {
        private static IConfigurationRoot _embeddedConfig;
        private static IConfigurationRoot _config;
        private static IDisposable _configCallback;
        private static ModuleSettings _settings;
        private static ModuleSettings _embeddedSettings;
        private static readonly string _appSettingsPath;
        private static readonly string _userAppSettingsPath;

        public const string ModuleName = "MilestonePSTools";
        public const string ModuleId = "46909c4a-d5d8-4faf-830d-5a0df564fe7b";
        public const string CompanyName = "Milestone Systems, Inc.";
        public static string AppDataDirectory { get; } = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData) + @"\Milestone\MilestonePSTools";
        public static string ProgramDataDirectory { get; private set; }
        public static string AssemblyVersion { get; } = FileVersionInfo.GetVersionInfo(typeof(Module).Assembly.Location).ProductVersion;

        internal static ModuleSettings EmbeddedSettings => _embeddedSettings;

        public static ModuleSettings Settings {
            get => _settings;
            private set
            {
                _settings = value;
                ApplySettings(null);
            }
        }

        

        static Module()
        {
            var assemblyFileInfo = new FileInfo(typeof(MilestoneConnection).Assembly.Location);
            _appSettingsPath = Path.Combine(assemblyFileInfo.DirectoryName, "appsettings.json");
            _userAppSettingsPath = Path.Combine(AppDataDirectory, "appsettings.user.json");
        }

        public static void Initialize()
        {
            InitializeConfiguration();
            ApplySettings(null);
            ProgramDataDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), EnvironmentManager.Instance.EnvironmentOptions[EnvironmentOptions.CompanyNameFolder], "MIPSDK");
        }

        private static void InitializeConfiguration()
        {
            _embeddedConfig = new ConfigurationBuilder()
                .AddJsonFile(_appSettingsPath, optional: false, reloadOnChange: false)
                .Build();
            _embeddedSettings = _embeddedConfig.Get<ModuleSettings>();
            
            _config = new ConfigurationBuilder()
                .AddJsonFile(_appSettingsPath, optional: false, reloadOnChange: false)
                .AddJsonFile(_userAppSettingsPath, optional: true, reloadOnChange: true)
                .AddEnvironmentVariables("VMS_")
                .Build();
            Settings = _config.Get<ModuleSettings>();

            if (_embeddedSettings.ApplicationInsights.ConnectionString != Settings.ApplicationInsights.ConnectionString)
            {
                Settings.ApplicationInsights.ConnectionString = _embeddedSettings.ApplicationInsights.ConnectionString;
                UpdateSettings(Settings);
            }
        }

        private static void ApplySettings(object state)
        {
            foreach (var option in Settings.Mip.EnvironmentManager.EnvironmentOptions)
            {
                EnvironmentManager.Instance.EnvironmentOptions[option.Name] = option.Value;
            }
            EnvironmentManager.Instance.DebugLoggingEnabled = Settings.Mip.EnvironmentManager.DebugLoggingEnabled;
            EnvironmentManager.Instance.FireEnvironmentOptionsChangedEvent();

            VideoOS.Platform.SDK.Environment.Properties.TraceLogin = Settings.Mip.EnvironmentProperties.TraceLogin;
            VideoOS.Platform.SDK.Environment.Properties.EnableConfigurationRefresh = Settings.Mip.EnvironmentProperties.EnableConfigurationRefresh;
            VideoOS.Platform.SDK.Environment.Properties.ConfigurationRefreshIntervalInMs = Settings.Mip.EnvironmentProperties.ConfigurationRefreshIntervalInMs;
            VideoOS.Platform.SDK.Environment.Properties.KeepLoginServerUriScheme = Settings.Mip.EnvironmentProperties.KeepLoginServerUriScheme;

            VideoOS.Platform.Proxy.ConfigApi.ConfigurationApiManager.BypassApiGateway = Settings.Mip.ConfigurationApiManager.BypassApiGateway;
            VideoOS.Platform.Proxy.ConfigApi.ConfigurationApiManager.EnableDebugLogging = Settings.Mip.ConfigurationApiManager.EnableDebugLogging;

            Configuration.Instance.ConfigurationApiManager.UseRestApiWhenAvailable = Settings.Mip.ConfigurationApiManager.UseRestApiWhenAvailable;

            // TODO: This doesn't feel right but is the only way I've been able to get the configuration to reload after multiple configuration changes
            _configCallback?.Dispose();
            _configCallback = _config.GetReloadToken().RegisterChangeCallback(ApplySettings, _config);
            var verb = state == null ? "Loading" : "Reloading";
            EnvironmentManager.Instance.Log(false, System.Reflection.MethodBase.GetCurrentMethod().Name, $"{verb} MilestonePSTools configuration");
        }

        public static void UpdateSettings(ModuleSettings settings)
        {
            try
            {
                var appSettingsJson = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
                if (!Directory.Exists(Path.GetDirectoryName(_userAppSettingsPath)))
                {
                    Directory.CreateDirectory(Path.GetDirectoryName(_userAppSettingsPath));
                }

                File.WriteAllText(_userAppSettingsPath, appSettingsJson);
            }
            catch (Exception ex) 
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                throw;
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "VmsModuleConfig")]
    [OutputType(typeof(ModuleSettings))]
    [RequiresVmsConnection(false)]
    public class GetModuleConfigCommand : PSCmdlet
    {
        protected override void ProcessRecord()
        {
            WriteObject(Module.Settings);
        }
    }

    [Cmdlet(VerbsCommon.Set, "VmsModuleConfig")]
    [RequiresVmsConnection(false)]
    public class SetModuleConfigCommand : PSCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true, Position = 0, ParameterSetName = "InputObject")]
        public ModuleSettings InputObject { get; set; }

        [Parameter(ParameterSetName = "Options")]
        public bool EnableTelemetry { get; set; }
        
        [Parameter(ParameterSetName = "Options")]
        public bool LogTelemetry { get; set; }
        
        [Parameter(ParameterSetName = "Options")]
        public bool EnableDebugLogging { get; set; }
        
        [Parameter(ParameterSetName = "Options")]
        [ValidateRange(1,8)]
        public int ProxyPoolSize { get; set; } 

        protected override void ProcessRecord()
        {
            if (InputObject != null)
            {
                Module.UpdateSettings(InputObject);
                return;
            }
            
            if (MyInvocation.BoundParameters.ContainsKey(nameof(EnableTelemetry)))
            {
                Module.Settings.ApplicationInsights.Enabled = EnableTelemetry;
                if (!EnableTelemetry)
                {
                    AppInsightsTelemetry.DisableTelemetry();
                }
            }
            if (MyInvocation.BoundParameters.ContainsKey(nameof(LogTelemetry)))
            {
                Module.Settings.ApplicationInsights.IncludeInLogs = LogTelemetry;
            }
            if (MyInvocation.BoundParameters.ContainsKey(nameof(EnableDebugLogging)))
            {
                Module.Settings.Mip.EnvironmentManager.DebugLoggingEnabled = EnableDebugLogging;
            }
            if (MyInvocation.BoundParameters.ContainsKey(nameof(ProxyPoolSize)))
            {
                Module.Settings.Mip.ProxyPoolSize = ProxyPoolSize;
            }
            Module.UpdateSettings(Module.Settings);
        }
    }
}
