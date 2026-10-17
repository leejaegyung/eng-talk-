#!/usr/bin/env bash
# PreToolUse(Write|Edit): refuse to write content that looks like a real API key.
input="$(cat)"
content="$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // ""')"
root="$(cd "$(dirname "$0")/../.." && pwd)"
if ! report="$(printf '%s' "$content" | python3 -I "$root/scripts/secret_scan.py" --stdin)"; then
  reason="실제 API 키로 보이는 값이 포함되어 쓰기를 차단했습니다. ($report) 테스트에는 sk-FAKE-... 같은 가짜 키를 쓰고, 실제 키는 OS secure storage에만 저장합니다 (docs/security.md)."
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
fi
exit 0
