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
using System.Windows.Interop;
using System.Windows.Media.Imaging;
using VideoOS.Platform;
using VideoOS.Platform.UI;
using DialogResult = System.Windows.Forms.DialogResult;
using FormStartPosition = System.Windows.Forms.FormStartPosition;

namespace MilestonePSTools.UI
{
    /// <summary>
    /// Wraps <see cref="ItemPickerWpfWindow"/>, the MIP SDK's replacement for the
    /// deprecated WinForms ItemPickerForm/ItemPickerUserControl.
    /// </summary>
    public class CustomItemPickerForm
    {
        private readonly ItemPickerWpfWindow _window = new ItemPickerWpfWindow();
        private List<Guid> _kindFilter = new List<Guid>();

        public bool AllowServers { get; set; }

        public bool AllowFolders { get; set; }

        public List<Item> ItemsSelected => _window.SelectedItems?.ToList() ?? new List<Item>();

        public List<Item> ItemsSelectedFlattened
        {
            get
            {
                var result = new List<Item>();
                var stack = new Stack<Item>(ItemsSelected);
                while (stack.Count > 0)
                {
                    var item = stack.Pop();
                    if (item.FQID.FolderType == FolderType.No && (_kindFilter.Count == 0 || _kindFilter.Contains(item.FQID.Kind)))
                    {
                        result.Add(item);
                    }
                    else
                    {
                        item.GetChildren().ForEach(stack.Push);
                    }
                }

                return result;
            }
        }

        public bool SingleSelect
        {
            get => _window.SelectionMode == SelectionModeOptions.SingleSelect;
            set => _window.SelectionMode = value ? SelectionModeOptions.SingleSelect : SelectionModeOptions.MultiSelect;
        }

        public List<Guid> KindFilter
        {
            set
            {
                _kindFilter = value ?? new List<Guid>();
                _window.KindsFilter = _kindFilter;
            }
        }

        public string Text
        {
            get => _window.Header;
            set => _window.Header = value;
        }

        public System.Drawing.Icon Icon
        {
            set => _window.Icon = value == null
                ? null
                : Imaging.CreateBitmapSourceFromHIcon(value.Handle, System.Windows.Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
        }

        public bool TopMost
        {
            get => _window.Topmost;
            set => _window.Topmost = value;
        }

        public FormStartPosition StartPosition
        {
            set => _window.WindowStartupLocation = value == FormStartPosition.CenterScreen
                ? System.Windows.WindowStartupLocation.CenterScreen
                : System.Windows.WindowStartupLocation.Manual;
        }

        public double Width
        {
            get => _window.Width;
            set => _window.Width = value;
        }

        public double Height
        {
            get => _window.Height;
            set => _window.Height = value;
        }

        public CustomItemPickerForm()
        {
            SingleSelect = false;
            Width = 700;
            Height = 500;
            _window.Items = GetPickerItems();
            _window.IsValidSelectionCallback = IsValidSelection;
            _window.SearchEnabled = true;
        }

        private static IEnumerable<Item> GetPickerItems()
        {
            // Server items expose different children per hierarchy (logical groups vs. the full device tree),
            // so only Server items are allowed to appear from both hierarchies. Everything else (e.g. the
            // layout group/video wall/GIS map folders) is shared between hierarchies and would otherwise be duplicated.
            var seen = new HashSet<Guid>();
            foreach (var item in Configuration.Instance.GetItems(ItemHierarchy.UserDefined)
                .Concat(Configuration.Instance.GetItems(ItemHierarchy.SystemDefined)))
            {
                if (item.FQID.Kind == Kind.Server || seen.Add(item.FQID.ObjectId))
                {
                    yield return item;
                }
            }
        }

        private bool IsValidSelection(Item item)
        {
            if (item.FQID.Kind == Kind.Server && !AllowServers) return false;
            if (item.FQID.FolderType != FolderType.No && !AllowFolders) return false;
            return true;
        }

        public DialogResult ShowDialog() => _window.ShowDialog() == true ? DialogResult.OK : DialogResult.Cancel;
    }
}

