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
using System.Diagnostics;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using VideoOS.Platform.ConfigurationItems;

namespace MilestoneLib
{
    public static class ServerTasks
    {
        public static class DriverScanProperty
        {
            public const string MacAddressExistsLocal = "MacAddressExistsLocal";
            public const string HardwareScanValidated = "HardwareScanValidated";
            public const string Progress = "Progress";
            public const string HardwareAddress = "HardwareAddress";
            public const string MacAddress = "MacAddress";
            public const string HardwareDriverPath = "HardwareDriverPath";
            public const string State = "State";
        }
        
        public static ServerTask WaitForTask(ServerTask task, IProgress<int> progress = null)
        {
            while (task.State != StateEnum.Success && task.State != StateEnum.Error)
            {
                Task.Delay(TimeSpan.FromMilliseconds(100)).Wait();
                task.UpdateState();
                progress?.Report(task.Progress);
            }

            if (task.State == StateEnum.Error)
                throw new InvalidOperationException(task.ErrorText);
            return task;
        }

        public static ServerTask WaitWithProgress(Cmdlet cmdlet, ServerTask task, ProgressRecord progress)
        {
            var lastProgress = task.Progress;
            var stopwatch = Stopwatch.StartNew();
            while (task.State != StateEnum.Success && task.State != StateEnum.Error)
            {
                Thread.Sleep(200);
                task.UpdateState();

                // Update progress no more than once per second and only if progress changed
                // to minimize performance hit with writeprogress in Windows PowerShell.
                if (stopwatch.Elapsed.TotalSeconds >= 1 && task.Progress != lastProgress)
                {
                    progress.PercentComplete = task.Progress;
                    cmdlet.WriteProgress(progress);
                    lastProgress = task.Progress;
                    stopwatch.Restart();
                }
            }

            if (task.State == StateEnum.Error)
                throw new InvalidOperationException(task.ErrorText);
            return task;
        }

        public static string GetTaskPropertyReport(ServerTask task, string header)
        {
            var sb = new StringBuilder($"{header}:\r\n");
            foreach (var key in task.GetPropertyKeys().Where(k => !k.StartsWith("pass", StringComparison.OrdinalIgnoreCase)).OrderBy(k => k))
            {
                sb.AppendLine($"  {key} : {task.GetProperty(key)}");
            }

            return sb.ToString();
        }
    }
}

