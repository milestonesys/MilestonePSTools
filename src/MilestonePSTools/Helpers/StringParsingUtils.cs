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

using System.Text.RegularExpressions;

namespace MilestoneLib
{
    public static class StringParsingUtils
    {
        /// <summary>
        /// Device setting keys are typically in the format identifier/propertyName/{guid}. This method extracts the
        /// property name from the middle of the key.
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static string GetPropertyNameFromKey(string key)
        {
            var match = Regex.Match(key,
                @"^[^/]+/(?<name>[^/]+)/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}");
            return match.Success ? match.Groups["name"].Value : key;
        }
    }
}

