# OpenWorker Source-Based Readiness Report (Phases 0, 1, preliminary 5)

- Author: Claude Code (Opus 4.8), for Ray
- Date: 2026-09-14
- Scope: public-source verification only. Nothing was downloaded, installed, or
  executed. No OpenWorker binary was run. This is the readiness step that
  precedes the GUI-assisted experiment described in
  `.llm/handoffs/openworker-bounded-evaluation-handoff-2026-09-14.md`.
- ChatMap commit examined: `2ba3ead2b81b578ded90725b145749ae58f331ca` (clean).
- Evidence location: this report and its notes live at
  `C:\Users\ray\eclipse-workspace\openworker-eval-2026-09-14\`, outside the
  ChatMap repository.

## Executive verdict: INCONCLUSIVE

The product is real, is a plausible fit for the "OpenWorker owns execution /
ChatMap owns continuity" split, and is safe enough to trial locally (MIT,
local Ollama, disposable copy). But the single load-bearing question for
ChatMap -- is there a documented, stable seam to observe a run's lifecycle,
approvals, and transcripts without scraping private storage -- cannot be
answered from public documentation. A local HTTP API and CLI exist, but their
read surface, storage format, and any export are undocumented publicly.

Recommendation: a GUI-assisted experiment is justified only if the goal is to
answer that seam question directly. The smallest next step (below) is bounded
and stops before any task run.

## Phase 0 - Product and authorship

- Exists: yes. Repository `github.com/andrewyng/openworker`; site
  `openworker.com`; multiple independent write-ups (MarkTechPost, Medium,
  TheAIAgentIndex, EveryDev, Proudfrog) dated July-August 2026.
- Authorship (conservative language): published under the `andrewyng` GitHub
  organization and built on `andrewyng/aisuite`; widely attributed to Andrew Ng
  in secondary coverage. I did not independently verify individual authorship
  beyond the hosting organization and consistent third-party reporting.
- License: MIT (stated in the repository README).
- Status: open beta, pre-1.0. Releases observed: v0.1.4 (2026-07-22) through
  v0.2.1 (2026-08-25). Latest examined: v0.2.1.
- Numerous forks exist (expected for a popular new MIT project); only the
  `andrewyng` origin was treated as authoritative.

## Phase 1 - Technical facts

| Item | Finding | Source strength |
| --- | --- | --- |
| License | MIT | README (direct) |
| Status / version | Open beta; latest v0.2.1, 2026-08-25 | Releases page (direct) |
| OS support | macOS 12+ (Apple Silicon), Windows 10/11 x64 | README (direct) |
| Windows install | Prebuilt `OpenWorker-windows-setup.exe` (~59 MB) and `.msi` (~70 MB) on the release; or build from source | Releases page (direct) |
| Code signing | README: Windows builds "not yet code-signed, so SmartScreen will warn; signing is in progress" | README (direct) |
| Architecture | Tauri (Rust) native shell + React UI; local Python "agent server" built on aisuite | README (direct) |
| Build deps | Python 3.10+, Node 20+, Rust toolchain | README (direct) |
| Ollama / local | Supported ("run fully local with Ollama"); or bring-your-own cloud key | README (direct) |
| Governance | Hard floors (human-only ops); approval-gated by default ("earned autonomy"); audit trail records each tool call with approval provenance (auto/user/denied + reviewer reasoning), persisted with the conversation; unattended asks park in an inbox | README (direct) |
| Risk classes | read / write_local / exec / external | Secondary reviews (not confirmed in README text I fetched) |
| MCP | Supported as a client (any MCP-reachable tool plugs in, per-tool control) | README (direct) |
| A2A | No evidence; not mentioned | Absence in README/coverage |
| Local API | `openworker-server` standalone server; HTTP with `X-OpenWorker-Token` header; `--cwd`/`--port` flags; desktop app uses an in-memory launch token | README (direct) |
| API read surface | Endpoint list, whether it exposes run status/transcripts/events, and request/response formats: not stated | README (gap) |
| Storage | Local "secret store" + full transcripts "land in the app"; a state dir with a sidecar token is referenced; DB type/format/paths not stated | README (gap) |
| Export / event stream / webhook | Not stated | README (gap) |
| Scheduling | Yes (recurring automations) | README (direct) |

### Discrepancy to carry forward (do not resolve by guessing)

The README says Windows builds are not code-signed and will trip SmartScreen,
yet each release also ships `.sig` files. Those are almost certainly Tauri
*updater* signatures (for the self-update channel), not OS Authenticode
signatures, so SmartScreen would still warn. This should be confirmed at install
time, not assumed. Any install would mean running an unsigned third-party
binary and clicking through SmartScreen -- a real trust decision for Ray.

## Preliminary Phase 5 - ChatMap boundary seam (source-based, no run)

Mapping OpenWorker concepts to ChatMap's existing lifecycle ledger:

| OpenWorker evidence | ChatMap concept | Available from public sources? |
| --- | --- | --- |
| Submitted task | assignment | Yes, via GUI or local API (submit path exists) |
| Run instance | worker session | Plausible; not confirmed observable via API |
| Progress / terminal state | lifecycle transition | Unknown; no documented status endpoint or event stream |
| Approval request + decision | decision/provenance evidence | Persisted in the audit trail; programmatic access undocumented |
| Produced file | artifact (hash + source path) | Yes -- deliverables are real files ChatMap can hash and record today |
| Transcript / summary | handoff / session evidence | Stored in-app; export/read path undocumented |
| Retry / continuation | successor session / continuation link | Unknown |

Assessment:
- Easy and already-supported: recording produced **artifacts**. OpenWorker emits
  real deliverable files; ChatMap's existing `WorkerArtifact` (label, location,
  hash-able source path) can record them with no schema change.
- The hard part -- and the whole reason to run the experiment -- is the
  lifecycle/approval/transcript evidence. OpenWorker clearly *persists* it (audit
  trail with approval provenance, full transcripts), but there is no public
  documentation of an API endpoint, storage format, or export to read it
  programmatically. Today that implies one of: (a) an undocumented local API, or
  (b) reading OpenWorker's private on-disk state -- brittle scraping, the exact
  anti-pattern the assignment warns against. This is the INCONCLUSIVE core.
- Protocol seams: **A2A is absent**, so no A2A bridge. **MCP is client-side**
  (OpenWorker consumes MCP tools); it is not, as documented, a way for an
  external recorder to observe OpenWorker. A speculative inversion -- ChatMap
  exposing an MCP server that an OpenWorker task calls to log lifecycle -- would
  require designing the task around it and would make ChatMap a participant, not
  a passive recorder. Note only; not recommended yet.
- Agent Client (working-context item 5) solves a different problem: portable
  CLI launching of Claude/Codex/Gemini. OpenWorker is a full desktop harness with
  its own execution and approvals. They are not substitutes; Agent Client would
  not help ChatMap observe an OpenWorker run.

Answers to the Phase 5 questions, to the extent public sources allow:
1. Record via existing services/schema? Partially -- artifacts yes; lifecycle,
   approvals, transcripts unproven.
2. Which facts are available via supported export/files/logs/API? Confirmed:
   produced artifact files. Everything else: undocumented.
3. Which facts live only in private storage/UI? Likely transcripts, approval
   provenance, run status -- unless the local API exposes them.
4. Stable seam or brittle scraping? Unknown; a documented local API exists but
   its read surface is unspecified. Cannot yet distinguish "stable API" from
   "scrape the state dir."
5. A2A/MCP/local API/CLI/events/export? Local HTTP API + `openworker-server`
   CLI: yes. MCP: client-side. A2A/events/export: no evidence.
6. Agent Client value alongside OpenWorker? No; different problem.
7. Smallest future experiment: see below.

## Risks and unknowns

- Running an unsigned Windows binary (SmartScreen) is a genuine trust decision.
- The API read surface, storage format, and export path are the decisive
  unknowns and are simply not public.
- Risk-class taxonomy (read/write_local/exec/external) came from secondary
  reviews; treat as unconfirmed until seen in-product.
- A GUI desktop app cannot be driven by Claude Code; every install click,
  approval prompt, and restart check would be a manual relay through Ray.

## Smallest next step (recommended, bounded, stops before any task run)

If Ray wants to resolve the seam question:
1. Ray installs OpenWorker v0.2.1 from the official release (accepting the
   unsigned-binary/SmartScreen caveat), configured for local Ollama only, no
   connectors or cloud keys.
2. Before running any task, inspect two things and report back:
   - the `openworker-server` local API surface (start it with `--port`, and see
     whether any documented/discoverable endpoint returns run status,
     transcript, or approval events -- not just accepts a submission); and
   - the on-disk state directory (its layout and whether tasks/transcripts/
     approvals are in an inspectable format such as SQLite or JSON).
3. Decide from that alone whether a passive ChatMap recorder is feasible via a
   supported seam, or whether it would require scraping. Only then consider the
   full Phase 3/4 task runs.

This keeps the trust and platform decision with Ray, answers the one question
that blocks everything else, and avoids committing to the full GUI-relayed
experiment before it is warranted.

## Evidence inventory

- This report:
  `C:\Users\ray\eclipse-workspace\openworker-eval-2026-09-14\openworker-source-based-readiness-report-2026-09-14.md`
- No binaries, transcripts, or third-party source were downloaded.

## Commands / actions run (none changed system or repo state)

- `git rev-parse HEAD` / `git status` on ChatMap (read-only).
- Web searches and page fetches: openworker.com, github.com/andrewyng/openworker
  (README, releases), and independent coverage. Read-only network reads.

## Sources

- https://github.com/andrewyng/openworker (README, releases)
- https://openworker.com/
- https://github.com/andrewyng/aisuite
- https://www.marktechpost.com/2026/07/23/andrew-ng-just-released-openworker-an-open-source-local-first-desktop-ai-coworker-that-returns-finished-deliverables-instead-of-chat/
- https://theaiagentindex.com/agents/openworker
- https://www.everydev.ai/tools/openworker
