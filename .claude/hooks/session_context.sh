#!/usr/bin/env bash
# SessionStart: hand the current progress board to Claude so every session resumes from the same state.
root="$(cd "$(dirname "$0")/../.." && pwd)"
p="$root/docs/plans/PROGRESS.md"
[[ -f "$p" ]] || exit 0
echo "## 현재 진행 상황 (docs/plans/PROGRESS.md)"
cat "$p"
command -v flutter >/dev/null 2>&1 || echo "⚠ 이 머신에 flutter가 없습니다. Dart 검증은 건너뛰어집니다."
exit 0
