#!/usr/bin/env bash
# The docs in this repo are what an agent acts on. If speakpen.app adds, renames or drops an
# MCP tool, the docs go stale silently. This compares the live tool list against README.md
# and fails on any difference, in either direction.
#
# SpeakPen's tools read your own notes, so tools/list needs a token:
#   SPEAKPEN_TOKEN=<API token from speakpen.app/app → Settings → Connections → Developers> scripts/check-tools.sh
set -euo pipefail

endpoint="${SPEAKPEN_MCP_URL:-https://speakpen.app/mcp}"
token="${SPEAKPEN_TOKEN:?set SPEAKPEN_TOKEN to an API token}"
doc="$(dirname "$0")/../README.md"

live="$(curl -sf -X POST "$endpoint" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H "Authorization: Bearer $token" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
  | jq -r '.result.tools[].name' | sort)"

if [ -z "$live" ]; then
  echo "Could not read tools/list from $endpoint" >&2
  exit 1
fi

documented="$(grep -oE '^\| `[a-z_]+` \|' "$doc" | tr -d '|` ' | sort)"

if [ "$live" != "$documented" ]; then
  echo "Tool list drifted from README.md" >&2
  diff <(echo "$documented") <(echo "$live") --label documented --label live >&2 || true
  exit 1
fi

echo "OK: $(echo "$live" | wc -l | tr -d ' ') tools documented, matching $endpoint"
