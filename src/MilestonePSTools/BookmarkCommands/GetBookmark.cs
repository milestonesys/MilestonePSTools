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
    /// <para type="synopsis">Gets one or more bookmarks based on the supplied parameters</para>
    /// <para type="description">Gets all bookmarks matching the supplied parameters. If there is any
    /// overlap between the timespan represented by the StartTime and EndTime parameters, and the
    /// timespan represented by the TimeBegin and TimeEnd properties of the Bookmarks themselves, the
    /// Bookmarks will be included in the results.
    ///
    /// Since a Bookmark usually has a "Time Triggered" as well as a short timespan before and after
    /// the trigger time, this means your Bookmark search may return Bookmarks which have a "TimeTrigged"
    /// value which falls outside the bounds of the StartTime and EndTime parameters, but their TimeBegin
    /// or TimeEnd timestamps do fall within the specified time period.</para>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -DeviceId $id -StartTime (Get-Date).Date.ToUniversalTime()</code>
    ///     <para>Get all bookmarks for device with ID $id occurring any time during the current day.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -StartTime ([DateTime]::UtcNow).AddHours(-2)</code>
    ///     <para>Get all bookmarks for any device where the bookmark time is in the last two hours.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -StartTime (Get-Date).Date.ToUniversalTime().AddDays(-1) -EndTime (Get-Date).Date.ToUniversalTime()</code>
    ///     <para>Get all bookmarks for the previous day.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -StartTime ([DateTime]::MinValue) -SearchText "Auto"</code>
    ///     <para>Get all bookmarks with the word "Auto" occuring in the Header or Description properties.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(Bookmark))]
    [OutputType(typeof(Bookmark))]
    [RequiresVmsConnection()]
    public class GetBookmark : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Optional device ID to filter the results on.</para>
        /// </summary>
        [Parameter(Position = 1)]
        public Guid[] DeviceId { get; set; }

        /// <summary>
        /// <para type="description">UTC time representing the start of the bookmark search period. Default is 24 hours ago.</para>
        /// </summary>
        [Parameter(Position = 2)] 
        public DateTime StartTime { get; set; } = DateTime.UtcNow - TimeSpan.FromDays(1);

        /// <summary>
        /// <para type="description">UTC time representing the end of the bookmark search period. Default is "now".</para>
        /// </summary>
        [Parameter] 
        public DateTime EndTime { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// <para type="description">A larger page size may result in a longer wait for the first set of results, but overall shorter processing time. Default is 1000.</para>
        /// </summary>
        [Parameter]
        public int PageSize { get; set; } = 1000;

        /// <summary>
        /// <para type="description">List of users to filter the search on. Users are typically searched using the format domain\username.</para>
        /// </summary>
        [Parameter]
        public string[] Users { get; set; }

        /// <summary>
        /// <para type="description">Search the header or description for the bookmarks in the defined time period for a keyword or phrase.</para>
        /// </summary>
        [Parameter]
        public string SearchText { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            StartTime = StartTime.ToUniversalTime();
            EndTime = EndTime.ToUniversalTime();
            var time = StartTime;
            do
            {
                var timeLimit = new TimeDuration {MicroSeconds = (EndTime - time).Ticks / (TimeSpan.TicksPerMillisecond / 1000) };
                WriteVerbose($"Searching for bookmarks from {time} to {EndTime}");
                var results = ServerCommandService.BookmarkSearchTime(
                    CurrentToken,
                    time,
                    timeLimit,
                    PageSize,
                    new[] { MediaDeviceType.Camera, MediaDeviceType.Microphone, MediaDeviceType.Speaker },
                    DeviceId ?? new Guid[0],
                    Users ?? new string[0],
                    SearchText ?? string.Empty);
                
                Bookmark lastBookmark = null;
                foreach (var bookmark in results)
                {
                    lastBookmark = bookmark;
                    WriteObject(bookmark);
                }

                if (results.Length < PageSize)
                {
                    break;
                }
                time = lastBookmark?.TimeEnd.AddTicks(1) ?? EndTime;
            } while (time < EndTime);
        }
    }
}

