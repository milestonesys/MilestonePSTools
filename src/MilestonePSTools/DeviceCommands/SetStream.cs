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

using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools.DeviceCommands
{
    [Cmdlet(VerbsCommon.Set, "Stream")]
    [RequiresVmsConnection()]
    public class SetStream : ConfigApiCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public StreamUsageChildItem Stream { get; set; }

        [Parameter(Position = 1)]
        public string StreamId { get; set; }

        [Parameter(Position = 2)]
        public string Name { get; set; }

        [Parameter(Position = 3)]
        public string LiveMode { get; set; }

        [Parameter(Position = 4)]
        public SwitchParameter LiveDefault { get; set; }

        [Parameter(Position = 5)]
        public SwitchParameter Record { get; set; }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            // Deprecated on 2022-01-18
            WriteWarning("Set-Stream is now deprecated. Please consider using Set-VmsCameraStream instead.");
            var camera = new Camera(Connection.CurrentSite.FQID.ServerId, Stream.ParentItemPath);
            var folder = camera.StreamFolder;
            var definition = folder.Streams.First();
            var setting = definition.StreamUsageChildItems.Single(c => c.StreamReferenceId == Stream.StreamReferenceId);

            setting.StreamReferenceId = StreamId ?? Stream?.StreamReferenceId ?? setting.StreamReferenceId;
            setting.Name = Name ?? Stream?.Name ?? setting.Name;
            setting.LiveMode = LiveMode ?? Stream?.LiveMode ?? setting.LiveMode;

            if (LiveDefault.IsPresent || Stream?.LiveDefault == true)
            {
                setting.LiveDefault = true;
                foreach (var item in definition.StreamUsageChildItems.Where(c => c.StreamReferenceId != Stream.StreamReferenceId))
                {
                    item.LiveDefault = false;
                }
            }

            if (Record.IsPresent || Stream?.Record == true)
            {
                setting.Record = true;
                foreach (var item in definition.StreamUsageChildItems.Where(c => c.StreamReferenceId != Stream.StreamReferenceId))
                {
                    item.Record = false;
                }
            }

            try
            {
                definition.Save();
            }
            catch (ValidateResultException validateResult)
            {
                foreach (var errorResult in validateResult.ValidateResult.ErrorResults)
                {
                    WriteError(new ErrorRecord(validateResult, errorResult.ErrorText, ErrorCategory.InvalidData, setting));
                }
            }
        }
    }
}

