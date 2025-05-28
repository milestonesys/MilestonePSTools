---
hide:
  - toc
---

# Set-AdaptiveStreaming

This function can be used to automate the configuration changes needed for adaptive streaming, and for Milestone systems
running version 2023 R2 or later, adaptive streaming can also be used when playing back recorded video as long as one
stream has been selected for the secondary recording track.

Video is often recorded at a higher resolution than the display it is viewed on - especially when there are multiple
cameras in the view. Many systems are still using 1080p displays with a maximum resolution of 1920x1080, but let's make
the case for adaptive streaming even on a 4K display.

The standard resolution on a 4K display is 3840x2160, and we'll assume you are recording video at 5 megapixel, or
around a resolution of 2592x1944. If you view 9 cameras at once in a 3x3 matrix on a 4K display, the video for each
camera gets resized by the client application and displayed in a much smaller 1280x720 resolution tile which is
effectively 1 megapixel. You're not even _seeing_ 80% of the pixels your computer is receiving.

If we assume you are recording 10 frames per second, that is 360 _million_ pixels worth of information per second that
is being sent over the network to your computer, wasting bandwidth in the process. And once it gets to your computer,
it takes a lot of work to decode that video - even if a GPU is providing some hardware accelerated assistance. You might
find that your computer isn't able to decode and render 9 5MP H.264 streams at once.

With adaptive streaming enabled, your recording server will receive 2 or more streams from a camera, and one of them
may be used for recording full resolution video while the other(s) can be much lower resolution such as 1280x720 or 720p.
The client application can then receive the low resolution video until you maximize a single camera and the total area
used to display the video is larger than the low resolution stream. At that point, the client can automatically switch
to the high resolution stream.

This can enable you to display more video on the same hardware, or better yet - display the same video on much lower cost
hardware. It is also a benefit for remote workers where the bandwidth between the client and server is too low to stream
high resolution video effectively.

To setup adaptive streaming on a camera, you need to...

1. Open the camera settings in Management Client.
2. Add a second stream in the Streams tab.
3. Set one stream as the default live stream (usually the lower resolution stream).
4. Set one stream as the recorded stream, or "primary" recording track on version 2023 R2 and later.
5. Optionally set one stream as the "secondary" recording track on version 2023 R2 and later, and usually mark this as the default playback stream.
6. Review the stream properties in the settings tab for the enabled streams and make sure the codec, resolution, frame rate, and quality/bitrate make sense for your use.

These configuration steps can be tedious to do by hand, especially on more than a handful of cameras. This
`Set-AdaptiveStreaming` function can save a lot of time by making the majority of these changes in bulk.

[Download :material-download:](../scripts/Set-AdaptiveStreaming.ps1){ .md-button .md-button--primary }

## :material-powershell: Code

```powershell linenums="1" title="Set-AdaptiveStreaming.ps1"
--8<-- "scripts/Set-AdaptiveStreaming.ps1"
```

--8<-- "abbreviations.md"

