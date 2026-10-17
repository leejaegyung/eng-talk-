# 결정 기록 (ADR)

새 결정은 아래에 추가하고 기존 항목은 `대체됨: ADR-0xx`로 표시한다. 삭제하지 않는다.

## ADR-001 기술 스택 — 확정 (2026-10-17)
Flutter + Dart, Riverpod, go_router, Drift(SQLite), flutter_secure_storage. 출처: spec §0.
패키지 버전은 설치 시점의 stable을 사용하고 `pubspec.lock`으로 고정한다.

## ADR-002 음성 경로: STT → LLM → TTS 먼저, Realtime은 PoC 후 — 기본값 채택 (2026-10-17)
spec §19 기본 선택. MVP에는 세션 브로커를 운영하지 않는다. Realtime + 브로커는 Phase 2에서 재검토.
결과: `services/session_broker/`는 Phase 2 전까지 만들지 않는다. 끼어들기(barge-in)는 로컬 TTS 재생 중단 수준으로 제한.

## ADR-003 BYOK 키 처리: 순수 로컬 — 기본값 채택 (2026-10-17)
키는 기기의 secure storage에만 있고 앱이 공급자 API를 직접 호출한다. 서버로 키를 보내지 않는다.
위험(기기 탈취, 악성 앱)은 온보딩에서 고지한다.

## ADR-004 계정 없음, 원본 녹음 미저장 — 기본값 채택 (2026-10-17)
로그인·동기화 없음. 음성은 STT 전송 후 메모리에서 폐기한다.

## ADR-005 첫 공급자: OpenAI — 기본값 채택 (2026-10-17)
STT/LLM/TTS를 한 공급자로 PoC. 모델 ID는 공급자의 모델 목록 API + 앱 내 catalog 설정으로 고르고 하드코딩하지 않는다.
Anthropic/Gemini는 Phase 2 어댑터 (Anthropic은 STT/TTS가 없으므로 텍스트 LLM 전용 → 음성 공급자 분리 설정 필요).

## ADR-006 배포 방식 — 미정
개인 사이드로드 vs 스토어 출시. Phase 3 전에 결정. 그 전까지는 서명 없는 개발 빌드.

## ADR-007 오디오 / VAD — 잠정 (PoC로 확정)
녹음: `record` 패키지(4개 플랫폼 지원) 후보. 재생: `just_audio` 또는 `audioplayers` 후보.
VAD: 1차는 진폭(dBFS) 기반 + 침묵 지속시간 임계값. 정확도가 부족하면 Silero VAD(ONNX)를 검토.
P0-T3, P0-T6 결과로 확정한다.

## ADR-008 개발 단계 대상 플랫폼: macOS + Android(Galaxy) — 대체됨: ADR-009
사용자 결정. Phase 0~1은 macOS 데스크톱과 Galaxy 실기기(Android)만 검증한다. iOS·Windows는 MVP 개발 후 별도 단계에서 추가.
결과: Phase 0/1 종료 기준의 "4개 플랫폼"을 "macOS + Android"로 대체. 단, iOS/Windows 호환이 알려진 패키지만 선택해 나중에 이식 비용을 줄인다.
Android SDK는 Android Studio 없이 command-line tools로 구성한다.

## ADR-009 대상 플랫폼: macOS + Windows 개발, Android는 배포 후 확인 — 확정 (2026-10-17)
사용자 결정. 개발·검증은 Mac에서 하고, 앱은 macOS와 Windows 데스크톱에서 동작해야 한다.
Galaxy(Android)는 배포 빌드(APK)를 설치해 최종 확인만 한다(USB 디버깅 불필요). iOS는 MVP 이후.
결과:
- Flutter 플랫폼: macos, windows, android. Windows 빌드는 Mac에서 불가 → GitHub Actions windows 러너로 빌드·아티팩트 배포, 실행 확인은 사용자 Windows PC.
- 모든 패키지는 macOS·Windows·Android를 모두 지원해야 한다. 이에 따라 재생 패키지를 just_audio(Windows 미지원) → audioplayers로 교체.
- 데스크톱 우선 UX: 키보드 단축키, 넓은 창 레이아웃, 마이크 장치 선택.
