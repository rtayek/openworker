# Cold-start handoff — OpenWorker evaluation

- Date: 2026-09-16
- For: a fresh agent starting a new chat in this repo with no prior context.
- Repo: `openworker-eval-2026-09-14`, branch `experiment/openworker-self-test`.
- First: read `CLAUDE.md` → `AGENTS.md` → `.llm/index.md` (repo rules), then this file.

## What this project is

This repo is an **evidence / evaluation workspace**, NOT product code. The task:
evaluate **OpenWorker** (github.com/andrewyng/openworker, v0.2.1) as an external
agent runtime whose executed work **ChatMap** could later *record* (continuity,
provenance, lifecycle, artifacts) — without ChatMap becoming the scheduler/harness.

ChatMap itself is inspected **read-only** against a pinned snapshot,
commit `1000f865...` (in `pinned-checkout-1000f86/`). No ChatMap code/schema/data
is changed. No cloud connectors/keys used so far — everything has been local.

## Current verdict: INCONCLUSIVE (see `openworker-bounded-evaluation-report-2026-09-14.md`)

- **Promising seam:** OpenWorker persists work to real, structured, hash-chained
  on-disk SQLite that maps cleanly onto ChatMap's lifecycle ledger, readable
  read-only without UI scraping.
- **But no genuinely successful task run has ever been observed.** Every run so far
  used the local model `qwen2.5:7b` via Ollama, which is inadequate for this task.

## Findings so far (evidence in `stability-notes.md`)

1. **Voice input crashes the whole app** (desktop + server), reproducible in v0.2.1.
   Avoid it.
2. **Context-truncation looping (FIXED, was a real bug):** Ollama ran qwen2.5:7b at
   `n_ctx=4096`, truncating the agentic prompt + history → agent forgot the task and
   looped (144x `list_scheduled_tasks`). Fix: `OLLAMA_CONTEXT_LENGTH=16384` (see
   `run-openworker-16k.sh`, `Modelfile.qwen16k`).
3. **Fabrication (NOT fixable by config — model-capability failure).** After the 16k
   fix, qwen2.5:7b stopped looping but fabricated results in three observed flavors,
   all in OpenWorker session `a613f543-71a` under auto-approve:
   - hallucinated the **contents** of `WorkerLifecycleService.java` (a file it never
     read; claimed symbols like `worker_init_logging`, `handle_request` that occur 0x
     in the real 241-line source);
   - faked a `writing_file(...)` call + "The report artifact has been created" — **no
     file was ever written** (sandbox `C:\Users\ray\OpenWorker\a613f543-71a\` empty);
   - (latest, 2026-09-16) invented **fake tool syntax** — `todo_write([...])`,
     `todo_read_file(...)` — which are **not real OpenWorker tools**, then narrated
     progress. Audit trail (`audit_events`) shows only real calls: `list_files` (x2)
     + `mode_changed`. Still no read, still no artifact.

## How to distinguish a REAL run from fabrication

- A real (capable-model) run: the **Ollama log stops getting hit** (its last call goes
  stale), `audit_events` shows **actual read tools firing**, and a **real artifact
  appears on disk**. If Ollama is still being called and audit shows only `list_files`,
  it's local qwen fabricating — do not trust its prose.

## THE open next step (this is the decision point)

The report's recommended cheap next step, deliberately deferred to Ray:

> **Do one capable-cloud-model run.** In OpenWorker: model picker → Anthropic (Claude
> key), interactive mode, point at the snapshot root. Re-send the task. Only then do we
> finally get: a genuine successful run, the fabrication test, and the
> persistence-across-restart / team-journal path exercised with real data.

Alternative: **stop** — the local result is already documented and committed; the eval
can rest at INCONCLUSIVE with a clear, cheap unblock.

Ask Ray which of these before doing anything with OpenWorker.

## Bounded self-test fixture (in progress)

`self-test/` is a sandbox task to reliably catch fabrication: OpenWorker must read
input files (`self-test/input/` — alpha/beta/gamma fixtures), write
`self-test/output/summary.md` + an honest `run-report.md`. Facts are checkable:
**expected total count = 23**. Merely claiming a file was written does not count.

## Cleanup (only if stopping)

- Close OpenWorker (desktop + server).
- Revert Ollama context to 4096 (undo `OLLAMA_CONTEXT_LENGTH=16384`).
- `ollama rm qwen2.5-7b-16k`.

## Map of the repo

- Reports: `openworker-bounded-evaluation-report-2026-09-14.md` (live-run, main verdict),
  `openworker-source-based-readiness-report-2026-09-14.md` (source readiness).
- Evidence log: `stability-notes.md`. Schema notes: `journal-schema-findings.md`.
- Snapshot: `pinned-checkout-1000f86/`. Installer: `installer/`.
- Captured run evidence: `live-read*/`, `pulse*/`, `journal-snapshot*/`, `worker-a-artifact/`.
- Launchers: `run-openworker-16k.sh`, `start-a2a-ollama.sh`, `Modelfile.qwen16k`.

Note: "Remote Control disconnected" (seen in the claude.ai web UI) is unrelated to
OpenWorker — it means the local Claude Code process running a web session went offline.
