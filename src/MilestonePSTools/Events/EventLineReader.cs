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
using VideoOS.Platform;
using VideoOS.Platform.Proxy.Alarm;
using VideoOS.Platform.Proxy.AlarmClient;

namespace MilestonePSTools.Events
{
    public class EventLineReader : IDisposable
    {
        private readonly ServerId _serverId;
        private readonly IAlarmClient _client;

        public int PageSize { get; set; } = 1000;
        public int Position { get; set; } = 0;
        public OrderBy[] OrderBy { get; set; }
        public Condition[] Conditions { get; set; }

        public EventLineReader(ServerId serverId)
        {
            _serverId = serverId;
            _client = new AlarmClientManager().GetAlarmClient(_serverId);
        }

        public IEnumerable<EventLine> GetEvents()
        {

            var filter = new EventFilter
            {
                Conditions = Conditions,
                Orders = OrderBy
            };
            EventLine[] eventLines;
            do
            {
                eventLines = _client.GetEventLines(Position, PageSize, filter);
                foreach (var line in eventLines)
                {
                    yield return line;
                }
                Position += PageSize;
            } while (eventLines.Length == PageSize);
        }

        public void Dispose()
        {
            _client.CloseClient();
        }
    }
}

