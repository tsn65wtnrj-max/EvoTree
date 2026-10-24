---
name: evotree-setup
description: Install EvoTree into a selected local macOS Codex project. Use for EvoTree setup; recording and runtime operation use the installed evotree skill and require separate consent.
metadata:
  version: "0.7.0-dev.69-english-candidate-r3"
  stage: "English integration; Directory admission pending"
---
# Set up EvoTree

The one-time core download requires separate consent to the disclosed download.
Its exact URL is bound to the Pages origin assigned in the publisher's Cloudflare
account. Check the exact artifact size, hash and manifest; a prior host test
does not prove delivery of a new hash path. General platform trust is not established.
Download only with explicit consent as specified in `channel.json`.

When installation is requested, verify the absolute physical project root and run
the following with the existing installation consent:

```sh
/bin/sh <this-skill>/scripts/install.sh --root <absolute-project-root> --confirm-install --confirm-download
```

[channel.json](channel.json) specifies the exact version, source mode, SHA-256 and
manifest binding. Do not use alternative sources, newer versions or automatic
retries. Bound files are verified before execution. Installation enables neither
capture, the producer, autonomous recording nor the runtime. Failures can leave a
partial installation; inspect status instead of assuming installation or activation
succeeded.

After success, read the installed `.agents/skills/evotree/SKILL.md` and the reported
`instruction_file`; use `$evotree` for operation. This setup skill has a distinct
name so its path does not block the product installer. Explicit user instructions
take precedence. License allocation and every installed core path are documented
in [LICENSE-MAP.json](LICENSE-MAP.json), with license texts under `licenses/`.
Own integration contributions use MIT; own core contributions use Free Local;
third-party rights remain intact. The compiled core can still be copied and
analyzed; thin wrappers and browser files are readable.

Native preview: macOS 26+ on arm64 only. Setup uses existing Mac system tools and
needs no additional Python installation. No Intel, clean-Mac or notarization PASS.
The core includes specific third-party texts and file allocation; complete
provenance verification and platform acceptance remain open. Host authorization
is separate from public integration authorization.

This installer does not remove quarantine attributes. A quarantined core ZIP is
blocked before execution and retained until a normal platform trust path is
established. Also stop if security metadata cannot be read; do not delete
attributes or bypass system protection.

Codex performs setup. There is no separate Mac app or manually operated external
app installer. Execute only through the local Codex executor, using absolute
physical paths. Report missing system tools as a blocker; do not install anything.
Installation and download require their existing consent; repeating setup or
starting a process does not grant another opt-in.

The bound setup adapter has a finite 65-second window. Unexpected or incomplete
staging data are retained; no automatic retry or recursive deletion. It proves
neither public platform trust nor Directory admission.

The pinned core uses English UI and operating instructions. Old stored status
keys and exact owned legacy instruction blocks are retained for compatibility.
