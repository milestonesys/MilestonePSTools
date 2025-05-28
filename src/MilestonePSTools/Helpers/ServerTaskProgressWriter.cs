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

using MilestoneLib;
using System;
using System.Collections.Concurrent;
using System.Management.Automation;
using System.Threading.Tasks;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.Helpers
{
    public class ServerTaskProgressWriter
    {
        private readonly PSCmdlet _cmdlet;
        private readonly ServerTask _serverTask;
        private readonly ProgressRecord _progressRecord;
        private readonly BlockingCollection<int> _progressUpdateQueue = new BlockingCollection<int>();
        private readonly object _lock = new object();

        public ServerTaskProgressWriter(PSCmdlet cmdlet, ServerTask serverTask, ProgressRecord progressRecord)
        {
            _cmdlet = cmdlet;
            _serverTask = serverTask;
            _progressRecord = progressRecord;
        }

        public ServerTask MonitorProgress()
        {
            var task = Task.Run(ProcessTask).ConfigureAwait(false);
            // ReSharper disable once InconsistentlySynchronizedField
            foreach (var value in _progressUpdateQueue.GetConsumingEnumerable())
            {
                _progressRecord.PercentComplete = value;
                _cmdlet.WriteProgress(_progressRecord);
            }
            _progressRecord.PercentComplete = 100;
            _progressRecord.RecordType = ProgressRecordType.Completed;
            _cmdlet.WriteProgress(_progressRecord);
            task.GetAwaiter().GetResult();
            return _serverTask;
        }

        private void ProcessTask()
        {
            try
            {
                var progress = new Progress<int>(i =>
                {
                    lock (_lock)
                    {
                        if (!_progressUpdateQueue.IsAddingCompleted)
                            _progressUpdateQueue.Add(i);
                    }
                });
                ServerTasks.WaitForTask(_serverTask, progress);
            }
            finally 
            {
                lock (_lock)
                {
                    _progressUpdateQueue.CompleteAdding(); 
                }
            }
        }
    }
}
