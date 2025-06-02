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

using MilestonePSTools.Connection;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using System.Text.RegularExpressions;
using VideoOS.ConfigurationApi.ClientService;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Utility
{
    public class MipItemTransformationAttribute : ArgumentTransformationAttribute
    {
        private readonly Type _type;
        private readonly string _propertyName;
        private readonly Operator _operator;

        
        /// <summary>
        /// Transform an incoming string value into a designated <paramref name="type"/> from the
        /// VideoOS.Platform.ConfigurationItems namespace by matching the
        /// string to an item by name.
        /// </summary>
        /// <param name="type">A type from the VideoOS.Platform.ConfigurationItems namespace</param>
        public MipItemTransformationAttribute(Type type)
        {
            _type = type;
            _propertyName = "Name";
            _operator = Operator.Equals;
        }

        /// <summary>
        /// Transform an incoming string value into a designated <paramref name="type"/> from the
        /// VideoOS.Platform.ConfigurationItems namespace by matching the
        /// string to an item based on the provided <paramref name="propertyName"/>.
        /// </summary>
        /// <param name="type">A type from the VideoOS.Platform.ConfigurationItems namespace</param>
        /// <param name="propertyName">The name of a property to match the incoming string value with</param>
        public MipItemTransformationAttribute(Type type, string propertyName)
        {
            _type = type;
            _propertyName = propertyName;
            _operator = Operator.Equals;
        }

        /// <summary>
        /// Transform an incoming string value into a designated <paramref name="type"/> from the
        /// VideoOS.Platform.ConfigurationItems namespace by matching the
        /// string to an item based on the provided <paramref name="propertyName"/> and <paramref name="comparisonOperator"/>.
        /// </summary>
        /// <param name="type">A type from the VideoOS.Platform.ConfigurationItems namespace</param>
        /// <param name="propertyName">The name of a property to match the incoming string value with</param>
        /// <param name="comparisonOperator"></param>
        public MipItemTransformationAttribute(Type type, string propertyName, Operator comparisonOperator = Operator.Equals)
        {
            _type = type;
            _propertyName = propertyName;
            _operator = comparisonOperator;
        }

        public override object Transform(EngineIntrinsics engineIntrinsics, object inputData)
        {
            if (inputData == null) throw new NullReferenceException($"Unable to process null {_type.Name} value.");
            if (inputData is IEnumerable<object> objArray)
            {
                return objArray.Select(obj => ResolveMipItem(obj));
            }
            else
            {
                return ResolveMipItem(inputData);
            }
        }

        private object ResolveMipItem(object inputData)
        {
            var inputObject = inputData is PSObject psObject ? psObject.BaseObject : inputData;
            var inputType = inputObject.GetType();
            if (_type.IsAssignableFrom(inputType))
            {
                return inputObject;
            }

            if (!typeof(string).IsAssignableFrom(inputType))
            {
                var invalidCastMessage = $"{nameof(MipItemTransformationAttribute)} accepts only {nameof(inputData)} of type [string].";
                var message = $"Expected a value of type [string] or [{_type.FullName}], but received a [{inputType.FullName}].";
                throw new ArgumentTransformationMetadataException(
                    message,
                    new PSInvalidCastException(message));
            }

            // Special handler for emitting time profiles with the expected paths for Always and Default.
            // These are used in the Import-VmsRole command.
            if (_type == typeof(TimeProfile))
            {
                if (inputObject.ToString().Equals("Always", StringComparison.OrdinalIgnoreCase))
                {
                    return new TimeProfile(
                        MilestoneConnection.Instance.ManagementServer.ServerId,
                        new ConfigurationItem
                        {
                            DisplayName = "Always",
                            ItemCategory = "Item",
                            ItemType = "TimeProfile",
                            Path = "TimeProfile[11111111-1111-1111-1111-111111111111]",
                            ParentPath = "/TimeProfileFolder"
                        }
                    );
                }
                else if (inputObject.ToString().Equals("Default", StringComparison.OrdinalIgnoreCase))
                {
                    return new TimeProfile(
                        MilestoneConnection.Instance.ManagementServer.ServerId,
                        new ConfigurationItem
                        {
                            DisplayName = "Default",
                            ItemCategory = "Item",
                            ItemType = "TimeProfile",
                            Path = "TimeProfile[00000000-0000-0000-0000-000000000000]",
                            ParentPath = "/TimeProfileFolder"
                        }
                    );
                }
            }

            var inputString = (string)inputObject;
            var queryService = new QueryItems(MilestoneConnection.Instance.CurrentSite.FQID.ServerId);
            var filter = new ItemFilter(_type.Name, new PropertyFilter[] { new PropertyFilter(_propertyName, _operator, inputString) });
            var result = queryService.Query(filter, int.MaxValue);
            if (result.Count == 0)
            {
                throw new ItemNotFoundException($"{_type.Name} item not found where {_propertyName} {_operator.ToString().ToLower()} \"{inputString}\".");
            }
            if (result.Count > 1)
            {
                throw new ItemNotFoundException($"Ambiguous query result. Multiple {_type.Name} items found where {_propertyName} {_operator.ToString().ToLower()} \"{inputString}\".");
            }

            return result.First();
        }
    }

    /// <summary>
    /// Argument completer for the Name property of any MIP item of type T
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class MipItemNameCompleter<T> : IArgumentCompleter
    {
        private static readonly Regex LeadingQuote = new Regex("^['\"]");
        private static readonly Regex TrailingQuote = new Regex("['\"]$");

        public string Property { get; set; } = "Name";

        public MipItemNameCompleter()
        {
        }

        public IEnumerable<CompletionResult> CompleteArgument(string commandName, string parameterName, string wordToComplete, CommandAst commandAst, IDictionary fakeBoundParameters)
        {
            var queryService = new QueryItems(MilestoneConnection.Instance.CurrentSite.FQID.ServerId);
            var filter = new ItemFilter(typeof(T).Name, new PropertyFilter[] { new PropertyFilter(Property, Operator.Contains, string.Empty) });
            wordToComplete = RemoveQuotes(wordToComplete);
            var prop = typeof(T).GetProperty(Property);
            if (prop == null) yield break;

            foreach (var item in queryService.Query(filter, int.MaxValue).OrderBy(i => prop.GetValue(i)))
            {
                var completion = prop.GetValue(item)?.ToString();
                if (completion == null) continue;

                if (string.IsNullOrEmpty(wordToComplete) || completion.StartsWith(wordToComplete.Trim('\'', '"'), StringComparison.OrdinalIgnoreCase))
                {
                    yield return new CompletionResult(
                            completionText: WrapWithQuotesIfNeeded(completion),
                            listItemText: completion,
                            resultType: CompletionResultType.ParameterValue,
                            toolTip: $"{typeof(T).Name} {Property}: {completion}"
                        );
                }
            }
        }

        private string RemoveQuotes(string wordToComplete)
        {
            return TrailingQuote.Replace(LeadingQuote.Replace(wordToComplete, string.Empty), string.Empty);
        }

        private string WrapWithQuotesIfNeeded(string value)
        {
            if (value.IndexOf(" ") < 0)
            {
                return value;
            }
            else
            {
                return $"'{value}'";
            }
        }
    }
}
