# 아키텍처

spec §4~§6 요약 + 구현 규칙. 규칙 중 기계 검사 가능한 것은 `scripts/arch_lint.py`가 강제한다.

## 저장소 구조
```text
apps/flutter_app/          Flutter 앱 (4개 플랫폼)
  lib/app/                 bootstrap, router(go_router), theme, DI(provider 배선)
  lib/core/                errors, logging(redacting), result 타입, 공용 유틸
  lib/domain/              entities, use_cases, 인터페이스(LlmProvider, VoiceProvider, CredentialVault, 리포지토리)
  lib/data/                구현체: db(drift), providers(openai/...), vault(secure storage), audio
  lib/features/<name>/     화면 + 컨트롤러(Riverpod Notifier). onboarding, provider_settings, home,
                           assessment, conversation, feedback, progress, history
  test/                    단위·위젯 테스트 (lib 구조 미러링)
  integration_test/
services/session_broker/   FastAPI (Realtime용, 차기 단계 — ADR-002)
packages/prompt_assets/    버전 관리되는 프롬프트/루브릭
scripts/                   check.sh, arch_lint.py, secret_scan.py
docs/                      설계 문서와 계획
```

## 레이어 의존 규칙
```text
features ──▶ domain ◀── data
    │           ▲         │
    └──▶ core ◀─┴─────────┘
app: 모든 레이어를 배선(DI)할 수 있는 유일한 곳
```
| 레이어 | import 가능 | import 금지 |
|---|---|---|
| domain | core(순수 Dart 부분), dart: | flutter, data, features, app, http/drift/secure_storage/riverpod |
| data | domain, core, 인프라 패키지 | features |
| features | domain, core, app(router/providers) | data |
| core | 외부 순수 패키지 | features |

## 핵심 컴포넌트 (spec §4.2)
- `ConversationSessionController` — 상태 머신 `idle → connecting → listening → user_speaking → processing → ai_speaking → listening → paused → ended`. 모든 이벤트에 단조 증가 시퀀스 ID.
- `ConversationPolicyEngine` — 레벨/모드/힌트 단계/교정 타이밍. 순수 Dart, 단위 테스트 필수.
- `PromptComposer` — system/developer/context/messages 계층 합성. 사용자 발화는 지시로 취급하지 않음.
- `LlmProvider` / `VoiceProvider` — `ProviderCapabilities`로 기능 노출. 지원 안 되면 UI 비활성화 또는 폴백.
- `CredentialVault` — 키 저장/조회/삭제의 유일한 경로.
- `FeedbackService` — JSON 스키마 검증, 교정은 transcript turn ID에 연결. 실패 시 1회 재요청 후 축약 결과.
- `ProgressService` — 발화 지표 집계, 복습 큐.

## 상태 관리 / 라우팅
- Riverpod (Notifier/AsyncNotifier). 전역 싱글톤 대신 provider로 주입 → 테스트에서 override.
- go_router. 온보딩 미완료 시 redirect.

## 오류 모델
공급자 오류는 `data/`에서 `ProviderFailure`(invalidKey, insufficientQuota, rateLimited, modelUnavailable, network, unknown)로 정규화한다. UI는 이 enum으로만 분기한다 (spec §11).

## 로컬 DB (Drift)
- 테이블: `lib/data/db/tables.dart`, DB: `lib/data/db/app_database.dart` (생성 파일 `*.g.dart`는 커밋한다 → CI에 build_runner 불필요)
- 테이블 변경 후: `dart run build_runner build`
- 스키마 변경 시: `schemaVersion` 증가 → `dart run drift_dev make-migrations` (스냅샷 `drift_schemas/` + 단계별 마이그레이션 테스트 `test/drift/` 생성) → `migration` 구현. 스냅샷 누락은 `test/data/db/schema_test.dart`가 잡는다.
- enum 컬럼은 이름으로 저장 → `domain/conversation/session_enums.dart` 값 이름 변경 = 마이그레이션 필요.
