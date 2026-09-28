#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): when routes or API controllers change, remind Claude of the API rules.
# Exit 2 on PostToolUse shows stderr to Claude without undoing anything.
set -uo pipefail
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

case "$file" in
  *config/routes.rb|*app/controllers/api/*)
    echo "REMINDER (api-endpoints rule): you changed $file. Before this phase is done: update config/initializers/init_dr_permissions.rb, add/update the rswag spec in spec/integration/, run 'bundle exec rake rswag:specs:swaggerize', and implement V2 if it was confirmed." >&2
    exit 2 ;;
esac
exit 0
