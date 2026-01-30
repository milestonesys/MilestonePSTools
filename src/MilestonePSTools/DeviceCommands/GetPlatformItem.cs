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
using System.Management.Automation;
using MilestonePSTools.Utility;
using VideoOS.Platform;

namespace MilestonePSTools.DeviceCommands
{
    /// <summary>
    /// <para type="synopsis">Gets a VideoOS.Platform.Item object representing a configuration item</para>
    /// <para type="description">The Item is a generic object representing a configuration item in the VMS.
    /// An Item might represent a camera, hardware, server, or generic event.
    /// This cmdlet is especially useful for converting an FQID from Get-ItemState into an item, in order
    /// to get the device name faster than possible using Configuration API commands like Get-ConfigurationItem.</para>
    /// <example>
    ///     <code>C:\PS> Get-ItemState | % { $name = ($_.FQID | Get-PlatformItem).Name; "$name - $($_.State)" }</code>
    ///     <para>Retrieve the Item name and write the name and ItemState</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS> Get-PlatformItem -ListAvailable</code>
    ///     <para>Retrieve all configuration items from the VMS which are not considered Parent objects</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS> $kind = (Get-Kind -List | ? DisplayName -eq Transact).Kind; Get-PlatformItem -Kind $kind</code>
    ///     <para>Retrieve all Transact sources configured in the VMS. First we get the GUID associated with 'Kind.Transact'
    ///     then we pass that GUID into the Get-PlatformItem -Kind parameter. You can then inspect the Properties collection
    ///     associated with the returned Items.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "PlatformItem", DefaultParameterSetName = "ByFQID")]
    [OutputType(typeof(Item))]
    [RequiresVmsConnection()]
    public class GetPlatformItem : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">VideoOS.Platform.FQID of a Milestone configuration Item</para>
        /// </summary>
        [Parameter(Position = 1, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, ParameterSetName = "ByFQID")]
        public FQID Fqid { get; set; }

        /// <summary>
        /// <para type="description">Specifies the name or string to search for</para>
        /// </summary>
        [Parameter(Position = 1, ValueFromPipeline = true, ParameterSetName = "BySearch")]
        public string SearchText { get; set; }

        /// <summary>
        /// <para type="description">Specifies the GUID constant for the Kind of object you want to return</para>
        /// </summary>
        [Parameter(Position = 1, ValueFromPipeline = true, ParameterSetName = "ByKind")]
        [ArgumentCompleter(typeof(KindArgumentCompleter))]
        [KindNameTransform()]
        public Guid Kind { get; set; }

        /// <summary>
        /// <para type="description">Enumerate all Items in the configuration</para>
        /// </summary>
        [Parameter(Position = 1, ParameterSetName = "ListAvailable")]
        public SwitchParameter ListAvailable { get; set; }

        /// <summary>
        /// <para type="description">Filter the results based on the system hierarchy, user-defined hierarchies like camera groups, or both.</para>
        /// </summary>
        [Parameter(Position = 1, ParameterSetName = "ListAvailable")]
        public ItemHierarchy Hierarchy { get; set; } = ItemHierarchy.SystemDefined;

        /// <summary>
        /// <para type="description">Only child objects with no child items of their own are included by default. Example: Cameras and user-defined events.</para>
        /// </summary>
        [Parameter(Position = 1, ParameterSetName = "ListAvailable")]
        public SwitchParameter IncludeFolders { get; set; }

        /// <summary>
        /// <para type="description">Specifies the maximum number of results allowed. When
        /// a search returns more than this, it is considered an error. Default = 1</para>
        /// </summary>
        [Parameter(Position = 2, ParameterSetName = "BySearch")]
        public int MaxResultCount { get; set; } = 1;

        /// <summary>
        /// <para type="description">Specifies the timeout in seconds before a search is
        /// terminated. Default = 60 seconds</para>
        /// </summary>
        [Parameter(Position = 3, ParameterSetName = "BySearch")]
        public int TimeoutSeconds { get; set; } = 60;

        /// <summary>
        /// <para type="description">Specifies the Guid identifier for an item</para>
        /// <para type="description">Use only when you have an ID but no knowledge of the device type.</para>
        /// </summary>
        [Parameter(Position = 1, ParameterSetName = "ById")]
        [Alias("ObjectId")]
        public Guid Id { get; set; }

        /// <summary>
        /// 
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ParameterSetName == "BySearch")
            {
                var items = Configuration.Instance.GetItemsBySearch(SearchText, MaxResultCount, TimeoutSeconds, out var result);
                if (result == SearchResult.OK)
                {
                    items.ForEach(WriteObject);
                }
                else
                {
                    WriteError(
                        new ErrorRecord(
                            new MIPException($"GetItemsBySearch failed: {result}"),
                            "GetItemsBySearch Failed",
                            ErrorCategory.InvalidResult,
                            null));
                }
            }
            else if (ParameterSetName == "ById")
            {
                try
                {
                    var kinds = VideoOS.Platform.Kind.DefaultTypeToNameTable.Keys;
                    foreach (Guid kind in kinds)
                    {
                        var item = Configuration.Instance.GetItem(Id, kind);
                        if (item != null)
                        {
                            WriteObject(item);
                            return;
                        }
                    }
                }
                catch (InvalidOperationException ex)
                {
                    WriteWarning("Configuration may still be loading in the background. Try again.");
                    WriteError(
                        new ErrorRecord(
                            ex,
                            ex.Message,
                            ErrorCategory.InvalidOperation,
                            null));
                }
            }
            else if (ParameterSetName == "ByKind")
            {
                foreach (var item in EnumerateItemsByKind(Kind))
                {
                    WriteObject(item);
                }
            }
            else if (ParameterSetName == "ListAvailable")
            {
                foreach (var item in EnumerateItemsByKind(Guid.Empty, Hierarchy, IncludeFolders))
                {
                    WriteObject(item);
                }
            }
            else
            {
                WriteObject(Configuration.Instance.GetItem(Fqid));
            }
        }

        private static IEnumerable<Item> EnumerateItemsByKind(Guid kind, ItemHierarchy hierarchy = ItemHierarchy.SystemDefined, bool includeFolders = false)
        {
            var hashSet = new HashSet<Guid>();
            var stack = new Stack<Item>(Configuration.Instance.GetItems(hierarchy));
            while (stack.Count > 0)
            {
                var item = stack.Pop();
                if (hashSet.Contains(item.FQID.ObjectId))
                {
                    continue;
                }

                if (item.FQID.FolderType != FolderType.No)
                {
                    item.GetChildren().ForEach(stack.Push);
                }

                if (kind == Guid.Empty || item.FQID.Kind == kind && (item.FQID.FolderType == FolderType.No || includeFolders))
                {
                    hashSet.Add(item.FQID.ObjectId);
                    yield return item;
                }
            }
        }
    }
}

