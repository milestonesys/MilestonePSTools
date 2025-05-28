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
using System.Diagnostics;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Security;
using System.Text;
using System.Xml;
using VideoOS.Common.Proxy.Server.WCF;
using VideoOS.Platform.Login;
using IConfigurationService = VideoOS.ConfigurationApi.ClientService.IConfigurationService;

namespace MilestonePSTools.Connection
{
    internal static class ChannelBuilder
    {
        private static readonly Dictionary<Type, string> ServicePaths = new Dictionary<Type, string>();

        static ChannelBuilder()
        {
            ServicePaths.Add(typeof(IConfigurationService), "/ManagementServer/ConfigurationApiService.svc");
            ServicePaths.Add(typeof(IServerCommandService), "/ManagementServer/ServerCommandService.svc");
            ServicePaths.Add(typeof(VideoOS.Platform.Util.Svc.IServiceRegistrationService), "/ManagementServer/ServiceRegistrationService.svc");
        }

        public static T BuildChannel<T>(LoginSettings loginSettings) where T : class
        {
            var servicePath = ServicePaths[typeof(T)];
            Binding binding;
            if (loginSettings.IsOAuthConnection)
            {
                servicePath = servicePath.Replace(".svc", "OAuth.svc");
                binding = GetOAuthBinding(isHttps: loginSettings.Uri.Scheme.Equals("https", StringComparison.CurrentCultureIgnoreCase));
            }
            else
            {
                binding = GetLegacyBinding(loginSettings);
            }
            var serviceUri = new Uri(loginSettings.UriCorporate, servicePath);
            var spn = VideoOS.Platform.Util.SpnFactory.GetSpn(serviceUri);
            var factory = new ChannelFactory<T>(binding, new EndpointAddress(serviceUri, EndpointIdentity.CreateSpnIdentity(spn)));

            if (!loginSettings.SecureOnly)
            {
                factory.Credentials.ServiceCertificate.SslCertificateAuthentication =
                    new X509ServiceCertificateAuthentication()
                    {
                        CertificateValidationMode = X509CertificateValidationMode.None,
                    };
            }

            // Attach credentials / behaviors as needed depending on the type of WCF binding/credential
            if (loginSettings.IsOAuthConnection)
            {
                if (factory.Endpoint.EndpointBehaviors.Contains(typeof(AddTokenBehavior)))
                {
                    factory.Endpoint.EndpointBehaviors.Remove(typeof(AddTokenBehavior));
                }
                factory.Endpoint.EndpointBehaviors.Add(new AddTokenBehavior(loginSettings.IdentityTokenCache));
                ConfigureEndpoint(factory.Endpoint);
            }
            else if (loginSettings.IsBasicUser)
            {
                factory.Credentials.UserName.UserName = loginSettings.NetworkCredential.UserName;
                factory.Credentials.UserName.Password = loginSettings.NetworkCredential.Password;
            }
            else
            {
                factory.Credentials.Windows.ClientCredential = loginSettings.NetworkCredential;
            }

            var channel = factory.CreateChannel();
            if (channel is ClientBase<T> clientBase)
            {
                clientBase.Open();
            }
            return channel;
        }

        public static void ConfigureEndpoint(ServiceEndpoint serviceEndpoint)
        {
            if (serviceEndpoint == null)
            {
                throw new ArgumentNullException(nameof(serviceEndpoint));
            }

            foreach (var operationDescription in serviceEndpoint.Contract.Operations)
            {
                var operationBehavior = operationDescription.Behaviors[typeof(DataContractSerializerOperationBehavior)];
                if (operationBehavior != null)
                {
                    if (operationBehavior is DataContractSerializerOperationBehavior dataContractSerializerOperationBehavior)
                    {
                        dataContractSerializerOperationBehavior.MaxItemsInObjectGraph = 2147483647;
                    }
                }
            }
        }

        public static Binding GetOAuthBinding(bool isHttps)
        {
            var binding = new BasicHttpBinding();
            binding.Security.Mode = isHttps ? BasicHttpSecurityMode.Transport : BasicHttpSecurityMode.None;
            binding.ReaderQuotas.MaxStringContentLength = 2147483647;
            binding.MaxReceivedMessageSize = 2147483647;
            binding.MaxBufferPoolSize = 2147483647;
            if (!Debugger.IsAttached)
            {
                // Avoid timeout if debugging calls to server
                binding.ReceiveTimeout = ChannelSettings.Timeouts.ReceiveTimeout;
                binding.SendTimeout = ChannelSettings.Timeouts.SendTimeout;
                binding.CloseTimeout = ChannelSettings.Timeouts.CloseTimeout;
            }
            binding.BypassProxyOnLocal = false;
            binding.HostNameComparisonMode = HostNameComparisonMode.StrongWildcard;
            binding.MessageEncoding = WSMessageEncoding.Text;
            binding.TextEncoding = Encoding.UTF8;
            binding.UseDefaultWebProxy = true;
            binding.AllowCookies = false;

            binding.ReaderQuotas = XmlDictionaryReaderQuotas.Max;

            return binding;
        }

        public static Binding GetLegacyBinding(LoginSettings loginSettings)
        {
            if (loginSettings.IsBasicUser)
            {
                return new BasicHttpBinding
                {
                    OpenTimeout = ChannelSettings.Timeouts.OpenTimeout,
                    CloseTimeout = ChannelSettings.Timeouts.CloseTimeout,
                    ReceiveTimeout = ChannelSettings.Timeouts.ReceiveTimeout,
                    SendTimeout = ChannelSettings.Timeouts.SendTimeout,
                    ReaderQuotas = XmlDictionaryReaderQuotas.Max,
                    MaxReceivedMessageSize = ChannelSettings.MaxReceivedMessageSize,
                    MaxBufferSize = ChannelSettings.MaxBufferSize,
                    MaxBufferPoolSize = ChannelSettings.MaxBufferPoolSize,
                    HostNameComparisonMode = HostNameComparisonMode.StrongWildcard,
                    MessageEncoding = WSMessageEncoding.Text,
                    TextEncoding = Encoding.UTF8,
                    UseDefaultWebProxy = true,
                    AllowCookies = false,
                    Security =
                    {
                        Mode = BasicHttpSecurityMode.Transport,
                        Transport = {ClientCredentialType = HttpClientCredentialType.Basic}
                    }
                };
            }
            else
            {
                return new WSHttpBinding
                {
                    OpenTimeout = ChannelSettings.Timeouts.OpenTimeout,
                    CloseTimeout = ChannelSettings.Timeouts.CloseTimeout,
                    ReceiveTimeout = ChannelSettings.Timeouts.ReceiveTimeout,
                    SendTimeout = ChannelSettings.Timeouts.SendTimeout,
                    ReaderQuotas = XmlDictionaryReaderQuotas.Max,
                    MaxReceivedMessageSize = ChannelSettings.MaxReceivedMessageSize,
                    // MaxBufferSize not defined on WSHttpBinding
                    MaxBufferPoolSize = ChannelSettings.MaxBufferPoolSize,
                    HostNameComparisonMode = HostNameComparisonMode.StrongWildcard,
                    MessageEncoding = WSMessageEncoding.Text,
                    TextEncoding = Encoding.UTF8,
                    UseDefaultWebProxy = true,
                    AllowCookies = false,
                    Security =
                    {
                        Message =
                        {
                            ClientCredentialType = MessageCredentialType.Windows
                        }
                    }
                };
            }
        }
    }
}

