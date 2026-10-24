# EvoTree — privacy notice for the local basic version

Updated: 2026-10-24. Publisher: Andreas Aschenbrenner. Public contact:
[GitHub Issues](https://github.com/tsn65wtnrj-max/EvoTree/issues).
This package contains no private email address.

## Purpose and activation

EvoTree represents development of a selected local Codex project as a feature
structure with provenance, changes and evidence. Installation alone does not
enable capture, producer processing or the runtime. Before activation, the
specific project, native session, source file, start at the current end of that
file, duration and configuration hash are shown.

Capture, local requirements processing and optional suggestions in the existing
Codex context each require their respective separate consent. There is no full
import of past sessions or search through other chats' contents.

## Data processed and stored locally

In normal `project-session-v1` mode, EvoTree reads authorized future native inputs
from the bound source file. It stores project, session and input identities,
content hashes, timestamps, cursors, receipts, feature and requirement titles,
descriptions, relationships, revisions and history. Complete prompt texts and
tool responses are not archived as such in this mode. Derived titles or
descriptions can nevertheless contain private information. Hashes do not prove
anonymization. General detection or complete removal of all secrets is not
promised. Do not select credentials or other people's private content for capture.

Autonomous suggestions retain agent provenance, separate from UserMessages and
actual evidence. An optional, explicitly prepared local evidence test reads only
the confirmed project files and runs only the confirmed command. It stores file
and command hashes, scope, outcome, timestamps and signed evidence; stdout/stderr
are retained only as hashes and byte counts, not free-form output. A test command
does not create an additional operating-system sandbox: it has the actual existing
Codex/macOS permissions. Do not approve untrusted commands.

Local operational diagnostics contain bounded state and error counters and, where
applicable, the first technical error class, a fixed error code, phase, runtime
reference, UTC/monotonic time and minimized lifecycle state. These first-error
diagnostics exclude free-form exception messages, stack traces and full settings.

## Storage, retention and local view

Project status reports the actual private storage location and binding. Runtime
and registration data are project-specific under `.evotree`; product files are
under `.agents/skills/evotree`. The local view server binds only to `127.0.0.1`
and requires project-specific authentication. Someone controlling your user
account, local keys or backups may be able to read or copy the data. EvoTree does
not replace operating-system access controls.

Stored graph, provenance and evidence data have no automatic deletion deadline.
They remain local until product-data deletion is explicitly confirmed. The end
of a bounded capture window and deactivation stop new capture but do not delete
existing history. A saved view can open while capture is disabled and does not
restart it.

## Control and deletion

The installed `SESSION_CONSENT.md` reference describes status, deactivation,
stopping and separately confirmed project-data deletion. Deletion requires explicit
confirmation of the project ID. Any configured optional login startup must first
be disabled through the normal procedure. Product-data deletion removes captured
input hashes, graphs and receipts; a disabled reimport-blocking marker remains.
Original native Codex files are neither modified nor deleted. Registration and
consent metadata and package backups remain until separate, safe artifact cleanup.

Exports you created, operating-system/user backups and original Codex transcripts
are outside this product-data deletion. Check local graphs, exports and diagnostic
details for confidential content before sharing them. After renewed consent, a
new capture window starts at the current EOF; disabled periods are not imported
retroactively.

## Transfers and other providers

EvoTree has no telemetry SDK, model client of its own or additional AI API.
Storage, layout and live-update processing run locally. Optional semantic matching
uses the existing Codex model context and its data/account settings; this does not
mean Codex itself runs offline. No user project is sent to an EvoTree cloud server.

The OpenAI plugin package bundles the pinned core archive. The skills.sh route can
download one fixed-version HTTPS artifact from Cloudflare Pages at
`https://evotree-downloads.pages.dev`. The static download is publicly available.
The host can see technical request metadata such as IP address, time and artifact
path. Download requests do not include project paths, session IDs, prompts or
credentials. After installation, the core does not need that host to process
projects. Future updates or a new setup can require another explicitly chosen
download.

Cloudflare processes technical request/traffic metadata under its own terms and
[privacy policy](https://www.cloudflare.com/privacypolicy/). No fixed log-deletion
period or zero-logging guarantee is promised. The free plan and pages.dev name do
not guarantee permanent availability or retention. The unchanged public HTTPS
delivery, including TLS, bytes, hashes and headers, was tested. This is not Codex
plugin trust or Directory acceptance. See the additional
[download notice](https://evotree-downloads.pages.dev/PRIVACY.md).

Codex/OpenAI, skills.sh and installation tools have their own privacy terms.
Documented Skills CLI use outside a separately authorized indexing test is intended
to use `DISABLE_TELEMETRY=1`; this is not a guarantee about every third-party tool
or platform log. EvoTree has no user login, mandatory cloud service or transfer to
the developer's computer.

This notice describes the documented data paths and local controls. It does not
confirm the exact public Developer identity mapping or Directory admission. Do not
send private user data to public support channels.
