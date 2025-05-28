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

using MilestonePSTools.Telemetry;
using System;
using System.Collections.Generic;
using System.Net;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.License;
using VideoOS.Platform.Login;

namespace MilestonePSTools.Connection
{
    public class MilestoneConnection : IDisposable
    {
        public static MilestoneConnection Instance;
        
        private Uri _uri;
        private Item _currentSite;
        private ManagementServer _managementServer;
        private CredentialCache _cc;
        private readonly LoginType _loginType;

        private LoginSettings _loginSettings;
        private SystemLicense _systemLicense;

        public Dictionary<string, object> Cache = new Dictionary<string, object>();
        private DateTime _datetimeConnected;

        public Item MainSite => EnvironmentManager.Instance.GetSiteItem(_loginSettings?.Guid ?? Guid.Empty);

        public Item CurrentSite
        {
            get => _currentSite;
            set
            {
                if (value != null)
                {
                    _currentSite = value;
                    _managementServer = new ManagementServer(_currentSite.FQID.ServerId);
                }
            }
        }

        public SystemLicense SystemLicense
        {
            get
            {
                if (_systemLicense == null)
                {
                    _systemLicense = new SystemLicense();
                }

                return _systemLicense;
            }
        }

        public ManagementServer ManagementServer
        {
            get
            {
                if (Module.Settings.Mip.UseCachedManagementServer)
                {
                    if (_managementServer == null)
                    {
                        _managementServer = new ManagementServer(_currentSite.FQID.ServerId);
                    }

                    return _managementServer;
                }

                return new ManagementServer(_currentSite.FQID.ServerId);
            }
        }

        public TimeSpan Duration {
            get
            {
                return DateTime.Now - _datetimeConnected;
            }
        }

        public bool IncludeChildSites { get; set; }

        public Guid IntegrationId { get; set; } = Guid.Empty;
        public string IntegrationName { get; set; } = string.Empty;
        public string IntegrationVersion { get; set; } = "1.0";
        public string ManufacturerName { get; set; } = string.Empty;

        private string AuthType => _loginType == LoginType.Basic ? "Basic" : _loginType == LoginType.OAuth ? "OAuth" : "Negotiate";
        public bool SecureOnly { get; set; }

        private readonly object _disabledDevicesLock = new object();
        public Dictionary<Guid, Item> DisabledDevices {
            get
            {
                lock (_disabledDevicesLock)
                {
                    if (!Cache.ContainsKey("DisabledDevices"))
                    {
                        var disabledDevices = new Dictionary<Guid, Item>();
                        foreach (var item in VideoOS.Platform.SDK.Environment.GetDisabledDevices(MilestoneConnection.Instance.CurrentSite.FQID.ObjectId))
                        {
                            disabledDevices[item.FQID.ObjectId] = item;
                        }
                        Cache["DisabledDevices"] = disabledDevices;
                    }
                }
                return (Dictionary<Guid, Item>)Cache["DisabledDevices"];
            }
        }

        public MilestoneConnection(Uri uri, LoginType loginType, NetworkCredential nc)
        {
            if (MilestoneConnection.Instance != null)
            {
                MilestoneConnection.Instance.Dispose();
                MilestoneConnection.Instance = null;
            }

            _uri = uri;
            _loginType = loginType;
            switch (loginType)
            {
                case LoginType.Basic:
                case LoginType.Windows:
                    _cc = new CredentialCache { { uri, AuthType, nc } };
                    break;
                case LoginType.WindowsCurrentUser:
                    _cc = new CredentialCache { { uri, AuthType, CredentialCache.DefaultNetworkCredentials } };
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(loginType), loginType, null);
            }

            MilestoneConnection.Instance = this;
        }

        public MilestoneConnection(LoginSettings loginSettings)
        {
            if (loginSettings == null)
            {
                throw new VmsNotConnectedException("Logon did not complete successfully. The LoginSettings object is either null, or the Guid property for the site is empty. This might be due to a compatibility issue between the version of MIP SDK used by MilestonePSTools and your current VMS version.");
            }

            if (MilestoneConnection.Instance != null)
            {
                MilestoneConnection.Instance.Dispose();
                MilestoneConnection.Instance = null;
            }

            _uri = loginSettings.Uri;
            if (loginSettings.IsBasicUser)
            {
                _loginType = LoginType.Basic;
            }
            else if (loginSettings.IsOAuthIdentity)
            {
                _loginType = LoginType.OAuth;
            }
            else if (string.IsNullOrWhiteSpace(loginSettings.CredentialCache.GetCredential(loginSettings.Uri, "Negotiate")?.UserName))
            {
                _loginType = LoginType.WindowsCurrentUser;
            }
            else
            {
                _loginType = LoginType.Windows;
            }
            _cc = loginSettings.CredentialCache;
            _loginSettings = loginSettings;
            CurrentSite = MainSite;

            MilestoneConnection.Instance = this;
            _datetimeConnected = DateTime.Now;
            try
            {
                var privacySetting = new ToolOptionPrivacySetting(CurrentSite.FQID.ServerId, "ToolOption[a36b973e-eb89-4cd9-8f44-5628c1e7f032]");
                if (!privacySetting.CollectTelemetryEnabled)
                {
                    AppInsightsTelemetry.DisableTelemetry();
                    Module.Settings.ApplicationInsights.Enabled = false;
                    Module.UpdateSettings(Module.Settings);
                }
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message);
            }
            AppInsightsTelemetry.SendNewVmsConnectionTelemetry();
        }

        public void Open()
        {
            if (_loginSettings == null)
            {
                VideoOS.Platform.SDK.Environment.AddServer(SecureOnly, _uri, _cc);
                VideoOS.Platform.SDK.Environment.Login(_uri, IntegrationId, IntegrationName, IntegrationVersion,
                  ManufacturerName);
                if (!VideoOS.Platform.SDK.Environment.IsLoggedIn(_uri))
                {
                    // This login method may be obsolete, but it's also necessary when logging in to older VMS
                    VideoOS.Platform.SDK.Environment.Login(_uri);
                }
                if (!VideoOS.Platform.SDK.Environment.IsLoggedIn(_uri))
                {
                    throw new VmsNotConnectedException($"Login to {_uri} did not throw an error, but VideoOS.Platform.SDK.Environment.IsLoggedIn(uri) still returned false.");
                }
                _loginSettings = LoginSettingsCache.GetLoginSettings(_uri.Host);
                //if (_loginSettings == null || _loginSettings.Guid == Guid.Empty)
                if (_loginSettings == null)
                {
                    throw new VmsNotConnectedException("Logon did not complete successfully. The LoginSettings object is either null, or the Guid property for the site is empty. This might be due to a compatibility issue between the version of MIP SDK used by MilestonePSTools and your current VMS version.");
                }

                _cc = _loginSettings.CredentialCache;
                _uri = _loginSettings.Uri;
            }

            CurrentSite = MainSite;
            if (CurrentSite == null)
            {
                throw new ArgumentNullMIPException(
                  $"Something went wrong during the login process. EnvironmentManager.Instance.GetSiteItem returned null. The LoginSettings guid for the attempted login is '{_loginSettings?.Guid.ToString() ?? "null"}'");
            }
            _datetimeConnected = DateTime.Now;

            try
            {
                var privacySetting = new ToolOptionPrivacySetting(CurrentSite.FQID.ServerId, "ToolOption[a36b973e-eb89-4cd9-8f44-5628c1e7f032]");
                if (!privacySetting.CollectTelemetryEnabled)
                {
                    AppInsightsTelemetry.DisableTelemetry();
                    Module.Settings.ApplicationInsights.Enabled = false;
                    Module.UpdateSettings(Module.Settings);
                }
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message);
            }
            AppInsightsTelemetry.SendNewVmsConnectionTelemetry();
            if (!IncludeChildSites) return;

            var stack = new Stack<Item>(MainSite.GetChildren());
            while (stack.Count > 0)
            {
                var item = stack.Pop();
                AddSite(item.FQID.ServerId.Uri);
                item.GetChildren().ForEach(stack.Push);
            }
        }

        private void AddSite(Uri uri)
        {
            if (_loginSettings.IsOAuthIdentity) return;
            _cc.Add(uri, AuthType, _loginSettings.NetworkCredential);
            VideoOS.Platform.SDK.Environment.AddServer(SecureOnly, uri, _cc);
            VideoOS.Platform.SDK.Environment.Login(uri, IntegrationId, IntegrationName, IntegrationVersion,
                  ManufacturerName);
        }

        public IEnumerable<Item> GetSites()
        {
            if (MainSite == null) yield break;
            var stack = new Stack<Item>(new[] { MainSite });
            while (stack.Count > 0)
            {
                var item = stack.Pop();
                yield return item;
                item.GetChildren().ForEach(stack.Push);
            }
        }

        public T CreateChannel<T>(ServerId serverId = null) where T : class
        {
            serverId = serverId ?? MainSite.FQID.ServerId;
            var loginSettings = LoginSettingsCache.GetLoginSettings(serverId);
            return ChannelBuilder.BuildChannel<T>(loginSettings);
        }

        public string GetCurrentToken(ServerId serverId = null)
        {
            serverId = serverId ?? MainSite.FQID.ServerId;
            var settings = LoginSettingsCache.GetLoginSettings(serverId);
            return settings.Token;
        }

        public void Dispose()
        {
            AppInsightsTelemetry.SendCloseVmsConnectionTelemetry();
            VideoOS.Platform.SDK.Environment.Logout();
            VideoOS.Platform.SDK.Environment.RemoveAllServers();
        }
    }
}

