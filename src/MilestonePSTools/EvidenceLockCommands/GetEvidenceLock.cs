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
using System.Management.Automation;
using VideoOS.Common.Proxy.Server.WCF;

namespace MilestonePSTools.EvidenceLockCommands
{
    [Cmdlet(VerbsCommon.Get, "EvidenceLock")]
    [OutputType(typeof(MarkedData))]
    [RequiresVmsConnection()]
    [RequiresVmsFeature("EvidenceLock")]
    public class GetEvidenceLock : ConfigApiCmdlet
    {
        [Parameter]
        public Guid[] DeviceIds { get; set; } = new Guid[0];

        [Parameter]
        public string SearchText { get; set; }

        [Parameter]
        public string[] Users { get; set; } = new string[0];

        [Parameter]
        public DateTime CreatedFrom { get; set; } = DateTime.MinValue;

        [Parameter]
        public DateTime CreatedTo { get; set; } = DateTime.MaxValue;

        [Parameter]
        public DateTime FootageFrom { get; set; } = DateTime.MinValue;

        [Parameter]
        public DateTime FootageTo { get; set; } = DateTime.MaxValue;

        [Parameter]
        public DateTime ExpireFrom { get; set; } = DateTime.MinValue;

        [Parameter]
        public DateTime ExpireTo { get; set; } = DateTime.MaxValue;

        [Parameter]
        public int PageSize { get; set; } = 100;

        [Parameter]
        [ValidateSet(
            validValues: new[] {
                "CreateTime",
                "Description",
                "EndTime",
                "Header",
                "RetentionExpireTime",
                "Size",
                "StartTime",
                "TagTime",
                "UserName"},
            IgnoreCase = false)]
        public string SortBy { get; set; } = "CreateTime";

        [Parameter]
        public SwitchParameter SortDecending { get; set; }

        protected override void ProcessRecord()
        {
            var client = ServerCommandService;
            var sortOption = (SortOrderOption)Enum.Parse(typeof(SortOrderOption), SortBy);
            var currentPage = 0;
            MarkedData[] result = null;
            do
            {
                for (int errors = 0; errors < 2; errors++)
                {
                    try
                    {
                        result = client.MarkedDataSearch(
                                                CurrentToken,
                                                DeviceIds,
                                                SearchText,
                                                Users,
                                                CreatedFrom,
                                                CreatedTo,
                                                FootageFrom,
                                                FootageTo,
                                                DateTime.MinValue,
                                                DateTime.MaxValue,
                                                ExpireFrom,
                                                ExpireTo,
                                                currentPage++,
                                                PageSize,
                                                sortOption,
                                                !SortDecending);
                        foreach (var evidenceLock in result)
                        {
                            WriteObject(evidenceLock);
                        }
                    }
                    catch (System.ServiceModel.CommunicationException)
                    {
                        if (errors > 0)
                        {
                            throw;
                        }
                        WriteVerbose($"Get-EvidenceLock threw a CommunicationException. The operation will be retried after clearing the proxy client cache.");
                        ClearProxyClientCache();
                        client = ServerCommandService;
                    }
                }
            } while (result?.Length == PageSize);
        }
    }
}

