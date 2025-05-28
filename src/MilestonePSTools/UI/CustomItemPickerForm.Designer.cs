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

namespace MilestonePSTools.UI
{
    partial class CustomItemPickerForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(CustomItemPickerForm));
            this.ItemPicker = new VideoOS.Platform.UI.ItemPickerUserControl();
            this.CancelButton = new System.Windows.Forms.Button();
            this.OkButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // ItemPicker
            // 
            this.ItemPicker.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ItemPicker.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ItemPicker.CategoryUserSelectable = true;
            this.ItemPicker.Dock = System.Windows.Forms.DockStyle.Top;
            this.ItemPicker.Font = new System.Drawing.Font("Arial", 9.25F);
            this.ItemPicker.GroupTabVisible = true;
            this.ItemPicker.ItemsSelected = ((System.Collections.Generic.List<VideoOS.Platform.Item>)(resources.GetObject("ItemPicker.ItemsSelected")));
            this.ItemPicker.KindSelected = new System.Guid("00000000-0000-0000-0000-000000000000");
            this.ItemPicker.KindUserSelectable = true;
            this.ItemPicker.Location = new System.Drawing.Point(0, 0);
            this.ItemPicker.Name = "ItemPicker";
            this.ItemPicker.ServerTabVisible = true;
            this.ItemPicker.ShowDisabledItems = false;
            this.ItemPicker.SingleSelect = false;
            this.ItemPicker.Size = new System.Drawing.Size(614, 363);
            this.ItemPicker.TabIndex = 0;
            this.ItemPicker.ItemsSelectedChangedEvent += new System.EventHandler(this.itemPickerUserControl1_ItemsSelectedChangedEvent);
            // 
            // CancelButton
            // 
            this.CancelButton.Location = new System.Drawing.Point(521, 369);
            this.CancelButton.Name = "CancelButton";
            this.CancelButton.Size = new System.Drawing.Size(75, 23);
            this.CancelButton.TabIndex = 1;
            this.CancelButton.Text = "Cancel";
            this.CancelButton.UseVisualStyleBackColor = true;
            this.CancelButton.Click += new System.EventHandler(this.Button_Click);
            // 
            // OkButton
            // 
            this.OkButton.Location = new System.Drawing.Point(431, 369);
            this.OkButton.Name = "OkButton";
            this.OkButton.Size = new System.Drawing.Size(75, 23);
            this.OkButton.TabIndex = 2;
            this.OkButton.Text = "OK";
            this.OkButton.UseVisualStyleBackColor = true;
            this.OkButton.Click += new System.EventHandler(this.Button_Click);
            // 
            // CustomItemPickerForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(614, 409);
            this.Controls.Add(this.OkButton);
            this.Controls.Add(this.CancelButton);
            this.Controls.Add(this.ItemPicker);
            this.Name = "CustomItemPickerForm";
            this.Shown += new System.EventHandler(this.CustomItemPickerForm_Shown);
            this.ResumeLayout(false);

        }

        #endregion

        private VideoOS.Platform.UI.ItemPickerUserControl ItemPicker;
        private new System.Windows.Forms.Button CancelButton;
        private System.Windows.Forms.Button OkButton;
    }
}
