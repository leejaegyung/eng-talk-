#!/usr/bin/env python3
"""Mechanically enforce the architecture and security rules in docs/architecture.md.

Usage: python3 -I scripts/arch_lint.py [repo_root]
Exit code: 0 = pass, 1 = violations found.
"""
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
LIB = ROOT / "apps" / "flutter_app" / "lib"

IMPORT_RE = re.compile(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""", re.M)

# (layer-of-file, forbidden-import-pattern, why)
LAYER_RULES = [
    ("domain", re.compile(r"^package:flutter/"), "domain은 순수 Dart여야 함 (Flutter 의존 금지)"),
    ("domain", re.compile(r"(^|/)(data|features|app)/"), "domain은 data/features/app을 import할 수 없음"),
    ("domain", re.compile(r"^package:(http|dio|drift|flutter_secure_storage|riverpod|flutter_riverpod)/"),
     "domain은 인프라 패키지에 의존할 수 없음"),
    ("features", re.compile(r"(^|/)data/"), "features는 data를 직접 import할 수 없음 (domain 인터페이스 + app/di 경유)"),
    ("core", re.compile(r"(^|/)features/"), "core는 features를 import할 수 없음"),
]

# Content rules applied to every lib/ file: (pattern, why, allowed-path-substring)
CONTENT_RULES = [
    (re.compile(r"(?<![\w.])print\("), "print() 금지 — core/logging의 redacting logger 사용", None),
    (re.compile(r"debugPrint\("), "debugPrint() 금지 — core/logging 사용", None),
    # spec §16.2: personal data never reaches logs. Log lines may carry error
    # kinds and codes, not what the learner said or any credential.
    (re.compile(r"_log\.(info|warning|error)\([^;]*\$\{?(text|transcript|content|heard|partial|"
                r"message|answer|reply|turns?|said|draft|key|secret|token|accessToken|refreshToken)\b"),
     "로그에 대화 내용·키를 넣지 말 것 — 오류 종류(runtimeType/코드)만 (spec §16.2)", None),
    (re.compile(r"\bclaude-[a-z0-9-]+\b|\bgpt-[0-9][\w.-]*\b|\bgemini-[0-9][\w.-]*\b"),
     "모델 ID 하드코딩 금지 — provider catalog/설정에서 조회 (spec §6.2)", "provider_catalog"),
]

# API keys may only be touched inside the credential vault.
KEY_TABLE_RE = re.compile(r"\b(api_?key|apiKey|secret)\b", re.I)


def layer_of(rel: Path) -> str:
    return rel.parts[0] if rel.parts else ""


def main() -> int:
    if not LIB.exists():
        print(f"arch_lint: {LIB.relative_to(ROOT)} 없음 — 건너뜀")
        return 0
    violations = []
    for f in LIB.rglob("*.dart"):
        if f.name.endswith((".g.dart", ".freezed.dart")):
            continue
        rel = f.relative_to(LIB)
        text = f.read_text(encoding="utf-8")
        layer = layer_of(rel)
        for imp in IMPORT_RE.findall(text):
            for rule_layer, pat, why in LAYER_RULES:
                if layer == rule_layer and pat.search(imp):
                    violations.append(f"{rel}: import '{imp}' — {why}")
        for pat, why, allowed in CONTENT_RULES:
            if allowed and allowed in str(rel):
                continue
            for m in pat.finditer(text):
                line = text.count("\n", 0, m.start()) + 1
                violations.append(f"{rel}:{line}: {why}")
        # Drift table definitions must never declare a key column.
        if "data/db" in str(rel) and KEY_TABLE_RE.search(text):
            violations.append(f"{rel}: DB 스키마에 API 키/secret 컬럼 금지 — vault_key_ref만 허용 (spec §9.2)")
    if violations:
        print("arch_lint: 위반 발견")
        for v in violations:
            print("  -", v)
        print("규칙 근거: docs/architecture.md, docs/security.md")
        return 1
    print("arch_lint: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
