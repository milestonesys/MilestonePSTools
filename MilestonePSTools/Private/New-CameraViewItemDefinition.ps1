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

function New-CameraViewItemDefinition {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VmsCameraViewItemProperties]
        $Properties
    )

    process {
        $template = @"
<viewitem id="{0}" displayname="Camera ViewItem" shortcut="{1}" type="VideoOS.RemoteClient.Application.Data.ContentTypes.CameraContentType.CameraViewItem, VideoOS.RemoteClient.Application" smartClientId="{2}">
    <iteminfo cameraid="{3}" lastknowncameradisplayname="{4}" livestreamid="{5}" imagequality="{6}" framerate="{7}" maintainimageaspectratio="{8}" usedefaultdisplaysettings="{9}" showtitlebar="{10}" keepimagequalitywhenmaximized="{11}" updateonmotiononly="{12}" soundonmotion="{13}" soundonevent="{14}" smartsearchgridwidth="{15}" smartsearchgridheight="{16}" smartsearchgridmask="{17}" pointandclickmode="{18}" usingproperties="True" />
    <properties>
        <property name="cameraid" value="{3}" />
        <property name="livestreamid" value="{5}" />
        <property name="framerate" value="{7}" />
        <property name="imagequality" value="{6}" />
        <property name="lastknowncameradisplayname" value="{4}" />
    </properties>
</viewitem>
"@
        $soundOnMotion = if ($Properties.SoundOnMotion) { 1 } else { 0 }
        $soundOnEvent  = if ($Properties.SoundOnEvent)  { 1 } else { 0 }
        $values = @(
            $Properties.Id,
            $Properties.Shortcut,
            $Properties.SmartClientId,
            $Properties.CameraId,
            $Properties.CameraName,
            $Properties.LiveStreamId,
            $Properties.ImageQuality,
            $Properties.Framerate,
            $Properties.MaintainImageAspectRatio,
            $Properties.UseDefaultDisplaySettings,
            $Properties.ShowTitleBar,
            $Properties.KeepImageQualityWhenMaximized,
            $Properties.UpdateOnMotionOnly,
            $soundOnMotion,
            $soundOnEvent,
            $Properties.SmartSearchGridWidth,
            $Properties.SmartSearchGridHeight,
            $Properties.SmartSearchGridMask,
            $Properties.PointAndClickMode
        )
        Write-Output ($template -f $values)
    }
}

