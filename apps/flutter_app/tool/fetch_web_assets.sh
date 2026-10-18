#!/usr/bin/env bash
# Web database engine files (drift on the web), from the packages' official
# GitHub releases, pinned to the versions in pubspec.lock and checked by
# SHA-256. Re-run after upgrading drift or sqlite3, then update the pins.
#   tool/fetch_web_assets.sh
set -euo pipefail
cd "$(dirname "$0")/../web"

SQLITE3_TAG=sqlite3-3.5.2
SQLITE3_SHA=13d3f11d05b39ba0618a7115fb41640a5d48b6300f5d3f325f554b42bd6688a4
DRIFT_TAG=drift-2.35.2
DRIFT_SHA=191fc9db018d2bbecb1723e81118fcf2c5c094df8644c2fcba2ed51df061e90a

fetch() { # repo tag file sha
  curl -fsSL "https://github.com/$1/releases/download/$2/$3" -o "$3.tmp"
  echo "$4  $3.tmp" | shasum -a 256 -c - >/dev/null
  mv "$3.tmp" "$3"
  echo "✓ $3 ($2)"
}
fetch simolus3/sqlite3.dart "$SQLITE3_TAG" sqlite3.wasm "$SQLITE3_SHA"
fetch simolus3/drift "$DRIFT_TAG" drift_worker.js "$DRIFT_SHA"
