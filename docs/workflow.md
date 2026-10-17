# 작업 방식 (하네스)

## 하네스 구성
| 구성 요소 | 위치 | 역할 |
|---|---|---|
| 지도 | `CLAUDE.md` | 짧은 진입점. 세부는 docs로 링크 |
| 진행 보드 | `docs/plans/PROGRESS.md` | 세션 간 상태 인계. SessionStart 훅이 자동 주입 |
| 결정 기록 | `docs/decisions.md` | 확정 사항. 에이전트가 임의로 재논의하지 않음 |
| 기계 검사 | `scripts/check.sh` | 시크릿·아키텍처·format·analyze·test 단일 진입점 |
| 시크릿 차단 | PreToolUse 훅 | 실제처럼 보이는 키 쓰기를 거부 |
| 자동 포맷 | PostToolUse 훅 | 편집한 .dart 파일 `dart format` |
| 종료 게이트 | Stop 훅 | `check.sh --fast` 실패 시 수정하도록 되돌려 보냄 (1회) |
| CI | `.github/workflows/` | 4개 플랫폼 빌드 매트릭스 + check.sh (Phase 0 T2) |

## 태스크 루프
1. PROGRESS.md에서 **다음 태스크 하나**를 고른다. 태스크 정의는 `docs/plans/phase-*.md`.
2. 완료 기준을 테스트로 먼저 옮긴다 (가능한 경우).
3. 구현한다. 레이어 규칙과 보안 불변식을 지킨다.
4. `scripts/check.sh` 통과.
5. PROGRESS.md 갱신: 상태, 발견한 사항, 남은 위험. 실패/보류는 그대로 기록.
6. 커밋 (태스크 ID를 메시지에 포함, 예: `P0-T3: audio capture PoC`).

## 완료 정의 (Definition of Done)
- 태스크의 완료 기준을 모두 만족하고 그 증거(테스트 이름, 측정값, 스크린샷 경로)를 PROGRESS에 남김
- `scripts/check.sh` 통과
- 새로운 공개 인터페이스에는 테스트가 있음
- 사용자에게 보이는 문자열은 l10n 리소스 경유

## 에이전트가 사용자에게 물어야 하는 경우
- `docs/decisions.md`의 결정을 바꿔야 할 때
- 유료 API 호출, 스토어 제출, 서명 키 생성 등 되돌리기 어렵거나 비용이 드는 작업
- Xcode/Android Studio 설치처럼 사용자 계정·GUI가 필요한 작업

## 설치된 에이전트 스킬 활용
| 작업 | 스킬 |
|---|---|
| 레이어 구조 | flutter-apply-architecture-best-practices, flutter-expert |
| 라우팅 | flutter-setup-declarative-routing |
| HTTP/JSON | flutter-use-http-package, flutter-implement-json-serialization |
| 테스트 | dart-add-unit-test, dart-generate-test-mocks, flutter-add-widget-test, flutter-add-integration-test |
| 품질 | dart-run-static-analysis, dart-fix-runtime-errors |
| 다국어/반응형 | flutter-setup-localization, flutter-build-responsive-layout |
| 브로커 | fastapi |
| CI | github-actions-templates |
