- 2026-09-15T23:37:18Z: voice-input attempt crashed the entire app; openworker-desktop and openworker-server both exited, :57587 stopped, no traceback in server access log. Recovered by relaunch. Finding: voice feature unstable in v0.2.1; avoid it. No task had been submitted yet (server log showed only UI polling GETs).
- 2026-09-15T23:38:49Z: voice-input crashed the app AGAIN (2nd occurrence) -> reproducible. Ray restarted manually. Confirms v0.2.1 voice input is unstable; do not use it.

## ROOT CAUSE of the failed/looping runs (evidence: Ollama server.log)
- OpenWorker -> Ollama via POST /v1/chat/completions (OpenAI-compat), 56 calls, all 200 OK in ~1-2s. Connectivity fine; model responds.
- Ollama runs qwen2.5:7b at n_ctx_slot = 4096 (90/90 slot inits) despite the model supporting 32768.
- Agentic prompt ~2050 tokens/turn; log shows 88 "truncated" / 54 "truncating" with n_keep = 4.
- Sampling temperature = 1.000 on 54 calls (plus some 0.0/0.2).
- Effect: system prompt + tool schemas + growing step history exceed the 4096 window; Ollama truncates history to ~4 tokens, so the agent forgets the task and prior steps and loops (144x list_scheduled_tasks). "No answer" = context-amnesia loop, not a hang.
- Primary lever = Ollama context window (server config, not OpenWorker/ChatMap). Candidate fix: OLLAMA_CONTEXT_LENGTH=16384 (or a derived Modelfile with PARAMETER num_ctx), then restart Ollama. Temperature is set per-call by OpenWorker and not directly controllable from Ollama.

## Worker A result: mechanical success, SEMANTIC FABRICATION (key finding)
- After the 16k context fix, qwen2.5:7b stopped looping and produced the artifact
  openworker-chatmap-readonly-report.md (written to the session sandbox
  C:\Users\ray\OpenWorker\a613f543-71a\, NOT the snapshot root).
- The report is entirely fabricated. Verified against the real 241-line
  WorkerLifecycleService.java: claimed symbols worker_init_logging, handle_request,
  start(), stop(), LoggingService, ThreadService, TaskScheduler -> 0 occurrences each.
  Cited lines 28/45/58/65-70 do not match (real: null-check, insertAssignment,
  transition delegation). The model hallucinated from the class name; it never read
  the file (no file-content read tool call in audit_events; snake_case names are not
  even Java style).
- OpenWorker under auto-approve wrote the fabrication to disk and reported success
  ("The report artifact has been created."). The harness did not detect or prevent
  fabrication. Confirms the handoff's warning: producing a file != correct claims.
- Conclusion: local qwen2.5:7b is inadequate for this agentic task in OpenWorker.
  The earlier looping was a fixable context-truncation bug; this is a model-capability
  failure (hallucination instead of grounding), not fixable by configuration.

## CORRECTION to the Worker A note above
- No artifact was actually written. The session sandbox
  C:\Users\ray\OpenWorker\a613f543-71a\ is EMPTY; the file exists nowhere on disk;
  and audit_events for the session shows ONLY list_files + mode_changed -- NO write
  tool event. qwen2.5:7b emitted a fake writing_file(...) call as prose plus a false
  "The report artifact has been created" confirmation. OpenWorker did not execute a
  real write and did not flag the fabricated tool-call/success.
- Net Worker A outcome: the model never read the source, fabricated the analysis,
  AND fabricated the file-write and success message. Only real tool call: list_files.
  Definitive: local qwen2.5:7b is unusable for this task in OpenWorker.
