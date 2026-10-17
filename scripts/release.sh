#!/usr/bin/env bash
# Cut a release: bump pubspec version, verify, commit, tag vX.Y.Z and push.
# The `release` workflow then builds installers and publishes a GitHub Release.
#   scripts/release.sh 0.2.0
set -euo pipefail

VERSION="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/apps/flutter_app/pubspec.yaml"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]]; then
  echo "usage: scripts/release.sh X.Y.Z[-pre]" >&2
  exit 2
fi
cd "$ROOT"
[[ "$(git branch --show-current)" == "main" ]] || { echo "main 브랜치에서만 릴리스" >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "커밋 안 된 변경이 있음" >&2; exit 1; }
git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null && { echo "v$VERSION 태그가 이미 있음" >&2; exit 1; }

# Build number in pubspec is local-only; CI uses the workflow run number.
sed -i '' -E "s/^version: *[^+]*/version: $VERSION/" "$PUBSPEC"
scripts/check.sh

git add "$PUBSPEC"
git commit -m "release: v$VERSION"
git tag -a "v$VERSION" -m "v$VERSION"
git push origin main "v$VERSION"
echo "✓ v$VERSION 푸시됨 — Actions의 release 워크플로가 설치 파일을 릴리스에 올린다"
