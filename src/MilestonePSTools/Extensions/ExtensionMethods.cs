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
using System.Device.Location;
using System.Linq;
using System.Management.Automation;
using System.Runtime.Serialization;
using System.Text.RegularExpressions;
using VideoOS.ConfigurationApi.ClientService;
using ValueTypes = VideoOS.ConfigurationAPI.ValueTypes;

namespace MilestonePSTools.Extensions
{
    public static class GisPointUtils
    {
        public static string ToGisPoint(this string coordinate)
        {
            if (string.IsNullOrEmpty(coordinate)) return "POINT EMPTY";

            var parts = coordinate.Split(',').Select(n => double.Parse(n.Trim())).ToList();
            if (parts.Count == 2)
            {
                return $"POINT ({parts[1]} {parts[0]})";
            }
            else if (parts.Count == 3)
            {
                return $"POINT ({parts[1]} {parts[0]} {parts[2]})";
            }
            throw new ArgumentException("Coordinates must be provided as a comma-separated list of numbers representing the latitude, longitude, and optionally altitude.");
        }

        public static string ToGisPoint(this GeoCoordinate coordinate)
        {
            return $"POINT ({coordinate.Latitude} {coordinate.Longitude})";
        }
    }

    public static class ConfigApiExtensions
    {
        private static readonly string[] ignoredValueTypeInfoValueNames = new[] { "MinValue", "MaxValue", "StepValue" };
        public static string GetDisplayValue(this Property property)
        {
            var displayValue = property.ValueTypeInfos?.FirstOrDefault(i => i.Value == property.Value && Array.IndexOf(ignoredValueTypeInfoValueNames, i.Name) == -1)?.Name;
            return displayValue ?? property.Value;
        }

        public static Property GetProperty(this ConfigurationItem item, string key)
        {
            return item.Properties.SingleOrDefault(p => Regex.IsMatch(p.Key, $"(^|/){Regex.Escape(key)}(/|$)", RegexOptions.IgnoreCase));
        }

        /// <summary>
        /// Sets the value of the property with the matching key. Supports the use of a partial key
        /// which is useful when updating values for three-part keys used in device settings.
        /// Note: Will throw an exception if more than one property is found with a key matching
        /// the provided key name.
        /// </summary>
        /// <param name="item"></param>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <returns>The updated Property or null if no matching property found.</returns>
        public static Property SetProperty(this ConfigurationItem item, string key, string value)
        {
            var property = item.Properties.SingleOrDefault(p => Regex.IsMatch(p.Key, $"(^|/){Regex.Escape(key)}(/|$)", RegexOptions.IgnoreCase));
            if (property == null)
            {
                return null;
            }
            property.Value = value;
            return property;
        }

        public static string GetResolvedValue(this Property property, string value)
        {
            if (property.ValueType != ValueTypes.EnumType)
            {
                return value;
            }
            var valueTypeInfo = property.ValueTypeInfos.SingleOrDefault(info =>
                info.Value.Equals(value, StringComparison.OrdinalIgnoreCase) || info.Name.Equals(value, StringComparison.OrdinalIgnoreCase));
            return valueTypeInfo?.Value ?? value;
        }

        public static IEnumerable<ErrorRecord> GetValidationErrors(this ValidateResult result)
        {
            if (!result.ValidatedOk)
            {
                foreach (var error in result.ErrorResults)
                {
                    yield return new ErrorRecord(new VmsValidateResultException(error), error.ErrorText, ErrorCategory.InvalidResult, result.ResultItem);                        
                }
            }
        }
    }

    [Serializable]
    public class VmsValidateResultException : Exception
    {
        public ErrorResult ErrorResult { get; private set; }

        public VmsValidateResultException() { }

        public VmsValidateResultException(string message) : base(message) { }

        public VmsValidateResultException(ErrorResult result) : base(result.ErrorText)
        {
            ErrorResult = result;
        }

        public VmsValidateResultException(string message, Exception innerException) : base(message, innerException) { }

        protected VmsValidateResultException(SerializationInfo info, StreamingContext context) : base(info, context) { }
    }
}

