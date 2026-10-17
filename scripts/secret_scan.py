#!/usr/bin/env python3
"""Detect real-looking provider API keys.

Usage:
  python3 -I scripts/secret_scan.py [repo_root]      # scan tracked/untracked repo files
  python3 -I scripts/secret_scan.py --stdin           # scan text from stdin (used by hooks)
Exit code: 0 = clean, 1 = secret found.

Test fixtures must use obviously fake keys such as `sk-FAKE-...`, which are ignored.
"""
import re
import subprocess
import sys
from pathlib import Path

PATTERNS = [
    ("Anthropic key", re.compile(r"sk-ant-[A-Za-z0-9_-]{20,}")),
    ("OpenAI key", re.compile(r"sk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{32,}")),
    ("Google API key", re.compile(r"AIza[0-9A-Za-z_-]{35}")),
    ("Private key block", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
]
FAKE_MARKERS = ("FAKE", "EXAMPLE", "DUMMY", "xxxxxxxx", "XXXXXXXX")
SKIP_DIRS = {".git", "build", ".dart_tool", "node_modules", ".claude", ".agents", "Pods"}


def find(text: str):
    hits = []
    for name, pat in PATTERNS:
        for m in pat.finditer(text):
            if any(mark in m.group(0) for mark in FAKE_MARKERS):
                continue
            hits.append((name, text.count("\n", 0, m.start()) + 1))
    return hits


def repo_files(root: Path):
    try:
        out = subprocess.run(
            ["git", "ls-files", "-co", "--exclude-standard"],
            cwd=root, capture_output=True, text=True, check=True,
        ).stdout.splitlines()
        return [root / p for p in out]
    except (subprocess.CalledProcessError, FileNotFoundError):
        return [p for p in root.rglob("*") if p.is_file() and not SKIP_DIRS & set(p.parts)]


def main() -> int:
    if "--stdin" in sys.argv:
        hits = find(sys.stdin.read())
        for name, line in hits:
            print(f"secret_scan: {name} 의심 (line {line})")
        return 1 if hits else 0
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
    found = False
    for f in repo_files(root):
        if not f.is_file() or f.stat().st_size > 2_000_000:
            continue
        try:
            text = f.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for name, line in find(text):
            print(f"secret_scan: {f.relative_to(root)}:{line}: {name} 의심")
            found = True
    if not found:
        print("secret_scan: OK")
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
