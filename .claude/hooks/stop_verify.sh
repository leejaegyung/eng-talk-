#!/usr/bin/env bash
# Stop: run the fast gates; if they fail, send Claude back to fix them (once).
input="$(cat)"
[[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" == "true" ]] && exit 0
root="$(cd "$(dirname "$0")/../.." && pwd)"
if ! out="$("$root/scripts/check.sh" --fast 2>&1)"; then
  jq -n --arg r "scripts/check.sh --fast 실패. 아래 위반을 고친 뒤 종료하세요:
$(printf '%s' "$out" | tail -40)" '{decision:"block",reason:$r}'
fi
exit 0
