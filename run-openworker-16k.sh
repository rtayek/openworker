#!/bin/sh
# run-openworker-16k.sh
#
# Start OpenWorker against a fresh Ollama server using a 16384-token context.
# The clean shutdown matters because OLLAMA_CONTEXT_LENGTH is read by the
# Ollama server process, not by OpenWorker. If an old Ollama server survives,
# OpenWorker can silently reconnect to the old 4096-token configuration.
#
# In OpenWorker after running this: select the plain "qwen2.5:7b" model.
#
# Reverting: restart Ollama normally (or reboot). The environment variable only
# applies to the Ollama server started by this script.

set -eu

ctx=16384
ollamaExe="/c/Users/ray/AppData/Local/Programs/Ollama/ollama.exe"
openworkerExe="/c/Users/ray/AppData/Local/OpenWorker/openworker-desktop.exe"
ollamaLog="/c/Users/ray/AppData/Local/Temp/ollama-16k.log"

export OLLAMA_CONTEXT_LENGTH="$ctx"

kill_image() {
    image="$1"
    taskkill //F //T //IM "$image" >/dev/null 2>&1 || true
}

image_running() {
    tasklist //FI "IMAGENAME eq $1" 2>/dev/null | grep -qi "$1"
}

echo "Stopping existing OpenWorker and Ollama processes..."
kill_image "openworker-desktop.exe"
kill_image "openworker-server.exe"
kill_image "ollama app.exe"
kill_image "ollama.exe"

# Give Windows a moment to finish tearing down process trees and sockets.
i=0
while [ "$i" -lt 20 ]; do
    if ! image_running "openworker-desktop.exe" \
       && ! image_running "openworker-server.exe" \
       && ! image_running "ollama app.exe" \
       && ! image_running "ollama.exe"; then
        break
    fi
    sleep 1
    i=$((i + 1))
done

if image_running "openworker-desktop.exe" \
   || image_running "openworker-server.exe" \
   || image_running "ollama app.exe" \
   || image_running "ollama.exe"; then
    echo "ERROR: one or more old OpenWorker/Ollama processes are still running." >&2
    tasklist | grep -Ei 'openworker|ollama' || true
    exit 1
fi

echo "Clean process state confirmed."
echo "Starting Ollama with OLLAMA_CONTEXT_LENGTH=$ctx ..."
: >"$ollamaLog"
nohup "$ollamaExe" serve >"$ollamaLog" 2>&1 &

echo "Waiting for Ollama to accept connections..."
i=0
while [ "$i" -lt 30 ]; do
    if curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo "Ollama is up."
        break
    fi
    sleep 1
    i=$((i + 1))
done

if ! curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "ERROR: Ollama did not become ready. See $ollamaLog" >&2
    exit 1
fi

echo "Launching OpenWorker..."
nohup "$openworkerExe" >/dev/null 2>&1 &

echo ""
echo "Done."
echo "  OLLAMA_CONTEXT_LENGTH=$ctx"
echo "  Ollama log: $ollamaLog"
echo "  In OpenWorker: select qwen2.5:7b."
echo "  For the current self-test, set the workspace to this openworker repo,"
echo "  then ask it to read self-test/README.md and perform the test."
