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
using System.Linq;
using System.Management.Automation;
using VideoOS.Platform;
using VideoOS.Platform.Data;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Generates a partially filled Alarm object to be sent using Send-Alarm.</para>
    /// <para type="description">The partially completed Alarm object can be modified as needed before sending to the Event Server with the Send-Alarm cmdlet.</para>
    /// <example>
    ///     <code>
    /// PS C:\> $cameraItem = Get-VmsCamera -Id 948aa6a2-9a46-4c4c-8279-af0485428d75 | Get-PlatformItem
    /// PS C:\> $alarm = New-Alarm -Message "Important Alarm Message" -Source $cameraItem
    /// PS C:\> $alarm | Send-Alarm</code>
    ///     <para>Retrieves the Item object for Camera with the given Id and creates an Alarm with this camera as the source.</para>
    ///     <para>The Alarm object is then sent to the Event Server which generates a new alarm.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.New, nameof(Alarm))]
    [OutputType(typeof(Alarm))]
    [RequiresVmsConnection(false)]
    public class NewAlarm : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the alarm message</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string Message { get; set; } = "MilestonePSTools Default Alarm Message";

        /// <summary>
        /// <para type="description">Specifies the detailed description of the alarm. This appears in the XProtect Smart Client under the alarm's Instructions field.</para>
        /// </summary>
        [Parameter()]
        public string Description { get; set; }

        /// <summary>
        /// <para type="description">Specifies the Alarm.EventHeader.CustomTag value which could be used later for searching or filtering in calls to Get-AlarmLines.</para>
        /// </summary>
        [Parameter()]
        public string CustomTag { get; set; }

        /// <summary>
        /// <para type="description">Specifies an alarm source to automatically fill in the Alarm.EventHeader.Source property.</para>
        /// <para type="description">To get an Item object, try passing a Camera or Input object for example into the Get-PlatformItem cmdlet.</para>
        /// <para type="description">Alternatively you can construct your own Item. All you need is the FQID property to contain a ServerId, ObjectId and Kind.</para>
        /// </summary>
        [Parameter()]
        public Item Source { get; set; }

        /// <summary>
        /// <para type="description">Specifies one or more items such as cameras as references or related items so that video from all related cameras is associated with the alarm.</para>
        /// <para type="description">To get an Item object, try passing a Camera or Input object for example into the Get-PlatformItem cmdlet.</para>
        /// <para type="description">Alternatively you can construct your own Item. All you need is the FQID property to contain a ServerId, ObjectId and Kind.</para>
        /// </summary>
        [Parameter()]
        public Item[] RelatedItems { get; set; }

        /// <summary>
        /// <para type="description">Specifies a vendor name as the source for the alarm. Default is MilestonePSTools.</para>
        /// </summary>
        [Parameter()]
        public string Vendor { get; set; } = "MilestonePSTools";

        /// <summary>
        /// <para type="description">Specifies the timestamp associated with the alarm.</para>
        /// <para type="description">Default is DateTime.UtcNow. All DateTimes will be converted to UTC time automatically if needed.</para>
        /// </summary>
        [Parameter()]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            var referenceList = new ReferenceList();
            if (RelatedItems?.Length > 0)
            {
                referenceList.AddRange(RelatedItems.Select(ri => new Reference { FQID = ri.FQID }));
            }

            WriteObject(new Alarm
            {
                EventHeader = new EventHeader {
                    ID = Guid.NewGuid(),
                    Timestamp = Timestamp.ToUniversalTime(),
                    Message = Message,
                    CustomTag = CustomTag,
                    Source = new EventSource {
                        FQID = Source?.FQID ?? new FQID {
                            ServerId = Connection.CurrentSite.FQID.ServerId
                        }
                    }
                },
                Description = Description,
                ObjectList = new AnalyticsObjectList(),
                ReferenceList = referenceList,
                RuleList = new RuleList(),
                SnapshotList = new SnapshotList(),
                Vendor = new Vendor() { Name = Vendor},
                StartTime = Timestamp,
                EndTime = Timestamp
            });
        }
    }
}

