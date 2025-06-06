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
using System.Management.Automation;
using MilestonePSTools.Connection;
using MilestonePSTools.Telemetry;
using VideoOS.Common.Proxy.Server.WCF;
using VideoOS.ConfigurationApi.ClientService;
using VideoOS.Platform;
using VideoOS.Platform.Login;

namespace MilestonePSTools
{
    internal class ProxyClientPool
    {
        private readonly List<object> _clients;
        private int _position = 0;
        private readonly object _poolLock = new object();

        public ProxyClientPool()
        {
            _clients = new List<object>();
        }

        public void Add(object client)
        {
            lock (_poolLock)
            {
                _clients.Add(client);
            }
        }

        public object GetNext()
        {
            lock (_poolLock)
            {
                if (_clients.Count == 0)
                {
                    throw new ArgumentOutOfRangeException($"There are no proxy clients available in pool.");
                }
                _position = _position >= _clients.Count ? 0 : _position;
                return _clients[_position++];
            }
        }
    }

    public abstract class VmsCmdlet : PSCmdlet
    {
        protected override void BeginProcessing()
        {
            AppInsightsTelemetry.SendInvokeCommandTelemetry(MyInvocation, ParameterSetName);
        }
    }

    public abstract class PSCmdletWithRequirements : VmsCmdlet {
        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            foreach (var attribute in GetType().GetCustomAttributes(true))
            {
                if (attribute is IVmsRequirementValidator requirement)
                {
                    requirement.Validate();
                }
            }
        }
    }

    public abstract class ConfigApiCmdlet : PSCmdletWithRequirements
    {
        private string _assemblyPath;

        public MilestoneConnection Connection => MilestoneConnection.Instance;

        public IConfigurationService ConfigurationService => GetProxyClient<IConfigurationService>();
        public IServerCommandService ServerCommandService => GetProxyClient<IServerCommandService>();
        public VideoOS.Platform.Util.Svc.IServiceRegistrationService ServiceRegistrationService => GetProxyClient<VideoOS.Platform.Util.Svc.IServiceRegistrationService>();
        public string CurrentToken => LoginSettingsCache.GetLoginSettings(Connection.CurrentSite.FQID.ServerId).Token;

        protected override void BeginProcessing()
        {
            // Find IVmsRequirementValidator attributes on derived class and execute validation method(s).
            base.BeginProcessing();
            
            _assemblyPath = _assemblyPath ?? System.IO.Path.GetDirectoryName(EnvironmentManager.Instance.GetType().Assembly.Location);
        }

        public static void ClearProxyClientCache()
        {
            lock (_proxyClientLock)
            {
                _proxyClients.Clear();
            }
        }

        private static readonly object _proxyClientLock = new object();
        private static readonly Dictionary<Type, ProxyClientPool> _proxyClients = new Dictionary<Type, ProxyClientPool>();
        protected internal static T GetProxyClient<T>() where T : class
        {
            var proxyType = typeof(T);
            lock (_proxyClientLock)
            {
                if (!_proxyClients.ContainsKey(proxyType))
                {
                    _proxyClients.Add(proxyType, new ProxyClientPool());
                    var loginSettings = LoginSettingsCache.GetLoginSettings(MilestoneConnection.Instance.CurrentSite.FQID.ServerId);
                    for (int i = 0; i < Module.Settings.Mip.ProxyPoolSize; i++)
                    {
                        var channel = ChannelBuilder.BuildChannel<T>(loginSettings);
                        _proxyClients[proxyType].Add(channel);
                    }
                }
            }
            return (T)_proxyClients[proxyType].GetNext();
        }

        protected void WriteExceptionError(Exception ex, string message = null)
        {
            EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, $"Message: {message}; Exception: {ex}");
            WriteError(
                new ErrorRecord(
                    ex,
                    message ?? ex.Message,
                    ErrorCategory.InvalidOperation,
                    null));
        }
    }
}

