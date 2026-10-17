#!/usr/bin/env bash
# PostToolUse(Write|Edit): format the edited Dart file.
f="$(jq -r '.tool_response.filePath // .tool_input.file_path // ""')"
[[ "$f" == *.dart && -f "$f" ]] || exit 0
command -v dart >/dev/null 2>&1 || exit 0
dart format "$f" >/dev/null 2>&1 || true
exit 0
