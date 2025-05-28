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
using System.Windows.Forms;
using VideoOS.Platform;
using VideoOS.Platform.Admin;
using VideoOS.Platform.UI;

namespace MilestonePSTools.UI
{
    public partial class CustomItemPickerForm : Form
    {
        public bool AllowServers { get; set; }
        public bool AllowFolders { get; set; }
        public List<Item> ItemsSelected => ItemPicker.ItemsSelected;

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

        public bool CategoryUserSelectable
        {
            get => ItemPicker.CategoryUserSelectable;
            set => ItemPicker.CategoryUserSelectable = value;
        }

        public bool KindUserSelectable
        {
            get => ItemPicker.KindUserSelectable;
            set => ItemPicker.KindUserSelectable = value;
        }

        public bool GroupTabVisable
        {
            get => ItemPicker.GroupTabVisible;
            set => ItemPicker.GroupTabVisible = value;
        }

        public bool ServerTabVisable
        {
            get => ItemPicker.ServerTabVisible;
            set => ItemPicker.ServerTabVisible = value;
        }

        public bool ShowDisabledItems
        {
            get => ItemPicker.ShowDisabledItems;
            set => ItemPicker.ShowDisabledItems = value;
        }

        public bool SingleSelect
        {
            get => ItemPicker.SingleSelect;
            set => ItemPicker.SingleSelect = value;
        }

        public List<Item> ItemsToSelectFrom
        {
            set => ItemPicker.ItemsToSelectFrom = value;
        }

        public List<Item> ItemsToSelectFromGroup
        {
            set => ItemPicker.ItemsToSelectFromGroup = value;
        }

        public List<Item> ItemsToSelectFromServer
        {
            set => ItemPicker.ItemsToSelectFromServer = value;
        }

        public List<Category> CategoryFilter
        {
            set => ItemPicker.CategoryFilter = value;
        }

        private List<Guid> _kindFilter = new List<Guid>();
        public List<Guid> KindFilter
        {
            set
            {
                value = value ?? new List<Guid>();
                _kindFilter = value;
                ItemPicker.KindFilter = _kindFilter;
                ReloadItemPicker();
            }
        }

        private void ReloadItemPicker()
        {
            ItemPicker.ItemsToSelectFromGroup = Configuration.Instance.GetItems(ItemHierarchy.UserDefined);
            ItemPicker.ItemsToSelectFromServer = Configuration.Instance.GetItems(ItemHierarchy.SystemDefined);
        }

        public CustomItemPickerForm()
        {
            InitializeComponent();
            CancelButton.Tag = DialogResult.Cancel;
            OkButton.Tag = DialogResult.OK;
            SetupItemPickerForm();
        }

        private void SetupItemPickerForm()
        {
            ItemPicker.Init();
            CategoryUserSelectable = false;
            KindUserSelectable = false;
            SingleSelect = false;
            ShowDisabledItems = false;
            ItemPicker.ValidateSelectionEvent += ItemPickerOnValidateSelectionEvent;
            ReloadItemPicker();
        }

        private void ItemPickerOnValidateSelectionEvent(ItemPickerForm.ValidateEventArgs e)
        {
            if (e.Item.FQID.Kind == Kind.Server && !AllowServers) return;
            if (e.Item.FQID.FolderType != FolderType.No && !AllowFolders) return;
            if (ItemsSelected.Any(i => i.FQID.ObjectId == e.Item.FQID.ObjectId)) return;
            e.AcceptSelection = true;
        }

        private void itemPickerUserControl1_ItemsSelectedChangedEvent(object sender, EventArgs e)
        {
            UpdateOkButton();
        }

        private void Button_Click(object sender, EventArgs e)
        {
            if (!(sender is Button button)) return;
            this.DialogResult = (DialogResult)button.Tag;
            this.Close();
        }

        private void CustomItemPickerForm_Shown(object sender, EventArgs e)
        {
            UpdateOkButton();
        }

        private void UpdateOkButton()
        {
            OkButton.Enabled = ItemPicker.ItemsSelected.Count > 0;
        }
    }
}

