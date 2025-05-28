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
using System.Text.RegularExpressions;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;

namespace MilestoneLib
{
    public static class DeviceGroups
    {
        public static string[] ParseGroupPath(string path)
        {
            var pathParts = Regex.Split(path, @"(?<!\`)\/").Where(p => !string.IsNullOrWhiteSpace(p)).Select(p => p.Replace("`", ""));
            return pathParts.ToArray();
        }

        #region Cameras
        public static CameraGroup CreateCameraGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.CameraGroupFolder;
            CameraGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.CameraGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new CameraGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.CameraGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.CameraGroupFolder;
            }

            return group;
        }

        public static CameraGroup SelectCameraGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.CameraGroupFolder;
            CameraGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.CameraGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.CameraGroupFolder;
            }
            return group;
        }

        public static void DeleteCameraGroup(CameraGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.CameraFolder.Cameras)
            {
                ServerTasks.WaitForTask(selectedGroup.CameraFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.CameraGroupFolder.CameraGroups)
                {
                    DeleteCameraGroup(group, true);
                }
            }
            var parentFolder = new CameraGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<CameraGroup> EnumerateCameraGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectCameraGroup(pathParts, ms);
            var stack = new Stack<CameraGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.CameraGroupFolder.CameraGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.CameraGroupFolder.CameraGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion

        #region Microphones
        public static MicrophoneGroup CreateMicrophoneGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.MicrophoneGroupFolder;
            MicrophoneGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.MicrophoneGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new MicrophoneGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.MicrophoneGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.MicrophoneGroupFolder;
            }

            return group;
        }

        public static MicrophoneGroup SelectMicrophoneGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.MicrophoneGroupFolder;
            MicrophoneGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.MicrophoneGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.MicrophoneGroupFolder;
            }
            return group;
        }

        public static void DeleteMicrophoneGroup(MicrophoneGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.MicrophoneFolder.Microphones)
            {
                ServerTasks.WaitForTask(selectedGroup.MicrophoneFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.MicrophoneGroupFolder.MicrophoneGroups)
                {
                    DeleteMicrophoneGroup(group, true);
                }
            }
            var parentFolder = new MicrophoneGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<MicrophoneGroup> EnumerateMicrophoneGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectMicrophoneGroup(pathParts, ms);
            var stack = new Stack<MicrophoneGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.MicrophoneGroupFolder.MicrophoneGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.MicrophoneGroupFolder.MicrophoneGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion

        #region Speakers
        public static SpeakerGroup CreateSpeakerGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.SpeakerGroupFolder;
            SpeakerGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.SpeakerGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new SpeakerGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.SpeakerGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.SpeakerGroupFolder;
            }

            return group;
        }

        public static SpeakerGroup SelectSpeakerGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.SpeakerGroupFolder;
            SpeakerGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.SpeakerGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.SpeakerGroupFolder;
            }
            return group;
        }

        public static void DeleteSpeakerGroup(SpeakerGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.SpeakerFolder.Speakers)
            {
                ServerTasks.WaitForTask(selectedGroup.SpeakerFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.SpeakerGroupFolder.SpeakerGroups)
                {
                    DeleteSpeakerGroup(group, true);
                }
            }
            var parentFolder = new SpeakerGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<SpeakerGroup> EnumerateSpeakerGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectSpeakerGroup(pathParts, ms);
            var stack = new Stack<SpeakerGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.SpeakerGroupFolder.SpeakerGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.SpeakerGroupFolder.SpeakerGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion

        #region Metadatas
        public static MetadataGroup CreateMetadataGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.MetadataGroupFolder;
            MetadataGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.MetadataGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new MetadataGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.MetadataGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.MetadataGroupFolder;
            }

            return group;
        }

        public static MetadataGroup SelectMetadataGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.MetadataGroupFolder;
            MetadataGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.MetadataGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.MetadataGroupFolder;
            }
            return group;
        }

        public static void DeleteMetadataGroup(MetadataGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.MetadataFolder.Metadatas)
            {
                ServerTasks.WaitForTask(selectedGroup.MetadataFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.MetadataGroupFolder.MetadataGroups)
                {
                    DeleteMetadataGroup(group, true);
                }
            }
            var parentFolder = new MetadataGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<MetadataGroup> EnumerateMetadataGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectMetadataGroup(pathParts, ms);
            var stack = new Stack<MetadataGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.MetadataGroupFolder.MetadataGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.MetadataGroupFolder.MetadataGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion

        #region InputEvents
        public static InputEventGroup CreateInputEventGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.InputEventGroupFolder;
            InputEventGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.InputEventGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new InputEventGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.InputEventGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.InputEventGroupFolder;
            }

            return group;
        }

        public static InputEventGroup SelectInputEventGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.InputEventGroupFolder;
            InputEventGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.InputEventGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.InputEventGroupFolder;
            }
            return group;
        }

        public static void DeleteInputEventGroup(InputEventGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.InputEventFolder.InputEvents)
            {
                ServerTasks.WaitForTask(selectedGroup.InputEventFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.InputEventGroupFolder.InputEventGroups)
                {
                    DeleteInputEventGroup(group, true);
                }
            }
            var parentFolder = new InputEventGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<InputEventGroup> EnumerateInputEventGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectInputEventGroup(pathParts, ms);
            var stack = new Stack<InputEventGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.InputEventGroupFolder.InputEventGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.InputEventGroupFolder.InputEventGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion

        #region Outputs
        public static OutputGroup CreateOutputGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.OutputGroupFolder;
            OutputGroup group = null;
            foreach (var groupName in folderNamesFromRoot)
            {
                group = folder.OutputGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                {
                    var task = ServerTasks.WaitForTask(folder.AddDeviceGroup(groupName, string.Empty));
                    group = new OutputGroup(folder.ServerId, task.Path);
                    folder.ClearChildrenCache();
                    group = folder.OutputGroups.FirstOrDefault(g => g.Name.Equals(groupName, StringComparison.OrdinalIgnoreCase));
                }
                folder = group.OutputGroupFolder;
            }

            return group;
        }

        public static OutputGroup SelectOutputGroup(string[] folderNamesFromRoot, ManagementServer ms)
        {
            var folder = ms.OutputGroupFolder;
            OutputGroup group = null;
            foreach (var folderName in folderNamesFromRoot)
            {
                group = folder.OutputGroups.FirstOrDefault(g => g.Name.Equals(folderName, StringComparison.OrdinalIgnoreCase));
                if (group == null)
                    throw new PathNotFoundMIPException($"Path to camera group not found: {string.Join("/", folderNamesFromRoot)}");
                folder = group.OutputGroupFolder;
            }
            return group;
        }

        public static void DeleteOutputGroup(OutputGroup selectedGroup, bool recurse)
        {
            foreach (var camera in selectedGroup.OutputFolder.Outputs)
            {
                ServerTasks.WaitForTask(selectedGroup.OutputFolder.RemoveDeviceGroupMember(camera.Path));
            }
            if (recurse)
            {
                foreach (var group in selectedGroup.OutputGroupFolder.OutputGroups)
                {
                    DeleteOutputGroup(group, true);
                }
            }
            var parentFolder = new OutputGroupFolder(selectedGroup.ServerId, selectedGroup.ParentPath);
            ServerTasks.WaitForTask(parentFolder.RemoveDeviceGroup(selectedGroup.Path));
        }

        public static IEnumerable<OutputGroup> EnumerateOutputGroups(string[] pathParts, ManagementServer ms)
        {
            var rootGroup = SelectOutputGroup(pathParts, ms);
            var stack = new Stack<OutputGroup>();
            if (rootGroup != null)
            {
                stack.Push(rootGroup);
            }
            else
            {
                foreach (var group in ms.OutputGroupFolder.OutputGroups)
                {
                    stack.Push(group);
                }
            }
            while (stack.Count > 0)
            {
                var group = stack.Pop();
                foreach (var subGroup in group.OutputGroupFolder.OutputGroups)
                {
                    stack.Push(subGroup);
                }

                yield return group;
            }
        }
        #endregion
    }
}

