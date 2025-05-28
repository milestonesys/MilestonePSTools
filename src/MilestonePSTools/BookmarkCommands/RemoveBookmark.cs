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
    /// <para type="synopsis">Removes / deletes a bookmark</para>
    /// <para type="description">Takes a bookmark, or a bookmark ID from the pipeline or parameters, and deletes it.</para>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -DeviceId $id | Remove-Bookmark</code>
    ///     <para>Remove all bookmarks for the last hour of video for device with ID $id</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -Timestamp '2019-06-04 14:00:00' -Minutes 120 | Remove-Bookmark</code>
    ///     <para>Removes all bookmarks for any device where the bookmark time is between 2PM and 4PM local time on the 4th of June.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Remove, nameof(Bookmark))]
    [RequiresVmsConnection()]
    public class RemoveBookmark : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the bookmark object to be deleted.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromBookmark")]
        public Bookmark Bookmark { get; set; }

        /// <summary>
        /// <para type="description">Specifies the ID of the bookmark object to be deleted.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromId")]
        public Guid BookmarkId { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            var id = Bookmark?.Id ?? BookmarkId;
            ServerCommandService.BookmarkDelete(CurrentToken, id);
        }
    }
}
