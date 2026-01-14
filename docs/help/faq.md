# Frequently asked questions

## :material-chat-plus: Can I use a new MilestonePSTools version on an old version of Milestone?

Yes. You can typically always use a newer "client" on an older VMS, however
there is a limit to the backward compatibility testing performed by Milestone.

Since MilestonePSTools operates the same as a Milestone client application, you
should expect to see a similar level of backward compatibility. However, it is
possible that some features of this module will require a newer version of the
Milestone XProtect Management Server. We will do our best to make it clear in
the documentation, and error messages, when you might expect to find an
incompatibility.

## :material-chat-plus: Can I use an older MilestonePSTools version on a newer version of Milestone?

Yes. Milestone Systems makes a significant effort to ensure a level of forward
and backward compatibility, and most of the time you may use an older client
application to connect to a newer server. Most of the time there is no change
in user experience, though there have been a small number of exceptions.

One notable exception is when new encryption options were introduced for
client communication with XProtect recording servers. If encryption was enabled
on the recording server(s), client versions released prior to the introduction
of this feature would be unable to communicate with those recording servers.

Since Milestone can not guarantee forward compatibility of client applications
and the MIP SDK, neither can MilestonePSTools promise to always work against
newer versions of the Milestone XProtect VMS.

## :material-chat-plus: Can I perform the "Replace Hardware" action?

As of Milestone XProtect VMS version 2023 R1 (23.1.1), Yes! Sometimes it's
necessary to perform the Replace Hardware action in Management Client to either
*update* the properties and features of a camera after a device pack or
firmware upgrade, or *change* the driver used for the camera to take advantage
of a new driver.

If you're running Milestone XProtect Management Server version 2023 R1 or later,
and MilestonePSTools version 23.1.1 or later, then you can use the
[`#!powershell Set-VmsHardwareDriver`](../commands/en-US/Set-VmsHardwareDriver.md)
command to run a simplified implementation of the replace-hardware wizard from
Management Client.

If you're using a Milestone VMS version released prior to 2023, then as soon as
you upgrade your Management Server to at least 2023 R1, you can take advantage
of this feature.

## :material-chat-minus: Can I add cameras that are not on the network?

No. The MIP SDK, and really the core Milestone XProtect VMS platform does not
support the ability to add devices unless network communication with the device
is possible from the recording server service to which you are adding the
camera. So even with MilestonePSTools, the device(s) must be online in order
to add them to a recording server.

There are a few reasons this would be challenging to architect at this stage.
One such reason is that the Milestone Device Pack drivers support the concept
of "dynamic events" and "dynamic channels". This means that until we talk to
the camera, we don't know all of the available edge-based events or the number
of camera, microphone, and other device channels to expect.

One possible workaround for relatively basic use cases is to use the universal
driver to add a non-existant camera. You could then configure the name of the
hardware and channels, the permissions, and create views. Then, later, you
could edit the IP address and credentials, then right-click on the hardware in
Management Client and click "Replace hardware", or use the `#!powershell Set-VmsHardwareDriver`
command to change the hardware driver and optionally the address and credentials
once the cameras are online.

## :material-chat-question: Why are some commands prefixed with "VMS"?

The MilestonePSTools project began in 2019 by an engineer with no prior
experience building PowerShell modules (the same engineer writing this FAQ).
Over time, it became clear that some command names had the potential to collide
with commands available in other modules. For example, "Get-User" is so generic
that there could easily be another unrelated PowerShell module with the same
command.

PowerShell module authors are recommended to prefix the nouns in their cmdlet
names with a short string to minimize the chance of colliding with other
modules. We chose to use "VMS", which is short for Video Management Software.

All new commands should use the new "VMS" prefix. The future for old commands
is not yet decided. We can't broadly apply the prefix to all commands due to
the risk of breaking any automation setup by customers using the module.
Perhaps we'll apply the prefix to all commands, and add aliases for the old
command names? If you have suggestions for how to address this with minimal
impact to current users, please feel free to contribute to a discussion
[on GitHub](https://github.com/milestonesys/MilestonePSTools)!
