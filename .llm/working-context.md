---
id: OW-CTX-01
lifecycle: working
status: active
provenance: git-history
---
# OpenWorker Working Context

Updated: 2026-10-12

## Project Status

**PAUSED.** The bounded OpenWorker evaluation is complete. No adoption or
ChatMap integration decision has been made. One optional final experiment is
defined below; otherwise this project may be archived.

## Purpose of This Project

This repository preserves the OpenWorker evaluation that began inside ChatMap.
It owns OpenWorker installation, configuration, runtime, stability, and model
evidence. It does not own ChatMap's architecture or durable ledger.

## Established Findings

- OpenWorker v0.2.1 exposes promising local SQLite evidence: journal entries,
  audit events, sessions, team records, approvals, decisions, and related
  hashes can potentially be observed without UI scraping.
- OpenWorker is a possible executor or harness. ChatMap remains the durable
  owner of accepted continuity, provenance, history, and semantic knowledge.
- OpenWorker's SQLite records are candidate evidence for ChatMap, not a
  replacement for ChatMap's ledger.
- MCP is present as a client-side facility. No usable A2A or external recorder
  interface was established.
- A 4096-token Ollama context caused looping with `qwen2.5:7b`; 16384 stopped
  the loop, but the model then fabricated analysis, a tool call, and success.
  No trustworthy artifact was produced.
- Voice input crashed OpenWorker reproducibly, and the Windows installer was
  unsigned.

The overall verdict is **INCONCLUSIVE**: the evidence seam is promising, but a
reliable live task and restart-persistence path were not proved.

## Ownership Boundary

Execution runtimes are replaceable. OpenWorker owns its execution details;
ChatMap owns durable continuity and provenance. A future integration, if
justified, should be a read-only boundary adapter that imports selected
OpenWorker evidence. ChatMap must not become OpenWorker's scheduler or harness.

The full transition is recorded in
`handoffs/handoff-chatmap-to-openworker-ownership-transition-2026-10-12.md`.

## Optional Final Experiment

Run one bounded `qwen2.5:14b` evaluation in a disposable workspace:

1. complete one grounded read/write task and verify the resulting file hash;
2. produce one deliberate failure or blocked task;
3. close and reopen OpenWorker;
4. verify preservation of the successful artifact, failure reason, decisions,
   audit evidence, and any journal/team records; and
5. compare the observed SQLite evidence read-only with ChatMap's existing
   lifecycle concepts.

Do not connect email, Slack, calendar, cloud accounts, or a real project. This
is an OpenWorker capability test, not a ChatMap integration task.

If Ray declines this experiment, or it adds no material evidence, archive the
project. Do not expand into additional models, connectors, orchestration, or
production integration without a new explicit decision.

## Historical Evidence

The dated reports and evidence files at the repository root record the original
evaluation. They are historical evidence, not the current agenda. The
`pinned-checkout-1000f86/` directory is a preserved ChatMap specimen; documents
inside it belong to that snapshot and are not OpenWorker project instructions.

