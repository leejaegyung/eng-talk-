#!/usr/bin/env bash
# Single verification entry point for humans, hooks and CI.
#   scripts/check.sh          full: secrets + architecture + format + analyze + tests
#   scripts/check.sh --fast   cheap gates only (used by the Stop hook)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/flutter_app"
BROKER="$ROOT/services/session_broker"
MODE="${1:-full}"
FAIL=0

step() { printf '\n▶ %s\n' "$1"; }
run() { "$@" || FAIL=1; }

step "secret scan"
run python3 -I "$ROOT/scripts/secret_scan.py" "$ROOT"

step "architecture lint"
run python3 -I "$ROOT/scripts/arch_lint.py" "$ROOT"

if [[ -f "$APP/pubspec.yaml" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    step "dart format (check)"
    run dart format --output=none --set-exit-if-changed "$APP/lib" "$APP/test"
    # `flutter analyze` crashes on non-ASCII project paths (LSP channel bug); `dart analyze` runs the same rules.
    step "dart analyze"
    (cd "$APP" && dart analyze --fatal-infos) || FAIL=1
    if [[ "$MODE" != "--fast" ]]; then
      step "flutter test"
      (cd "$APP" && flutter test) || FAIL=1
    fi
  else
    echo "⚠ flutter 미설치 — Dart 검사 건너뜀 (docs/plans/phase-0-poc.md T0 참고)"
  fi
fi

if [[ "$MODE" != "--fast" && -f "$BROKER/pyproject.toml" ]]; then
  step "broker tests"
  (cd "$BROKER" && python3 -m pytest -q) || FAIL=1
fi

echo
if [[ $FAIL -ne 0 ]]; then echo "✗ check 실패"; else echo "✓ check 통과"; fi
exit $FAIL
