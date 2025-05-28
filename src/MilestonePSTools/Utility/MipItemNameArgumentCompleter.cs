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

namespace MilestonePSTools.Utility
{
    public class MipItemTransformationAttribute : ArgumentTransformationAttribute
    {
        private readonly Type _type;
        private readonly string _propertyName;
        private readonly Operator _operator;

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
                if (!_type.IsAssignableFrom(typeof(IEnumerable<object>)))
                {
                    throw new ArgumentException($"Expected a single object but received multiple objects instead.");
                }
                return (objArray.Select(obj => ResolveMipItem(obj)));
            }
            return ResolveMipItem(inputData);
        }

        private object ResolveMipItem(object inputData)
        {
            var inputType = inputData.GetType();
            if (_type.IsAssignableFrom(inputType))
            {
                return inputData;
            }
            if (typeof(string).IsAssignableFrom(inputType))
            {
                var inputString = (string)inputData;
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
            throw new ArgumentException($"Unable to convert object of type {inputType.FullName} to {_type.FullName}.");
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

            foreach (var item in queryService.Query(filter, int.MaxValue))
            {
                var completion = prop.GetValue(item)?.ToString();
                if (completion == null) continue;

                if (wordToComplete == string.Empty)
                {
                    yield return new CompletionResult(WrapWithQuotesIfNeeded(completion));
                }
                else if (item.Name.StartsWith(wordToComplete, StringComparison.CurrentCultureIgnoreCase))
                {
                    yield return new CompletionResult(WrapWithQuotesIfNeeded(completion));
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


    /// <summary>
    /// Argument completer for the ID property of any MIP item of type T
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class MipItemIdCompleter<T> : MipItemNameCompleter<T>
    {
        public MipItemIdCompleter()
        {
            Property = "Id";
        }
    }
}

