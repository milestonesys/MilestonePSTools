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
using System.Data;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.Utility
{
    public class MipItemToPathTransformationAttribute : ArgumentTransformationAttribute
    {
        private readonly string[] _itemTypes;

        public MipItemToPathTransformationAttribute()
        {
            _itemTypes = new string[] { };
        }

        public MipItemToPathTransformationAttribute(params string[] itemTypes)
        {
            _itemTypes = itemTypes;
        }

        public override object Transform(EngineIntrinsics engineIntrinsics, object inputData)
        {
            if (inputData == null) return string.Empty;
            if (inputData is IEnumerable<object> objArray)
            {
                return objArray.Select(obj =>
                {
                    var baseObject = obj is PSObject psObject ? psObject.BaseObject : obj;
                    if (baseObject is IConfigurationItem item)
                    {
                        ValidateItemType(item.Path);
                        return item.Path;
                    }
                    ValidateItemType(baseObject.ToString());
                    return baseObject.ToString();
                });
            }
            else
            {
                var baseObject = inputData is PSObject psObject ? psObject.BaseObject : inputData;
                if (baseObject is IConfigurationItem item)
                {
                    ValidateItemType(item.Path);
                    return item.Path;
                }
                ValidateItemType(baseObject.ToString());
                return baseObject.ToString();
            }
        }

        private void ValidateItemType(string path)
        {
            if (_itemTypes.Length == 0) return;
            try
            {
                var configItemPath = new ConfigurationItemPath(path);
                if (!_itemTypes.Contains(configItemPath.ItemType, StringComparer.OrdinalIgnoreCase))
                {
                    var message = $"Expected an item of type {string.Join(", or ", _itemTypes)}, but received an item of type {configItemPath.ItemType} instead.";
                    throw new ArgumentTransformationMetadataException(
                        message,
                        new PSInvalidCastException(message));
                }
            }
            catch (VideoOS.Platform.ArgumentMIPException mipException)
            {
                var message = $"The string '{path}' is not a valid configuration item path for an XProtect VMS configuration item.";
                throw new ArgumentTransformationMetadataException(
                    message, new PSInvalidCastException(message, mipException));
            }
        }
    }
}
