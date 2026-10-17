# AI English Speaking Coach

BYOK(사용자 API 키) 기반 영어 회화 코치 앱. Flutter 단일 코드베이스로 Windows/macOS/Android/iOS 지원.
이 파일은 **지도**다. 세부 내용은 링크된 문서가 원본(source of truth)이다.

## 먼저 읽을 것
- 현재 상태와 다음 작업: `docs/plans/PROGRESS.md` (세션 시작 시 자동 주입됨)
- 제품 원본 설계서: `AI_English_Speaking_App_Development_Spec.md`
- 확정된 결정: `docs/decisions.md` — 여기 있는 결정을 임의로 뒤집지 말 것. 바꿔야 하면 사용자에게 묻고 새 항목 추가
- 구조/레이어 규칙: `docs/architecture.md`
- 보안 불변식: `docs/security.md`
- 작업 방식과 완료 기준: `docs/workflow.md`

## 명령어
```bash
scripts/check.sh          # 전체 검증: 시크릿 + 아키텍처 + format + analyze + test
scripts/check.sh --fast   # 빠른 검증 (Stop 훅이 자동 실행)
cd apps/flutter_app && flutter run -d macos   # 앱 실행
scripts/release.sh 0.2.0  # 버전 릴리스: 태그 push → GitHub Release에 설치 파일 (ADR-010)
```

## 절대 규칙 (훅·린트로 강제됨)
1. API 키는 `CredentialVault`(OS secure storage) 외부에 저장·로그·출력 금지. DB에는 `vault_key_ref`만.
2. `domain/`은 순수 Dart. `features/`는 `data/`를 직접 import하지 않는다.
3. `print`/`debugPrint` 금지 → `core/logging`의 redacting logger.
4. 모델 ID 하드코딩 금지 → provider catalog에서 조회.
5. 발음 점수·비용·개인화 등 **측정하지 않은 값을 만들어 표시하지 않는다** (spec §2.1, §11).
6. 실제처럼 보이는 키를 파일에 쓰면 PreToolUse 훅이 차단한다. 테스트에는 `sk-FAKE-...`.

## 작업 루프
계획(PROGRESS의 다음 태스크) → 테스트 먼저 → 구현 → `scripts/check.sh` → PROGRESS.md 갱신 → 커밋.
한 번에 하나의 태스크만. 태스크 완료 기준을 만족하지 못하면 "완료"라고 쓰지 않는다.
