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
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

namespace MilestonePSTools.Connection
{
    public static class ChannelSettings
    {
        public static int MaxBufferPoolSize { get; set; } = 2147483647;
        public static int MaxBufferSize { get; set; } = 2147483647;
        public static int MaxReceivedMessageSize { get; set; } = 2147483647;
        public static int MaxStringContentLength { get; set; } = 2147483647;

        public static RemoteCertificateValidationCallback RemoteCertificateValidationCallback { get; set; } = ValidateAllCerts;

        public static bool ValidateAllCerts(object sender, X509Certificate cert, X509Chain chain, SslPolicyErrors errors) => true;

        public static class Timeouts
        {
            public static TimeSpan AllTimeouts
            {
                set
                {
                    OpenTimeout = value;
                    CloseTimeout = value;
                    ReceiveTimeout = value;
                    SendTimeout = value;
                }
            }

            public static TimeSpan OpenTimeout { get; set; } = TimeSpan.FromMinutes(10);
            public static TimeSpan CloseTimeout { get; set; } = TimeSpan.FromMinutes(10);
            public static TimeSpan ReceiveTimeout { get; set; } = TimeSpan.FromMinutes(10);
            public static TimeSpan SendTimeout { get; set; } = TimeSpan.FromMinutes(10);
        }
    }
}

