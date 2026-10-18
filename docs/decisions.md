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

## ADR-005 첫 공급자: OpenAI — 기본값 채택 (2026-10-17), 과금 경로는 ADR-011로 대체
STT/LLM/TTS를 한 공급자로 PoC. 모델 ID는 공급자의 모델 목록 API + 앱 내 catalog 설정으로 고르고 하드코딩하지 않는다.
Anthropic/Gemini는 Phase 2 어댑터 (Anthropic은 STT/TTS가 없으므로 텍스트 LLM 전용 → 음성 공급자 분리 설정 필요).

## ADR-006 배포 방식: 개인용 직접 설치 — 확정 (2026-10-18)
사용자 결정: "개인용으로 설치해서 쓸거야". 스토어 출시·TestFlight·Play 내부 테스트·개인정보처리방침 웹페이지·스토어 개인정보 라벨은 범위 밖.
- 설치 파일은 GitHub Releases(ADR-010)에서 받는다.
- macOS·Windows: 서명 없는 빌드 유지(처음 실행 시 우클릭 → 열기 / SmartScreen '추가 정보 → 실행').
- Android: **고정 릴리스 키로 서명**해야 업데이트를 덮어 설치할 수 있다(앱을 지우면 로컬 기록도 지워짐). 키는 저장소에 넣지 않는다.
- iOS: 본인 Apple ID 서명(무료 계정은 7일마다 재설치, ADR-012).

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

## ADR-010 테스트 배포: GitHub Releases 버전 관리 — 확정 (2026-10-17)
사용자 결정. 설치 파일은 GitHub Releases에 버전별로 올린다. ADR-006(최종 배포 방식)이 정해지기 전까지의 테스트 배포 경로.
- `scripts/release.sh X.Y.Z` → pubspec 버전 갱신 + check + 커밋 + 태그 `vX.Y.Z` push → `release` 워크플로가 빌드 후 릴리스 생성.
- 태그와 pubspec 버전이 다르면 릴리스 실패. 빌드 번호(Android versionCode)는 워크플로 실행 번호. `-` 포함 태그는 prerelease.
- 산출물: `SpeakingCoach-<ver>-windows-x64.zip`, `-macos.zip`, `-android.apk`. 모두 서명 없음.
- 알려진 한계: APK는 CI의 임시 디버그 키로 서명되어 버전 간 서명이 달라 업데이트 설치가 안 될 수 있음(삭제 후 재설치). 고정 키스토어를 GitHub Secrets에 두면 해결 — 필요 시 사용자 확인 후 추가.

## ADR-011 과금 경로: ChatGPT 구독 우선(추가 요금 없음), API 키는 선택 — 확정 (2026-10-17)
사용자 결정: "gpt를 연결해서 쓰고 싶은데 추가 요금이 안나오게". ADR-005(OpenAI API 키 우선)를 대체한다.
- LLM: **Sign in with ChatGPT**(오픈소스 앱용 plan usage, developers.openai.com/siwc). `dynamic_agent_client` 자가 등록 → 발급 client_id 저장, PKCE 공개 클라이언트, 루프백 리다이렉트 `http://127.0.0.1:<port>/auth/callback`. `POST /v1/responses`(stream=true, store=false, system은 `instructions`)만 지원. Plus/Pro 구독 한도 내 사용.
- STT/TTS: plan usage가 오디오·전사를 지원하지 않으므로 OS 기본 음성(`speech_to_text`, `flutter_tts`) — 무료. Windows STT는 패키지가 베타 → P0에서 검증.
- OpenAI API 키(BYOK) 경로는 "고품질 음성" 선택 옵션으로 유지(P0-T6 코드 재사용).
- 토큰(access/refresh/id)과 발급 client_id는 CredentialVault에만 저장(S1과 동일 취급).
- 위험: 오픈소스 앱 조건(저장소 공개 + 라이선스), 프리뷰 기능 변경 가능성, Android 루프백 리다이렉트 미문서화, 무료 사용자는 대상 아님(문서상 Plus/Pro).

## ADR-012 iOS 빌드 추가 — 확정 (2026-10-18)
사용자 요청으로 ADR-009의 "iOS는 MVP 이후"를 앞당겨 iOS 플랫폼을 추가한다(최소 iOS 15). 마이크·음성 인식 권한 문구, `speakingcoach://` URL 스킴(ChatGPT 로그인 후 앱 복귀)을 설정했다. 서명 인증서가 없어 서명 없는 빌드(`flutter build ios --no-codesign`)까지만 자동화한다. 설치용 서명 방식(무료 Apple ID 7일 / 유료 개발자 계정 TestFlight)은 사용자 결정 대기.

## ADR-013 유료 OpenAI 음성 미도입 — 확정 (2026-10-18)
사용자 결정. 음성 인식·합성은 무료 OS 음성만 사용한다. Phase 2의 P2-6(OpenAI 고품질 음성)·P2-7(비용 추적·한도)은 보류. 인식 정확도는 맥락 힌트(P1-B1a)·말한 뒤 확인(P2-2)으로 보완한다.

## ADR-014 두 번째 AI 공급자: Claude (Anthropic) — 대체됨 → ADR-015 (2026-10-18)
사용자 결정. P2-8은 Anthropic Messages API 어댑터(`LlmProvider`)로 구현한다. 사용자 API 키(BYOK)는 CredentialVault에만 저장, 모델 ID는 provider catalog에서 라이브 목록과 대조해 고른다(규칙 4). 사용량만큼 과금되므로 실제 호출 테스트는 사용자 확인 후에만 한다. ChatGPT 구독이 기본 경로로 남는다(ADR-011).

## ADR-015 두 번째 AI 공급자: Gemini 무료 키 (ADR-014 대체) — 확정 (2026-10-18)
사용자 결정: "클로드도 추가비용 안나오는 방향으로" → Anthropic은 제3자 앱이 Claude.ai 로그인이나 Free/Pro/Max 구독으로 요청을 보내는 것을 허용하지 않음(code.claude.com/docs/en/legal-and-compliance, 확인 2026-10-18). API 키는 사용량 과금이라 요구를 만족할 수 없어 Claude는 제거하고 Gemini로 대체.
- Gemini Developer API 무료 등급 키(Google AI Studio, 결제 등록 없음). 모델은 무료 등급 Flash-Lite만(`gemini-3.5-flash-lite` → `3.1` → `2.5`), catalog에서 라이브 목록과 대조.
- 키는 vault(`provider.gemini`)에만, 요청 헤더(`x-goog-api-key`)로만 보냄(URL 쿼리 금지).
- 무료 등급은 대화 내용이 Google 제품 개선에 쓰이고 사람이 검토할 수 있음 → 설정·데이터 처리 안내에 고지, 개인정보를 말하지 말라고 안내.
- 사용량 제한(RESOURCE_EXHAUSTED)은 rateLimited로 안내. ChatGPT 구독이 기본 경로로 남는다(ADR-011).

## ADR-016 iPhone·iPad 사용자에게는 웹 앱(PWA)으로 배포 — 확정 (2026-10-18)
사용자 결정: iOS 사용자들에게 배포하려는데 무료 서명(7일·기기 3개)은 너무 제한적 → 웹 앱(Safari → 홈 화면에 추가). ADR-006(개인용 설치)을 보완: 갤럭시·Windows·Mac은 GitHub 릴리스 설치 파일, iOS는 웹.
- 호스팅: GitHub Pages(https://leejaegyung.github.io/eng-talk-/), 릴리스 태그마다 `pages.yml`로 자동 배포. 서버 없음 — 기록은 각자 브라우저(IndexedDB)에.
- DB: drift 웹(sqlite3.wasm + drift_worker.js, 공식 릴리스 고정 버전·SHA-256, `tool/fetch_web_assets.sh`). 홈 화면 앱은 Safari 7일 정리 대상에서 제외, `navigator.storage.persist()` 요청.
- ChatGPT 구독 로그인: 브라우저는 127.0.0.1 루프백 서버를 열 수 없어 **로그인 후 주소 붙여넣기**(redirect_uri는 문서대로 http://127.0.0.1:1455/auth/callback). OpenAI 인증·응답 API는 CORS 허용 확인(2026-10-18 preflight). Gemini 키도 웹에서 동작.
- 스트리밍: 웹 기본 HTTP 클라이언트는 응답을 모아서 주므로 fetch 기반 클라이언트(fetch_client).
- 키·토큰 보관: 웹은 OS 보안 저장소가 없어 flutter_secure_storage 웹(브라우저 저장소 + WebCrypto) — 네이티브보다 약함, 개인정보 검수에 기록.
- 내보내기: 공유 시트(아이폰 '파일에 저장') 또는 다운로드. 오류 기록은 웹에서 세션 동안만.
- 남은 위험: iOS 홈 화면 앱에서 Web Speech 음성 인식 지원 여부는 기기 확인 필요(안 되면 입력 안내). 한글 글꼴은 처음 한 번 Google Fonts에서 받음.

## ADR-017 음성 인식 선택: 기기 내장 / Gemini 받아쓰기 — 확정 (2026-10-18)
사용자 보고: 'Oasis music' → 'watch this music'(기기 인식 한계), "GPT에서 오디오 말하는 거마냥 인식되게". 확인(`tool/eval/audio_probe.dart`): ChatGPT 구독 토큰은 `/v1/audio/transcriptions` 401, `/v1/responses` 오디오 입력은 구독 모델 9개 모두 'Audio input is not available' → 구독으로는 불가. 사용자 결정: Gemini 무료 키로 받아쓰기.
- 설정 → 음성 인식: 기기 내장(기본) / Gemini. Gemini는 녹음(PCM, 메모리만) → 레벨 기반 VAD로 끝 판단(말한 뒤 2.5초 무음, 첫 단어 대기는 화면별) → WAV를 generateContent(inlineData)로 받아쓰기. 실수는 고치지 말고 그대로, 맥락(질문·주제)은 철자 참고용.
- 키가 없으면 기기 인식으로 자동 대체. 대화 AI는 별개(ChatGPT 유지 가능).
- 무료 등급은 녹음이 Google 개선에 쓰일 수 있음 → 설정·온보딩 안내. ADR-013(유료 OpenAI 음성 미도입)은 유지.
