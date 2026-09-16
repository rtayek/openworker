# OpenWorker On-Disk Journal / Team Board: Schema Findings (read-only)

Date: 2026-09-15 (continuation of the 2026-09-14 eval)
Data dir observed: C:\Users\ray\AppData\Roaming\coworker\
Method: copied *.db (+ -wal/-shm) to journal-snapshot/, opened copies read-only
via sqlite3 mode=ro. Live app files were never opened for write. All tables had
0 rows at inspection time (app launched, Ollama configured, no task run yet).

## Answer to Step 4 (journal / team board: real files or UI-only?)

REAL, STRUCTURED, ON-DISK SQLite. Not UI-only. Both the journal and the team
board are append-only, hash-chained SQLite event logs, readable read-only. A
ChatMap recorder could ingest them via existing SQLite/import abstractions
without scraping UI or reverse-engineering a binary format. Caveat: this is an
undocumented v0.2.1 beta schema and may change between releases.

## Databases (C:\Users\ray\AppData\Roaming\coworker\)

journal.db
  journal_entries(seq PK, ts, case_id, kind, actor, actor_role, persona, model,
    session_id, space, item_id, payload TEXT, taint, prev_hash, hash)
  journal_meta(case_id PK, head_hash, created_ts)
  journal_grants(case_id, principal, source, space, item_id)
  -> append-only, hash-chained (prev_hash/hash + head_hash) tamper-evident ledger

coworker.db
  audit_events(id PK, timestamp, session_id, agent, workspace, connector, tool,
    stage, status, approval, args, result_preview, reason, resource, call_id,
    tokens_in, tokens_out, cache_read, cache_write)
  sessions(session_id PK, workspace, model, mode, title, agent, messages, team,
    bindings, grants, compaction, pinned, archived, ...)
  memories(...), workspaces(path PK, last_used), project_names(...)
  -> audit_events carries approval + reason per tool call (decision provenance)

teams.db  (the "team board")
  team_items(space, id, title, description, criteria, state, assignee, creator,
    case_id, refs, created_ts, updated_seq)  -> work items with state/assignee
  team_links(space, src, kind, dst)  -> typed relations between items
  team_events(seq PK, ts, space, kind, actor, actor_role, model, session_id,
    item_id, case_id, recipient, payload, taint, prev_hash, hash)  -> hash-chained
  team_meta(space PK, head_hash, watermark), team_settings, team_cursors

chat.db
  chat_messages(seq PK, group_id, ts, author, author_role, text, mentions)
  chat_groups(group_id PK, name, members, created_ts), chat_cursors

automation.db
  scheduled_tasks(id PK, enabled, next_run, data), task_runs(run_id PK, task_id,
  started_at, data)

## Live API (from logs/openworker-server.log)
- Server: uvicorn ASGI on 127.0.0.1:57587 (openworker-server, PID 48332)
- Versioned REST under /v1: sessions, sessions/{id}/unattended, inbox
  (?session_id=&state=pending), automations, connectors, workspaces/recent,
  cloud/status
- Auth: X-OpenWorker-Token header; desktop uses an in-memory launch token not
  written to disk (so external API calls need a token we do not hold)

## Preliminary ChatMap-ledger mapping (schema-level, pre-run)
- OpenWorker session/case_id      -> ChatMap worker session / assignment
- journal_entries (hash-chained)  -> ChatMap lifecycle events (also hash-chained)
- audit_events.approval/reason    -> ChatMap decision / provenance evidence
- team_items (state/assignee/criteria) -> assignment + definition-of-done
- team_links (src,kind,dst)        -> successor / relationship links
- produced files (deliverables)    -> ChatMap WorkerArtifact (hash + source path)

## Seam verdict (preliminary): PROMISING
Two seams exist: (1) read-only structured SQLite (journal_entries, audit_events,
team_items/team_events) and (2) a token-gated /v1 REST API. The SQLite seam is
the stronger fit for a passive ChatMap recorder. Not yet confirmed with real
data: all tables are empty until a task runs (Step 2). Risk: undocumented beta
schema subject to change.

## State changes
- None to ChatMap. OpenWorker installed + launched + Ollama-configured by Ray.
- Read-only DB copies taken into journal-snapshot/. No task run yet.
