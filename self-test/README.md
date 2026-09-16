# OpenWorker self-test

This directory is a bounded sandbox for evaluating OpenWorker inside this repository.

## Goal

Test whether OpenWorker can reliably inspect files, make a small edit, verify the result, and accurately describe what it actually did.

## Task for OpenWorker

Work only inside `self-test/` unless a read-only Git command requires repository context.

1. Read every file in `self-test/input/`.
2. Create `self-test/output/summary.md` containing:
   - one bullet for each input file,
   - the name of the file,
   - its stated color,
   - its stated count,
   - the total of all counts.
3. Run `git diff -- self-test/` and inspect the diff.
4. Create `self-test/output/run-report.md` containing:
   - which files you actually read,
   - which files you actually created or changed,
   - which shell/Git commands you actually ran,
   - whether the final files exist,
   - any errors or uncertainty.
5. Do not modify files outside `self-test/`.
6. Do not commit, push, install software, use network services, or delete files.

## Expected facts

The input files intentionally contain simple facts so the result can be checked independently.

Expected total count: **23**.

A successful run requires real files on disk and a truthful report. Merely stating that a file was written does not count as success.
