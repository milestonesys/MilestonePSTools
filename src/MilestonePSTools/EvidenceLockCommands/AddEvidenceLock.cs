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
using System.Linq;
using System.Management.Automation;
using VideoOS.Common.Proxy.Server.WCF;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.EvidenceLockCommands
{
    [Cmdlet(VerbsCommon.Add, "EvidenceLock")]
    [OutputType(typeof(MarkedDataResult))]
    [RequiresVmsConnection()]
    [RequiresVmsFeature("EvidenceLock")]
    public class AddEvidenceLock : ConfigApiCmdlet
    {
        [Parameter(Mandatory = true)]
        public string Header { get; set; }
        
        [Parameter]
        public string Description { get; set; }

        [Parameter]
        public Guid[] CameraIds { get; set; } = new Guid[0];

        [Parameter]
        public Guid[] DeviceIds { get; set; }

        [Parameter]
        public SwitchParameter IncludeRelatedDevices { get; set; }

        [Parameter(Mandatory = true)]
        public DateTime FootageFrom { get; set; }
        
        [Parameter(Mandatory = true)]
        public DateTime FootageTo { get; set; }

        [Parameter]
        public DateTime? ExpireDate { get; set; }

        [Parameter]
        [ValidateSet(validValues:new []{"Indefinite", "UserDefined"}, IgnoreCase = false)]
        public string RetentionType { get; set; }

        protected override void ProcessRecord()
        {
            FootageFrom = FootageFrom.ToUniversalTime();
            FootageTo = FootageTo.ToUniversalTime();
            ExpireDate = ExpireDate?.ToUniversalTime();

            var deviceIds = BuildDeviceIdArray();
            var retentionOption = GetRetentionOptionBasedOnParameters();
            var client = ServerCommandService;
            var reference = client.MarkedDataGetNewReference(CurrentToken, CameraIds, true);
            var result = client.MarkedDataCreate(
                CurrentToken,
                Guid.NewGuid(),
                deviceIds,
                FootageFrom,
                FootageFrom,
                FootageTo,
                reference.Reference,
                Header,
                Description,
                2,
                true,
                ExpireDate.Value,
                retentionOption
            );
            if (result.Status != ResultStatus.Success)
            {
                foreach (var deviceResult in result.FaultDevices)
                {
                    WriteError(
                        new ErrorRecord(
                            new ApplicationException($"{result.Status}: Device '{deviceResult.DeviceId}', Message: {deviceResult.Message}"),
                            deviceResult.Message,
                            ErrorCategory.InvalidOperation,
                            null));
                }
            }
            WriteObject(result);
        }

        private Guid[] BuildDeviceIdArray()
        {
            var result = new List<Guid>();
            foreach (var cameraId in CameraIds)
            {
                if (result.Contains(cameraId)) continue;
                result.Add(cameraId);
                if (!IncludeRelatedDevices) continue;
                var camera = new Camera(Connection.CurrentSite.FQID.ServerId, $"Camera[{cameraId}]");
                var relatedItemPaths = camera.ClientSettingsFolder.ClientSettings.First().Related.Split(new []{','}, StringSplitOptions.RemoveEmptyEntries);
                foreach (var relatedItemPath in relatedItemPaths)
                {
                    var id = ConfigurationService.GetItem(relatedItemPath).Properties.SingleOrDefault(p => p.Key == "Id")?.Value;
                    if (id == null) continue;
                    var guid = new Guid(id);
                    if (!result.Contains(guid))
                        result.Add(guid);
                }             
            }

            if (DeviceIds != null)
            {
                foreach (var deviceId in DeviceIds)
                {
                    if (!result.Contains(deviceId))
                        result.Add(deviceId);
                }
            }
            
            return result.ToArray();
        }

        private RetentionOption GetRetentionOptionBasedOnParameters()
        {
            if (!ExpireDate.HasValue)
            {
                ExpireDate = DateTime.MaxValue;
                RetentionType = "Indefinite";
            }
            else
            {
                RetentionType = "UserDefined";
            }

            return new RetentionOption
            {
                RetentionOptionType = (RetentionOptionType) Enum.Parse(typeof(RetentionOptionType), RetentionType),
                RetentionUnits = -1,
            };
        }
    }
}

