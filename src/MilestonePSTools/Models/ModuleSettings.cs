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

namespace MilestonePSTools.Models
{
    public class ModuleSettings
    {
        public AppInsightsConfig ApplicationInsights { get; set; }
        public MipConfig Mip { get; set; }
    }

    public class MipConfig
    {
        public EnvironmentManager EnvironmentManager { get; set; }
        public EnvironmentProperties EnvironmentProperties { get; set; }
        public ConfigurationApiManager ConfigurationApiManager { get; set; }
        public bool UseCachedManagementServer { get; set; }
        public int ProxyPoolSize { get; set; }
    }

    public class EnvironmentManager
    {
        public EnvironmentOption[] EnvironmentOptions { get; set; }
        public bool DebugLoggingEnabled { get; set; }
    }

    public class EnvironmentOption
    {
        public string Name { get; set; }
        public string Value { get; set; }
    }

    public class EnvironmentProperties
    {
        public bool TraceLogin { get; set; }
        public bool EnableConfigurationRefresh { get; set; }
        public int ConfigurationRefreshIntervalInMs { get; set; }
        public bool KeepLoginServerUriScheme { get; set; }
    }

    public class ConfigurationApiManager
    {
        public bool BypassApiGateway { get; set; }
        public bool EnableDebugLogging { get; set; }
        public bool UseRestApiWhenAvailable { get; set; }
    }

    public class AppInsightsConfig
    {
        public bool Enabled { get; set; }
        public bool IncludeInLogs { get; set; }
        public string ConnectionString { get; set; }
    }

}

