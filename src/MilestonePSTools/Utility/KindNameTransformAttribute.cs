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
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using VideoOS.Platform;
using VideoOS.Platform.Messaging;

namespace MilestonePSTools.Utility
{
    public class KindNameTransformAttribute : ArgumentTransformationAttribute
    {
        private readonly FieldInfo[] _fields;

        public KindNameTransformAttribute()
        {
            var type = typeof(Kind);
            _fields = type.GetFields(BindingFlags.Static | BindingFlags.Public);
        }

        public override object Transform(EngineIntrinsics engineIntrinsics, object inputData)
        {
            if (inputData is PSObject psobject)
            {
                inputData = psobject.ImmediateBaseObject;
            }

            if (inputData is Guid guid)
            {
                if (!Kind.DefaultTypeToNameTable.ContainsKey(guid))
                {
                    throw new InvalidOperationException($"No VideoOS.Platform.Kind found matching '{guid}'.");
                }
                return guid;
            }

            if (inputData is FQID fqid)
            {
                return fqid.Kind;
            }

            if (inputData is ItemState itemState)
            {
                return itemState.FQID.Kind;
            }

            if (inputData is string kindName)
            {
                return ConvertToGuid(kindName);
            }

            if (inputData is IEnumerable<object> kinds)
            {
                var list = new List<Guid>();
                foreach (var kind in kinds)
                {
                    list.Add(ConvertToGuid(kind.ToString()));
                }
                return list;
            }
            throw new InvalidOperationException($"Expected string or Guid input but received input of type {inputData.GetType().FullName}.");
        }

        private Guid ConvertToGuid(string kindName)
        {
            // Input is a guid in string format
            if (Guid.TryParse(kindName, out var parsedGuid)) return parsedGuid;

            // Input is FQID.ToString()
            var match = Regex.Match(kindName, @"Type:(?<id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$");
            if (match.Success)
            {
                return Guid.Parse(match.Groups["id"].Value);
            }
            var field = _fields.SingleOrDefault(f => f.FieldType == typeof(Guid) && f.Name.Equals(kindName, StringComparison.OrdinalIgnoreCase));
            if (field == null)
            {
                throw new InvalidOperationException($"No VideoOS.Platform.Kind found matching '{kindName}'.");
            }
            return (Guid)field.GetValue(null);
        }
    }
}
