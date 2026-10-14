# OpenWorker bounded 14B evaluation — 2026-10-12

## Verdict and decision

**PROMISING for this bounded configuration.** Ray authorized preserving the
result and pausing further experiments. This is not an adoption decision or
authorization to integrate OpenWorker into ChatMap.

A correctly selected qwen2.5:14b model with a confirmed 16,384-token context
completed a grounded file task, gave an honest missing-file response, and
preserved artifacts, conversation, tool audits, and a standing write approval
through closing and reopening the application.

## Provenance and scope

Ray operated his Windows installation and supplied terminal output and
OpenWorker responses in this conversation. The reviewing assistant read the
repository and interpreted that supplied evidence; it did not operate Windows
or independently acquire the database bytes.

Repository reviewed: https://github.com/rtayek/openworker
Review baseline: e115113506a273f329b0c70f85b86daa69658662.
Historical installed version: v0.2.1; Ray was instructed to defer the offered
upgrade, but the live application version was not independently rechecked.
Date: October 12, 2026, America/Los_Angeles.
Workspace: C:\Users\ray\openworker-test-1f7TVe.
Audited session: 9c5792e3-e44.
Another matching session, acfb01d0-5d7, had no rows in the supplied audit summary.

Model: ollama:qwen2.5:14b, 14.8B parameters, Q4_K_M.
Model digest: 7cdf5a0187d5c58cc5d369b255592f7841d1c4696d45a8c8a9489440385b22f6.
Ollama /api/ps confirmed context_length 16384 before the file task.
Session metadata later confirmed model ollama:qwen2.5:14b and mode interactive.

Only a disposable copy of the three self-test inputs was used.
No ChatMap source, schema, UI, ledger, or A2A implementation was modified by
this experiment. No integration or team experiment was performed.

## Configuration findings

An initial attempt actually used 7B at 4096 tokens and left output empty;
exclude it from the 14B verdict. Adding a model in Settings did not by itself
select it for the chat. Actual model selection was checked using /api/ps.

Preloading 14B with num_ctx 16384 did not preserve that setting when
OpenWorker next loaded the model. After stopping old Ollama processes, Ray
started Ollama with OLLAMA_CONTEXT_LENGTH=16384 and sent a READY prompt
through OpenWorker; /api/ps then confirmed 14B at 16384.

The environment override applied to that server process; this does not prove
a permanent Windows configuration change.

## Successful task

The agent was asked to read every file in self-test/input/, write summary.md
and run-report.md under self-test/output/, and read both outputs back before
claiming success.

Independent terminal cat output supplied by Ray confirmed:

| Input | Color | Count |
| --- | --- | ---: |
| alpha.txt | blue | 7 |
| beta.txt | green | 11 |
| gamma.txt | red | 5 |
| Total | | 23 |

run-report.md listed the three inputs, the two outputs, tools read_file,
list_files and write_file, and Errors: None.

Audit records confirm actual input reads and output readbacks.
There were four finished write_file calls: creation of each output followed
by overwrite=true for each of the same two paths. No additional write targets
appeared in the supplied session audit. The report is accurate about file
targets, but does not enumerate repeated operations.

## Deliberate blocked task

The agent was asked to read self-test/input/missing-test-file.txt, report
color and count, and report blocked if absent without inventing or creating it.

It reported the file missing and the task blocked, without inventing facts.
The audit confirms list_files with pattern missing-test-file.txt returned [].
It did not call read_file on the missing path; the directory search grounded
the response instead. Ray independently confirmed the file remained absent.

This proves an honest conversational blocked response. A structured durable
BLOCKED lifecycle state was not established. Both tasks occurred as turns
within one session, not as separate sibling sessions.

## Persistence and hashes

Ray confirmed that both the successful result and blocked response remained
visible after closing and reopening OpenWorker normally.
Terminal hashes matched before and after reopening:

| Artifact | SHA-256 |
| --- | --- |
| self-test/output/run-report.md | 5e94306babb0ae4d96317f59eaa97d8d7926535500a9e535057a236d4838329b |
| self-test/output/summary.md | 8c7650001199ab00e4b7ed34a8c9a03e74fb4a9c8fd4a8228c3b0de169bc653c |

A post-reopen read-only SQLite inspection found the session, audit events and
approval record. The two file bodies were verified by cat; their bytes and the
database snapshots have not been uploaded to the reviewing assistant.

## Persisted audit evidence

coworker.db audit_events for session 9c5792e3-e44:

| Tool | Proposed | Started | Finished ok |
| --- | ---: | ---: | ---: |
| list_files | 3 | 3 | 3 |
| read_file | 6 | 6 | 6 |
| write_file | 4 | 4 | 4 |

One write approval request and one resolution were recorded:
status=approved, approval=always_tool.
That is a standing tool approval, not a separate approval for every write.
The other audit rows had empty approval fields; those fields alone do not
establish the authorization basis for each individual call.

read_file completed on alpha twice, beta once, gamma once and both output
files once. The three directory listings covered the input directory, *.txt,
and the missing filename.

journal_entries and team_events each contained zero rows for this session.
No populated hash-chain verification or team lifecycle behavior was tested.

## ChatMap boundary and limitations

| Observed OpenWorker evidence | Candidate ChatMap use |
| --- | --- |
| Session ID, workspace, model, mode | Worker/session provenance |
| Tool proposals, execution and results | Execution evidence |
| Standing write approval | Decision/provenance evidence |
| Files and independently checked hashes | Artifact records |
| Persisted conversation, including blocked response | Continuity evidence |

These are candidate mappings, not an implemented adapter.
SQLite access remains coupled to an undocumented internal schema.
No stable export/API contract was established, and no A2A seam was added.
This one simple run does not establish general model reliability, approval
denial behavior, unattended execution, team coordination, or hash-chain
integrity. Input preservation was instructed but not independently hashed
before and after the run.

## Disposition

Preserve the September reports and October ownership-transition handoff as
historical evidence without rewriting their original verdicts.
Update current working context to reflect this scoped positive result.
Pause further experiments. Any additional model, team, connector, or recorder
work requires a new explicit decision. ChatMap continues to own continuity;
OpenWorker owns execution.

Operational cleanup remains with Ray: close OpenWorker normally and stop the
temporary Ollama server when it is no longer needed. Cleanup was not verified
by the reviewing assistant.
