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

namespace MilestonePSTools.EventCommands
{
    /// <summary>
    /// 
    /// </summary>
    public class MessageQueueMessage
    {
        /// <summary>
        /// 
        /// </summary>
        public VideoOS.Platform.Messaging.Message Message { get; private set; }
        /// <summary>
        /// 
        /// </summary>
        public DateTime TimeReceived { get; private set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="message"></param>
        public MessageQueueMessage(VideoOS.Platform.Messaging.Message message)
        {
            Message = message;
            TimeReceived = DateTime.UtcNow;
        }
    }
}

