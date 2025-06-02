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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using VideoOS.Platform;

namespace MilestonePSTools.Utility
{
    public class KindArgumentCompleter : IArgumentCompleter
    {
        /// <summary>
        /// Complete the argument for VideoOS.Platform.Kind parameters.
        /// </summary>
        /// <param name="commandName">The name of the command that needs argument completion.</param>
        /// <param name="parameterName">The name of the parameter that needs argument completion.</param>
        /// <param name="wordToComplete">The (possibly empty) word being completed.</param>
        /// <param name="commandAst">The command AST in case it is needed for completion.</param>
        /// <param name="fakeBoundParameters">This parameter is similar to $PSBoundParameters, except that sometimes PowerShell cannot or will not attempt to evaluate an argument, in which case you may need to use commandAst.</param>
        /// <returns>A collection of completion results, most like <see cref="CompletionResult"/>.</returns>
        public IEnumerable<CompletionResult> CompleteArgument(string commandName, string parameterName, string wordToComplete, CommandAst commandAst, IDictionary fakeBoundParameters)
        {
            var results = new List<CompletionResult>();
            var kindType = typeof(Kind);
            var kindProperties = kindType.GetFields(System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public).Where(p => p.FieldType == typeof(Guid)).ToArray();
            foreach (var property in kindProperties)
            {
                if (string.IsNullOrEmpty(wordToComplete) || property.Name.StartsWith(wordToComplete.Trim('\'', '\"'), StringComparison.OrdinalIgnoreCase))
                {
                    results.Add(new CompletionResult(
                        completionText: WrapWithQuotesIfNeeded(property.Name),
                        listItemText: property.Name,
                        resultType: CompletionResultType.ParameterValue,
                        toolTip: $"Kind: {property.Name}"
                    ));
                }
            }
            return results.OrderBy(r => r.CompletionText);
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