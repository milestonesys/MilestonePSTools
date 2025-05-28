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

using System.Management.Automation;
using VideoOS.Common.Proxy.Server.WCF;

namespace MilestonePSTools.BookmarkCommands
{
    /// <summary>
    /// <para type="synopsis">Updates the properties of a bookmark</para>
    /// <para type="description">Updates a bookmark in the VMS by pushing changes to the bookmark object up to the Management Server.</para>
    /// <para type="description">The expected workflow is that a bookmark is retrieved using Get-Bookmark. Then properties of the local
    /// bookmark object are changed as desired. Finally the modified local bookmark object is used to update the record on the Management
    /// Server by piping it to this cmdlet.</para>
    /// <example>
    ///     <code>C:\PS>Get-Bookmark -Timestamp '2019-06-04 14:00:00' -Minutes 120 | % { $_.Description = 'Testing'; $_ | Update-Bookmark }</code>
    ///     <para>Gets all bookmarks for any device where the bookmark time is between 2PM and 4PM local time on the 4th of June, changes the Description to 'Testing', and sends the updated bookmark to the Management Server.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsData.Update, nameof(Bookmark))]
    [RequiresVmsConnection()]
    public class UpdateBookmark : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the bookmark object to be updated.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true, ParameterSetName = "FromBookmark")]
        public Bookmark Bookmark { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            ServerCommandService.BookmarkUpdate(
                CurrentToken,
                Bookmark.Id,
                Bookmark.DeviceId,
                Bookmark.TimeBegin,
                Bookmark.TimeTrigged,
                Bookmark.TimeEnd,
                Bookmark.Reference,
                Bookmark.Header,
                Bookmark.Description);
        }
    }
}
