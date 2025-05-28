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
    public static class AclHelpers
    {
        public static DeviceAcl GetAcl(dynamic item, Role role)
        {
            var task = (ServerTask)item.ChangeSecurityPermissions(role.Path);
            var attributes = new Dictionary<string, string>();
            var acl = new DeviceAcl {Role = role, Path = item.Path};
            foreach (var key in task.GetPropertyKeys().OrderBy(k => k))
            {
                if (key.Equals("UserPath", StringComparison.OrdinalIgnoreCase))
                    continue;
                attributes.Add(key, task.GetProperty(key));
            }

            acl.SecurityAttributes = attributes;
            return acl;
        }

        public static ServerTask SetAcl(dynamic device, DeviceAcl acl)
        {
            var task = device.ChangeSecurityPermissions(acl.Role.Path);
            foreach (var key in ((ICollection<string>)task.GetPropertyKeys()).OrderBy(k => k))
            {
                if (key.Equals("UserPath", StringComparison.OrdinalIgnoreCase))
                    continue;
                if (acl.SecurityAttributes.ContainsKey(key))
                {
                    task.SetProperty(key, acl.SecurityAttributes[key]);
                }
            }

            return task.ExecuteDefault();
        }
    }
}
