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

using MilestonePSTools.Helpers;
using System;
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.EventCommands
{
    [Cmdlet(VerbsCommon.Add, nameof(GenericEvent))]
    [OutputType(typeof(GenericEvent))]
    [RequiresVmsConnection()]
    public class AddGenericEvent : ConfigApiCmdlet
    {
        [Parameter(Position = 1, Mandatory = true)]
        public string Name { get; set; }

        [Parameter(Position = 2, Mandatory = true)]
        public string Expression { get; set; }

        [Parameter(Position = 3)]
        [ValidateSet("Search", "Match", "Regex", IgnoreCase = true)]
        public string ExpressionType { get; set; } = "Search";

        [Parameter(Position = 4)]
        public int Priority { get; set; } = 1;

        [Parameter(Position = 5)]
        public string DataSourceId { get; set; }

        protected override void ProcessRecord()
        {
            var ms = Connection.ManagementServer;

            DataSourceId = DataSourceId ??
                         ms.GenericEventDataSourceFolder.GenericEventDataSources.First(ds => ds.Enabled).Path;

            if (Guid.TryParse(DataSourceId, out var id))
            {
                DataSourceId = $"GenericEvent[{id}]";
            }

            var expressionType = ExpressionType.Equals("Search", StringComparison.OrdinalIgnoreCase)
                ? "0"
                : ExpressionType.Equals("Match", StringComparison.OrdinalIgnoreCase)
                    ? "1"
                    : "2";

            var taskHandler = new ServerTaskProgressWriter(
                this,
                ms.GenericEventFolder.AddGenericEvent(
                    Name,
                    DataSourceId,
                    Expression,
                    expressionType,
                    Priority),
                new ProgressRecord(0, "Add-GenericEvent", $"Adding generic event '{Name}'"));

            var result = taskHandler.MonitorProgress();
            if (result.State == StateEnum.Success)
            {
                WriteObject(new GenericEvent(Connection.CurrentSite.FQID.ServerId, result.Path));
            }
            else
            {
                WriteError(
                    new ErrorRecord(
                        new ValidateResultException(),
                        result.ErrorText,
                        ErrorCategory.InvalidData,
                        null));
            }
        }
    }
}

