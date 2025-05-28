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
using VideoOS.Platform.ConfigurationItems;

namespace MilestoneLib
{
    public class DeviceAcl
    {
        public Role Role { get; set; }
        public string Path { get; set; }
        public Dictionary<string, string> SecurityAttributes { get; set; }

        public void ApplyTemplate(AclTemplate template)
        {
            var keys = SecurityAttributes.Keys.ToList();
            switch (template)
            {
                case AclTemplate.Full:
                    foreach (var key in keys)
                    {
                        SecurityAttributes[key] = true.ToString();
                    }
                    break;
                case AclTemplate.None:
                    foreach (var key in keys)
                    {
                        SecurityAttributes[key] = false.ToString();
                    }
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(template), template, null);
            }
        }

        public enum AclTemplate
        {
            Full,
            None,
        }
    }
}
