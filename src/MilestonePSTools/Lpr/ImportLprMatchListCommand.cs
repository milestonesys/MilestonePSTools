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

using CsvHelper;
using MilestonePSTools.Connection;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Lpr
{
    [Cmdlet(VerbsData.Import, "VmsLprMatchList", SupportsShouldProcess = true)]
    [RequiresVmsConnection()]
    [OutputType(typeof(LprMatchList))]
    public class ImportLprMatchListCommand : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipelineByPropertyName = true, ParameterSetName = nameof(Path))]
        public string[] Path { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = nameof(LiteralPath))]
        public string[] LiteralPath { get; set; }

        [Parameter()]
        public SwitchParameter Append { get; set; }

        private readonly string[] _requiredHeaders = new string[] { "MatchList", "RegistrationNumber" };

        private readonly Hashtable _lists = new Hashtable(StringComparer.InvariantCultureIgnoreCase);
        private readonly Dictionary<LprMatchList, Dictionary<string, bool>> _results = new Dictionary<LprMatchList, Dictionary<string, bool>>();

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            Connection.ManagementServer.LprMatchListFolder?.ClearChildrenCache();
        }
        protected override void ProcessRecord()
        {
            if (ParameterSetName == nameof(Path))
            {
                LiteralPath = Path.SelectMany(p => GetResolvedProviderPathFromPSPath(p, out var provider)).ToArray();
            }

            foreach (var path in LiteralPath)
            {
                try
                {
                    using (var reader = new StreamReader(path))
                    using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
                    {
                        while (csv.Read())
                        {
                            if (!csv.GetField(0).StartsWith("#"))
                            {
                                break;
                            }
                        }
                        csv.ReadHeader();

                        // Validate headers

                        if (csv.HeaderRecord == null)
                        {
                            throw new FormatException("No header found in CSV file. A header must be defined with at least MatchList and RegistrationNumber columns.");
                            
                        }
                        foreach (var header in _requiredHeaders)
                        {
                            if (!csv.HeaderRecord.Any(h => h.Equals(header, StringComparison.InvariantCultureIgnoreCase)))
                            {
                                throw new FormatException($"Required header \"{header}\" not found. A header must be defined with at least MatchList and RegistrationNumber columns.");
                            }
                        }

                        // Build list of custom fields from CSV file
                        var customFields = csv.HeaderRecord.Where(h => !_requiredHeaders.Any(rh => rh.Equals(h, StringComparison.InvariantCultureIgnoreCase)));

                        LprMatchList list;
                        while (csv.Read())
                        {
                            var listName = csv.GetField("MatchList");
                            var registrationNumber = csv.GetField("RegistrationNumber");

                            list = (LprMatchList)_lists[listName];
                            if (list == null && ShouldProcess(listName, $"Get or create match list"))
                            {
                                list = GetMatchList(listName, true);
                                if (!Append)
                                {
                                    list.Reset();
                                }
                                list.AppendCustomFields(customFields);
                                _lists.Add(listName, list);
                            }
                            var customFieldsHashTable = new Hashtable(StringComparer.InvariantCultureIgnoreCase);
                            foreach (var fieldName in customFields)
                            {
                                customFieldsHashTable.Add(fieldName, csv.GetField(fieldName));
                            }
                            if (ShouldProcess(listName, $"Add or update registration number {registrationNumber}"))
                            {
                                list.AddOrUpdateRegistrationNumber(registrationNumber, customFieldsHashTable);
                                if (!_results.ContainsKey(list))
                                {
                                    _results.Add(list, new Dictionary<string, bool>());
                                }
                                _results[list][registrationNumber] = true;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    switch (ex.GetType().Name)
                    {
                        case nameof(FormatException):
                            WriteError(
                                new ErrorRecord(ex, "HeaderNotFound", ErrorCategory.InvalidData, path));
                            break;
                        default:
                            throw;
                    }
                }
            }
        }

        protected override void EndProcessing()
        {
            Connection.ManagementServer.LprMatchListFolder?.ClearChildrenCache();
            var lists = _results.Keys.ToList();
            for (int i = 0; i < _results.Count; i++)
            {
                var updatedList = lists[i].Refresh();
                foreach (var registrationNumber in _results[lists[i]].Keys)
                {
                    WriteObject(updatedList.GetRegistrationNumber(registrationNumber));
                }
            }
        }

        private LprMatchList GetMatchList(string name, bool create = false)
        {
            var list = MilestoneConnection.Instance.ManagementServer.LprMatchListFolder?.LprMatchLists.FirstOrDefault(l => l.Name.Equals(name, StringComparison.CurrentCultureIgnoreCase));
            if (list != null)
            {
                return list;
            }
            if (create)
            {
                return CreateLprMatchList(name, true);
            }
            throw new ItemNotFoundException($"LprMatchList {name} not found.");
        }

        private LprMatchList CreateLprMatchList(string name, bool returnInstance)
        {
            var task = MilestoneConnection.Instance.ManagementServer.LprMatchListFolder?.MethodIdAddLprMatchList(name);
            return returnInstance ? GetMatchListByPath(task.Path) : null;
        }

        private LprMatchList GetMatchListByPath(string path)
        {
            return new LprMatchList(MilestoneConnection.Instance.CurrentSite.FQID.ServerId, path);
        }
    }

    public static class LprExtensions {
        public static LprMatchList Reset(this LprMatchList list)
        {
            list.CustomFieldsList = new string[0];
            list.Save();
            list.MethodIdDeleteAllRegistrationNumbers();
            return list;
        }

        public static LprMatchList AppendCustomFields(this LprMatchList list, IEnumerable<string> fields)
        {
            list.CustomFieldsList = list.CustomFieldsList.AsQueryable().Union(fields, StringComparer.InvariantCultureIgnoreCase).ToArray();
            list.Save();
            return list;
        }

        public static void AddOrUpdateRegistrationNumber(this LprMatchList list, string registrationNumber, Hashtable customFields)
        {
            var existingEntry = list.GetRegistrationNumber(registrationNumber);
            if (existingEntry != null)
            {
                // Make sure we use the exact same case for registration number characters as the VMS is case sensitive.
                // We'll update the existing record if one exists based on case-insensitive comparison.
                registrationNumber = existingEntry.RegistrationNumber;
            }

            var fieldValues = list.CustomFieldsList.Select(f => customFields[f]?.ToString() ?? existingEntry?.CustomFields[f] ?? string.Empty);
            var sb = new StringBuilder(registrationNumber);
            foreach (var value in fieldValues)
            {
                sb.Append($",{value}");
            }
            list.MethodIdAddOrEditRegistrationNumbersInfo(sb.ToString());
        }

        public static IEnumerable<LprMatchListEntry> GetRegistrationNumbers(this LprMatchList list)
        {
            foreach (var registrationNumber in list.RegistrationNumbersList)
            {
                yield return list.GetRegistrationNumber(registrationNumber);
            }
        }

        public static LprMatchListEntry GetRegistrationNumber(this LprMatchList list, string registrationNumber)
        {
            var caseSensitiveRegistrationNumber = list.RegistrationNumbersList.FirstOrDefault(record => record.Equals(registrationNumber, StringComparison.InvariantCultureIgnoreCase));
            if (caseSensitiveRegistrationNumber == null) return null;

            var fieldNames = list.CustomFieldsList.ToList();
            var fieldValues = list.MethodIdGetCustomFieldsForRegistrationNumberWithResult(caseSensitiveRegistrationNumber).CustomFields.ToList();
            
            var customFields = new Dictionary<string, string>();
            for ( var i = 0; i < fieldNames.Count; i++)
            {
                customFields.Add(fieldNames[i], fieldValues[i]);
            }
            return new LprMatchListEntry
            {
                MatchList = list,
                RegistrationNumber = caseSensitiveRegistrationNumber,
                CustomFields = customFields
            };
        }

        public static LprMatchList Refresh (this LprMatchList list)
        {
            return new LprMatchList(list.ServerId, list.Path);
        }
    }

    public class LprMatchListEntry
    {
        public LprMatchList MatchList { get; set; }
        public string RegistrationNumber { get; set; }
        public Dictionary<string, string> CustomFields { get; set; }
    }
}

