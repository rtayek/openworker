# OpenWorker Install + Read-Only Inspection Evidence

Date: 2026-09-14 (session continued 2026-09-15)
ChatMap commit at time of work: 2ba3ead2b81b578ded90725b145749ae58f331ca (clean)

## Installer
- Source: github.com/andrewyng/openworker release v0.2.1
- File: OpenWorker-windows-setup.exe, 62,059,003 bytes
- SHA-256: a4fa05ee25036112ca06cb484ee98663306f79ad486ce8c34d58542813b26dfa
- Signing: unsigned (the .sig is a Tauri updater signature, not Authenticode)
- Install method: silent per-user NSIS install (`OpenWorker-windows-setup.exe /S`), exit 0
- No admin required. Uninstall via %LOCALAPPDATA%\OpenWorker\uninstall.exe

## Installed layout (%LOCALAPPDATA%\OpenWorker)
- openworker-desktop.exe  (~18 MB, Tauri GUI shell)
- sidecar\openworker-server.exe  (~22 MB, PyInstaller-frozen Python agent server)
- sidecar\_internal\  (bundled Python 3.12 runtime + deps)
- uninstall.exe
- Start Menu shortcut: OpenWorker.lnk

## Server CLI (openworker-server --help)
usage: openworker-server [-h] [--cwd CWD] [--model MODEL]
   [--mode {discuss,plan,interactive,auto,bypass-approvals,auto-approve}]
   [--host HOST] [--port PORT]

## Bundled stack (from _internal dist-info; direct observation)
- uvicorn 0.52.4 + websockets 16.1.1  -> ASGI HTTP server, websocket-capable
- mcp 1.29.1  -> Model Context Protocol SDK bundled
- SQLite via _sqlite3.pyd; NO SQLAlchemy/Alembic  -> raw sqlite or JSON persistence likely
- textual 8.2.8  -> TUI framework present (possible terminal interface)
- pydantic 2.13.4, jsonschema 4.26.0, pypdf 6.16.2, boto3, cryptography, httpx2
- OpenWorker app code + aisuite are frozen into the exe (base_library.zip); routes/storage
  paths not readable without unpacking (not done: reverse-engineering, discouraged)

## Confirmed vs pending
- Confirmed: install clean; server CLI surface; ASGI+WS server; MCP SDK; SQLite available;
  approval-mode ladder exists.
- Pending first GUI launch (creates data dir): exact on-disk state/journal location and
  format (SQLite vs JSON vs UI-only); live HTTP/WS endpoint list; whether the journal is a
  stable, readable on-disk artifact (the Step 4 seam question).

## State changes made
- Installed OpenWorker per-user (reversible via uninstall.exe). No connectors, no cloud
  keys, no network task run. App not yet launched. No ChatMap repo changes.
