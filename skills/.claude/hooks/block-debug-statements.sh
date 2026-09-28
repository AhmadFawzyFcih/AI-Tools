#!/usr/bin/env bash
# PreToolUse(Bash): block `git commit` if staged Ruby contains debug statements.
# Exit 2 = block the tool call and show stderr to Claude.
set -uo pipefail
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  # fallback: pull the "command" string out of the JSON without jq
  cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)"
fi

case "$cmd" in *"git commit"*) ;; *) exit 0 ;; esac

hits="$(git diff --cached --unified=0 -- '*.rb' 2>/dev/null \
  | grep -E '^\+' | grep -vE '^\+\+\+' \
  | grep -nE 'binding\.(pry|irb)|\bbyebug\b|\bdebugger\b|^\+[[:space:]]*(puts|pp?)[[:space:]]' || true)"

if [ -n "$hits" ]; then
  {
    echo "BLOCKED: debug statements found in staged Ruby changes. Remove them before committing:"
    echo "$hits"
  } >&2
  exit 2
fi
exit 0
