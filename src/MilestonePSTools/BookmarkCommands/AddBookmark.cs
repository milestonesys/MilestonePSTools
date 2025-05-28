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

namespace MilestonePSTools.BookmarkCommands
{
    /// <summary>
    /// <para type="synopsis">Adds a new bookmark to the timeline for a given device.</para>
    /// <para type="description">The Add-Bookmark cmdlet adds a new bookmark to the timeline for a given device.
    /// The bookmark can later be found by time, name or description, and is represented by a visual marker in the
    /// timeline for the given device in playback within XProtect Smart Client and any other integration using the timeline UI component.</para>
    /// <example>
    ///     <code>C:\PS>Add-Bookmark -DeviceId $id -Timestamp '2019-06-04 14:00:00'</code>
    ///     <para>Add a bookmark for device with a GUID ID value stored in the variable $id, using a local timestamp of 2PM on the 4th of June, 2019, based on the culture of the PowerShell session.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Add-Bookmark -DeviceId $id -Timestamp '2019-06-04 14:00:00Z'</code>
    ///     <para>Add a bookmark for device with a GUID ID value stored in the variable $id, using a UTC timestamp of 2PM UTC on the 4th of June, 2019</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-Hardware | Get-VmsCamera | ? Name -Like '*Elevator*' | % { Add-Bookmark -DeviceId $_.Id -Timestamp '2019-06-04 14:00:00' -Header 'Vandalism' }</code>
    ///     <para>Find all cameras with the case-insensitive string 'Elevator' in the name, and add a bookmark for those cameras at 2PM on June 4th, or 21:00 UTC if the location where the script is executed has a UTC offset of -7.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Add, nameof(Bookmark))]
    [OutputType(typeof(Bookmark))]
    [RequiresVmsConnection()]
    public class AddBookmark : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">GUID based identifier of the device for which the bookmark should be created.</para>
        /// </summary>
        [Parameter(Position = 1)]
        public Guid DeviceId { get; set; }

        /// <summary>
        /// <para type="description">Timestamp of the event which should be bookmarked. Value can be a string, and it will be parsed into a DateTime object. Default is the current time.</para>
        /// <para type="description">Note: The event will be stored with a UTC timestamp on the Management Server. Supplying a DateTime string can be finicky - it is recommended to thoroughly test any scripts to ensure it results in a bookmark at the expected place in the timeline.</para>
        /// </summary>
        [Parameter(Position = 2, Mandatory = true)]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// <para type="description">Specifies the time in seconds before, and after the value of Timestamp, which should be considered a part of this bookmark event.</para>
        /// </summary>
        [Parameter(Position = 3)]
        public int MarginSeconds { get; set; } = 10;

        /// <summary>
        /// <para type="description">Specifies a reference string for the bookmark. The default value will be a string retrieved from the Management Server using the BookmarkGetNewReference() method which returns a string like 'no.016735'. The value does not need to be unique.</para>
        /// </summary>
        [Parameter(Position = 4)]
        [ValidateNotNullOrEmpty]
        public string Reference { get; set; }

        /// <summary>
        /// <para type="description">Specifies the header, or title of the bookmark. It is helpful to supply a header or description to add context to the bookmark. The default value is 'Created &lt;timestamp&gt;'</para>
        /// </summary>
        [Parameter(Position = 5)]
        public string Header { get; set; } = $"Created {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss.fffZ}";

        /// <summary>
        /// <para type="description">Specifies the description of the bookmark. It is helpful to supply a header or description to add context to the bookmark. The default value is 'Created by MilestonePSTools'</para>
        /// </summary>
        [Parameter(Position = 6)]
        public string Description { get; set; } = "Created by MilestonePSTools";

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            Timestamp = Timestamp.ToUniversalTime();
            var reference = string.IsNullOrWhiteSpace(Reference)
                ? (ServerCommandService.BookmarkGetNewReference(CurrentToken, DeviceId, true)).Reference
                : Reference;
            var bookmark = ServerCommandService.BookmarkCreate(
                CurrentToken,
                DeviceId,
                Timestamp - TimeSpan.FromSeconds(MarginSeconds),
                Timestamp,
                Timestamp + TimeSpan.FromSeconds(MarginSeconds),
                reference,
                Header,
                Description);

            WriteObject(bookmark);
        }
    }
}

