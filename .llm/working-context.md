---
id: OW-CTX-01
lifecycle: working
status: paused
provenance: user-supplied-runtime-evidence
---
# OpenWorker Working Context

Updated: 2026-10-12

## Project Status

**PAUSED. Verdict: PROMISING for the bounded 14B configuration.**
The optional final experiment is complete within the limits below.
Ray authorized preserving the result and pausing further experiments.
No adoption or ChatMap integration decision has been made.

Read `../openworker-bounded-14b-evaluation-report-2026-10-12.md` for
configuration, session ID, artifact hashes, tool evidence and limitations.

## Purpose and Ownership

This repository owns OpenWorker evaluation evidence and runtime details.
OpenWorker is a possible executor; ChatMap owns accepted continuity,
provenance, history and semantic knowledge. A future adapter, if justified,
would import evidence read-only without making ChatMap a scheduler or harness.

The historical ownership transition remains in
`handoffs/handoff-chatmap-to-openworker-ownership-transition-2026-10-12.md`.

## Current Evidence

- Ray ran the disposable self-test with qwen2.5:14b, Q4_K_M, a confirmed
  16,384-token context, and interactive session mode.
- Terminal checks confirmed real outputs: blue/7, green/11, red/5, total 23.
- SQLite audits confirm input reads, output writes and readbacks. Four writes
  targeted two files: creation followed by overwriting each.
- A missing-file task received an honest blocked response grounded in an
  audited filename search returning []. The file remained absent.
- Ray confirmed both responses survived closing and reopening. Artifact
  hashes matched before and after; post-reopen SQLite reads found the session,
  audits and standing write approval (always_tool).
- No journal_entries or team_events were recorded for the tested session.
- Verify actual chat model selection and Ollama server context. Registration
  in Settings and a one-time model warm-up were insufficient.

## Limits and Historical Findings

The blocked outcome is conversational; a structured lifecycle state was not
established. Both tasks were turns in one session. Team operation, hash-chain
integrity, denied approvals, general reliability and a supported observer
contract remain unproved. SQLite's undocumented schema is not a stable
integration contract.

September fabrication and workspace-configuration failures remain historical
evidence. Earlier reports record voice crashes, an unsigned installer,
client-side MCP and no established A2A recorder seam. Version v0.2.1 is the
historical installed version; the live version was not independently rechecked.

## Next Work

None is authorized automatically. Preserve the result and pause. Additional
models, teams, connectors, orchestration, unattended work or ChatMap
integration require a new explicit decision.

Close OpenWorker normally and stop the temporary Ollama server when finished.
Cleanup has not been independently verified.

## Historical Evidence

Preserve earlier reports and snapshots unchanged. The preserved
`pinned-checkout-1000f86/` is historical ChatMap evidence, whose documents are
not current OpenWorker instructions.
