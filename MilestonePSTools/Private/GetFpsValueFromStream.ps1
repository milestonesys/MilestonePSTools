# Copyright 2025 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function GetFpsValueFromStream {
    param([VideoOS.Platform.ConfigurationItems.StreamChildItem]$Stream)

    $res = $Stream.Properties.GetValue("FPS")
    if ($null -ne $res) {
        $val = ($Stream.Properties.GetValueTypeInfoCollection("FPS") | Where-Object Value -eq $res).Name
        if ($null -eq $val) {
            $res
        }
        else {
            $val
        }
        return
    }

    $res = $Stream.Properties.GetValue("Framerate")
    if ($null -ne $res) {
        $val = ($Stream.Properties.GetValueTypeInfoCollection("Framerate") | Where-Object Value -eq $res).Name
        if ($null -eq $val) {
            $res
        }
        else {
            $val
        }
        return
    }
}
