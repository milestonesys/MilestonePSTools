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
using System.Linq;
using VideoOS.ConfigurationApi.ClientService;
using VideoOS.Platform;

namespace MilestonePSTools
{
    public class Webhook
    {
        public string Name { get; set; }
        public Uri Address { get; set; }
        public string Token { get; set; }
        public string ApiVersion { get; set; }

        public Guid Id { get; }
        public DateTime LastModified { get; }
        public string Path { get; }

        public Webhook(ConfigurationItem item)
        {
            if (item.ParentPath != "MIPKind[b9a5bc9c-e9a5-4a15-8453-ffa41f2815ac]/MIPItemFolder")
            {
                throw new ArgumentMIPException($"ConfigurationItem is not a valid {nameof(Webhook)} item.");
            }
            Name = item.DisplayName;
            Path = item.Path;
            Address = new Uri(item.Properties.FirstOrDefault(i => i.Key == nameof(Address))?.Value);
            Token = item.Properties.FirstOrDefault(i => i.Key == nameof(Token))?.Value;
            ApiVersion = item.Properties.FirstOrDefault(i => i.Key == nameof(ApiVersion))?.Value;
            Id = new Guid(item.Properties.First(i => i.Key == nameof(Id)).Value);
            LastModified = DateTime.Parse(item.Properties.First(i => i.Key == nameof(LastModified)).Value);
        }

        public override string ToString()
        {
            return $"[{Name}]({Address})";
        }
    }
}
