# MilestonePSTools

A PowerShell module for configuring, automating, and reporting on a Milestone XProtect video management system (VMS), covering both the hybrid PowerShell/C# cmdlet surface and the underlying `VideoOS.*` SDK it wraps.

## Language

**Hardware**:
A container representing one network-addressable unit (IP address or hostname) added to a Recording Server. Holds one or more Devices — typically a Camera, and often a Microphone, Speaker, Metadata, and Input/Output devices.
_Avoid_: Camera, Encoder, Device (when you mean the whole unit)

**Device**:
The umbrella term for any channel a piece of Hardware exposes — Camera, Microphone, Speaker, Metadata, or Input/Output.

**Camera**:
A video Device — one of potentially several channels (numbered from 0) exposed by a single Hardware unit.
_Avoid_: Hardware (a Camera is one channel *of* a Hardware unit, not the unit itself)

**Offline**:
Ambiguous without qualification — can mean either (a) the Hardware's network connection is unreachable, or (b) a specific Device (usually a Camera) is failing to stream even though the Hardware's network connectivity is healthy (e.g. UDP video blocked by a firewall, or a misbehaving Recording Server / device driver). Users colloquially say "the camera is offline" for both cases and rarely say "hardware." When diagnosing or writing agent output, be explicit about which layer failed rather than reusing "offline" unqualified.

**Site**:
A whole Milestone XProtect VMS deployment — the Management Server plus every server connected to it (Recording Servers, Event Server, Failover Servers, Mobile Server, etc.) — viewed as one node in a Federated Hierarchy. Broader than "Management Server" in concept, though in a single-server deployment (management server, event server, and recording server all on one box) the two amount to the same thing. The "currently selected site" is the one most cmdlets operate against.
_Avoid_: System

**Management Server**:
Specifically the server component of a Site that holds the configuration database and coordinates the rest of the Site's servers, users, and rules. Narrower than "Site" — use "Site" when referring to the deployment as a whole.

**Recording Server**:
The server component that manages connections to Hardware/Devices, records video, and serves live/playback streams. A Site can have multiple Recording Servers.

**Federated Hierarchy** (Federated Site Hierarchy):
A set of Sites linked parent/child so a central Site can reach into child Sites. `Connect-Vms -IncludeChildSites` logs into the whole hierarchy at once.
