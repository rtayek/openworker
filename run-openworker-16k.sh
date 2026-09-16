#!/bin/sh
# run-openworker-16k.sh
#
# Make Ollama serve models with a 16384-token context window, then launch
# OpenWorker. OpenWorker was driving Ollama at the 4096 default, so its agentic
# prompt plus tool/step history overflowed and got truncated, causing the agent
# to forget its task and loop. OLLAMA_CONTEXT_LENGTH is read by the OLLAMA
# SERVER (not by OpenWorker), so this script restarts Ollama with the variable
# set, then starts OpenWorker, which simply reconnects over HTTP.
#
# In OpenWorker after running this: pick the plain "qwen2.5:7b" model. It now
# runs at 16k, because the server default changed.
#
# Reverting: just restart Ollama normally (or reboot); the variable only affects
# the server this script starts.

set -eu

ctx=16384
ollamaExe="/c/Users/ray/AppData/Local/Programs/Ollama/ollama.exe"
openworkerExe="/c/Users/ray/AppData/Local/OpenWorker/openworker-desktop.exe"
ollamaLog="/c/Users/ray/AppData/Local/Temp/ollama-16k.log"

export OLLAMA_CONTEXT_LENGTH="$ctx"

echo "Stopping running OpenWorker and Ollama..."
taskkill //F //T //IM openworker-desktop.exe >/dev/null 2>&1 || true
taskkill //F //IM openworker-server.exe      >/dev/null 2>&1 || true
taskkill //F //IM "ollama app.exe"           >/dev/null 2>&1 || true
taskkill //F //IM ollama.exe                 >/dev/null 2>&1 || true
sleep 2

echo "Starting Ollama with OLLAMA_CONTEXT_LENGTH=$ctx ..."
nohup "$ollamaExe" serve >"$ollamaLog" 2>&1 &

echo "Waiting for Ollama to accept connections..."
i=0
while [ "$i" -lt 30 ]; do
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo "Ollama is up."
        break
    fi
    sleep 1
    i=$((i + 1))
done

echo "Launching OpenWorker..."
nohup "$openworkerExe" >/dev/null 2>&1 &

echo ""
echo "Done."
echo "  OLLAMA_CONTEXT_LENGTH=$ctx   (server log: $ollamaLog)"
echo "  In OpenWorker: select model qwen2.5:7b (now runs at ${ctx}-token context),"
echo "  set the folder to the pinned-checkout snapshot, then send your task."
