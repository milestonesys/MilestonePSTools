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
using VideoOS.ConfigurationApi.ClientService;

namespace MilestonePSTools.ConfigApiCommands
{
    /// <summary>
    /// <para type="synopsis">Gets a ConfigurationItem object</para>
    /// <para type="description">Uses the Configuration API to access configuration items. Useful for navigating the
    /// configuration of the VMS without the need to understand the individual object types like cameras, servers, and users.</para>
    /// <para type="description">Each ConfigurationItem may have child items, methods that could be invoked, or properties that
    /// can be read and/or modified. Use Set-ConfigurationItem to save changes made to a ConfigurationItem object.</para>
    /// <example>
    ///     <code>C:\PS> $ms = Get-ConfigurationItem -Path "/"; $name = $ms.Properties[0] | Where-Object Key -eq "Name"; $name = "New Name"; $ms | Set-ConfigurationItem</code>
    ///     <para>Changes the Name property of the Management Server</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <para type="link" uri="https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&amp;tree=tree_4.html">MIP SDK Configuration API docs</para>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(VideoOS.ConfigurationApi.ClientService.ConfigurationItem))]
    [OutputType(typeof(ConfigurationItem))]
    [RequiresVmsConnection()]
    public class GetConfigurationItem : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies a source ConfigurationItem for retrieving a Child or Parent ConfigurationItem</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public ConfigurationItem ConfigurationItem { get; set; }

        /// <summary>
        /// <para type="description">Specifies an item type such as Camera, Hardware, RecordingServer, to use for constructing a path in the form of ItemType[Id]</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public string ItemType { get; set; }

        /// <summary>
        /// <para type="description">Specifies a Guid identifier to use for constructing a path in the form of ItemType[Id]</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true)]
        public Guid Id { get; set; }

        /// <summary>
        /// <para type="description">Specifies the Configuration API path string for a given item if already known.</para>
        /// <para type="description">These are typically in the form of Camera[GUID] but you can always start crawling the configuration from the top starting at "/" which specifies the Management Server itself.</para>
        /// </summary>
        [Parameter(ValueFromPipelineByPropertyName = true, Position = 1)]
        public string Path { get; set; }

        /// <summary>
        /// <para type="description">Get all child items for the given ConfigurationItem, Path, or ItemType and ID pair</para>
        /// </summary>
        [Parameter]
        public SwitchParameter ChildItems { get; set; }

        /// <summary>
        /// <para type="description">Get the immediate parent of a given ConfigurationItem, Path, or ItemType and ID pair</para>
        /// </summary>
        [Parameter]
        public SwitchParameter Parent { get; set; }

        /// <summary>
        /// <para type="description">Get the first parent of a given ConfigurationItem, Path, or ItemType and ID pair where the ItemCategory is "Item"</para>
        /// <para type="description">This is mostly used when navigating up from a Camera device to the parent Hardware device, or Hardware to Recording Server</para>
        /// <para type="description">The -Parent switch will provide the immediate parent which might be a Folder rather than an actual recognizable device</para>
        /// </summary>
        [Parameter]
        public SwitchParameter ParentItem { get; set; }

        /// <summary>
        /// <para type="description">Return the desired ConfigurationItem and all child items recursively.</para>
        /// <para type="description">Note: This can take a very long time to return a result depending on the provided Path and size of the VMS.</para>
        /// </summary>
        [Parameter]
        public SwitchParameter Recurse { get; set; }

        [Parameter]
        public SwitchParameter Sort { get; set; }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            var path = ConfigurationItem?.Path ?? Path ?? $"{ItemType}[{Id}]";

            for (int errors = 0; errors < 2; errors++)
            {
                try
                {
                    if (ChildItems)
                    {
                        foreach (var childItem in ConfigurationService.GetChildItems(path))
                        {
                            WriteItem(childItem);
                        }
                    }
                    else if (Parent)
                    {
                        var item = ConfigurationItem ?? ConfigurationService.GetItem(path);
                        WriteItem(ConfigurationService.GetItem(item.ParentPath));
                    }
                    else if (ParentItem)
                    {
                        var item = ConfigurationItem ?? ConfigurationService.GetItem(path);
                        var parent = ConfigurationService.GetItem(item.ParentPath);
                        while (parent.ItemCategory != "Item")
                        {
                            parent = ConfigurationService.GetItem(parent.ParentPath);
                        }
                        WriteItem(parent);
                    }
                    else
                    {
                        WriteItem(ConfigurationService.GetItem(path));
                    }
                    break;
                }
                catch (System.ServiceModel.CommunicationException)
                {
                    if (errors > 0)
                    {
                        throw;
                    }
                    WriteVerbose($"Get-ConfigurationItem threw a CommunicationException. The operation will be retried after clearing the proxy client cache.");
                    ClearProxyClientCache();
                }
            }
        }

        private void WriteItem(ConfigurationItem item)
        {
            if (Recurse)
            {
                FillConfigurationItem(item);
            }
            WriteObject(item);
        }

        private void FillConfigurationItem(ConfigurationItem item)
        {
            var stack = new Stack<ConfigurationItem>(new[] { item });
            while (stack.Count > 0)
            {
                var currentItem = stack.Pop();
                currentItem.Children = currentItem.Children ?? new ConfigurationItem[0];
                if (!currentItem.ChildrenFilled)
                {
                    try
                    {
                        currentItem.Children = ConfigurationService.GetChildItems(currentItem.Path)
                                               ?? new ConfigurationItem[0];

                        currentItem.ChildrenFilled = true;
                    }
                    catch (Exception ex)
                    {
                        WriteWarning($"Failed to get child items from {currentItem.Path}: {ex.Message}");
                    }
                }

                if (Sort && currentItem.Children.All(c => c.Properties != null && c.Properties.Any(p => p.Key.Equals("Channel"))))
                {
                    Array.Sort(currentItem.Children, (c1, c2) =>
                    {
                        if (c1.Properties == null && c2.Properties == null) return 0;
                        if (c1.Properties == null) return -1;
                        if (c2.Properties == null) return 1;

                        var item1Chan = int.Parse(c1.Properties.FirstOrDefault(p => p.Key == "Channel")?.Value ?? "-1");
                        var item2Chan = int.Parse(c2.Properties.FirstOrDefault(p => p.Key == "Channel")?.Value ?? "-1");

                        return item1Chan.CompareTo(item2Chan);
                    });
                }

                if (currentItem.Children == null) continue;

                foreach (var child in currentItem.Children)
                {
                    stack.Push(child);
                }
            }
        }
    }
}

