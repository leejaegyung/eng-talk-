# 진행 보드

> 세션 시작 시 자동 주입된다. 태스크를 끝낼 때마다 갱신한다. 짧게 유지하고 오래된 상세는 "기록"으로 옮긴다.

**현재 Phase:** 1 (MVP) — Phase 0은 Windows 실행 확인만 남음
**대상 플랫폼:** macOS·Windows 데스크톱 (Mac에서 개발), Galaxy는 APK 배포 후 확인 (ADR-009)
**다음 태스크:** P1-A4 정책 → A5 대화 화면 → A6 피드백 → A7 결과·저장
**과금 방향:** ADR-011 — ChatGPT 구독(추가 요금 없음) 기본, OpenAI API 키는 선택
**Phase 0 순서:** T7 → T4 → T5 → T3 → T6(키·과금, 실행 전 확인). T2는 사용자 Windows 실행 확인 대기

## 상태
| 태스크 | 상태 | 증거 / 메모 |
|---|---|---|
| 하네스 구성 | ✅ | 훅 4종 동작 확인(포맷 훅 실제 적용됨), arch_lint 위반 샘플 5종 검출 |
| 기획 문서 | ✅ | roadmap, phase-0, phase-1, decisions(ADR-001~009) |
| P0-T0 환경 | ✅ | Flutter 3.47.7, Xcode 27.1, Android SDK 36(cmdline tools), JDK 17, CocoaPods 1.17 |
| P0-T1 프로젝트 생성 | ✅ | apps/flutter_app (macos/windows/android), check.sh 통과(테스트 5개), macOS·APK debug 빌드 성공 |
| P0-T2 CI | 🔄 | github.com/leejaegyung/eng-talk- (public). CI 4개 job 녹색, v0.1.0 릴리스(win/mac/apk) 생성. Windows PC 실행 확인 대기 |
| P0-T3 오디오 | ✅ (macOS) | PCM16 스트림 녹음 → 메모리 → WAV 재생(전용 temp 폴더, 재생 후 삭제), 진폭 VAD, 권한 거부·무신호 안내. **사용자 macOS 녹음·재생 확인 (2026-10-17)**. Windows/Galaxy는 다음 릴리스로 확인 |
| P0-T4 Vault | ✅ | `domain/credentials` 인터페이스 + `data/vault/SecureStorageVault`(byok. 네임스페이스, ref 검증으로 키가 키 이름에 들어가는 실수 차단). 단위 13개. macOS 실제 키체인에서 저장→재시작→조회→삭제→재시작→null 확인(integration_test 3회 실행). Windows/Android 실기 확인은 P1-A2 설정 화면에서 |
| P0-T5 Drift | ✅ | 6개 테이블 v1, FK·cascade, enum은 domain. CRUD/cascade/FK/키 컬럼 금지(S1) 테스트 + validateDatabaseSchema + 스냅샷 v1(make-migrations) |
| P0-T6 OpenAI 왕복 (API 키, 선택 경로) | 🔄 | 구현: domain `LlmProvider`/`VoiceProvider`/`ProviderFailure`, `data/providers/openai`(키는 요청마다 vault에서 읽음, SSE 스트리밍, usage 토큰 수집, 오류 정규화), provider_catalog(라이브 모델 목록과 대조해 선택), 홈 → "음성 대화 테스트(개발용)"(키 입력·연결 테스트·말하기·구간별 지연·p50/p95·측정 사용량). 테스트: MockClient 18 + 컨트롤러 10 + 위젯 5. 실제 OpenAI에 가짜 키 → 401 → invalidKey 확인(과금 없음). **남음: 사용자 키로 실제 왕복 10회 측정** |
| P0-T7 상태 머신 | ✅ | `domain/conversation/` 순수 Dart. 시퀀스(seq)+턴 ID로 지연 응답 거부, barge-in 시 `interruptsAssistant`, 연결 끊김→paused(connectionLost)→재연결. 테스트 31개 |
| P0-T8 ChatGPT 구독 연결 | ✅ | Sign in with ChatGPT(오픈소스 plan usage): dynamic_agent_client 자가 등록, PKCE, 루프백 127.0.0.1 콜백, 토큰은 vault만, 갱신 직렬화·종료 오류만 세션 삭제, 로그아웃 시 revoke. `/v1/responses`(stream, store=false, instructions). 오류 3종 추가(signInRequired/planUsageLimit/planNotEligible). 홈 → "ChatGPT 대화 테스트". 테스트: auth 14 + client 12 + controller 10. **✅ 사용자 실로그인·대화 성공(2026-10-17)**. 실제 응답 확인: plan 모델 목록은 `{models:[{slug,priority,description,visibility,supported_in_api}]}` 형식 → 설명에 'fast'인 최상위 우선순위 모델 자동 선택, reasoning effort low. 첫 토큰 1.9s / 전체 2.3s(1회). 수정 이력: ext_agent_host_id는 `urn:uuid:` 형식 필수 |
| P0-T9 OS 음성 (무료) | ✅ | domain `SpeechInput`/`SpeechOutput`, data `OsSpeechInput`(speech_to_text, en_US dictation, 3초 멈춤=턴 종료)·`OsSpeechOutput`(flutter_tts en-US, 완료 대기). ChatGPT 테스트 화면에 🎤·답변 읽어주기·끼어들기(말하면 읽기 중단). macOS TTS 실기 integration_test 통과. v0.2.0 릴리스. Galaxy 로그인 → '네트워크 연결 불가': 토큰 교환이 브라우저가 앞에 있을 때(앱 백그라운드) 실행돼 차단된 것으로 추정 → 모바일은 앱 복귀 후 교환 + 완료 페이지에 '앱으로 돌아가기'(speakingcoach://signed-in) → v0.2.1. **✅ 사용자 Galaxy에서 로그인·음성 대화 확인(2026-10-17)**. Windows STT(베타)는 T2와 함께 |
| P1-A1 앱 셸·온보딩 | ✅ | `app_settings` 테이블(스키마 v2, stepByStep 마이그레이션 + 스냅샷 테스트), `SettingsStore`(domain)·`DriftSettingsStore`, `OnboardingGate` + router redirect(splash → onboarding/home, 읽기 실패 시 온보딩). S01 최소판: 소개 → 데이터 처리 안내(텍스트 전송, OS 음성 인식 서버 처리 가능, 녹음 미저장, 로컬 기록, 보안 저장소) → ChatGPT 연결 또는 나중에. 테스트: redirect 4 + 온보딩 흐름 위젯 5 + 저장소 2, macOS 실제 DB 재열기 integration_test 통과. 언어 선택·마이크 테스트·진단은 슬라이스 D |
| P1-A2 설정 | ✅ | S02/S11 최소판: ChatGPT 연결 상태·로그인/로그아웃·연결 확인(자동 선택 모델 표시), 실패 4종(로그인 필요/구독 불가/한도/네트워크) 메시지 위젯 테스트, 답변 읽어주기 기본값 저장(`voice.speak_replies`), 데이터 처리 안내(온보딩과 공유 위젯), 오픈소스 라이선스. 홈 ⚙️. API 키 입력은 ADR-011로 선택 항목 → 후속 |
| P1-A3 PromptComposer | ✅ | `domain/conversation/prompt_composer.dart`(버전 `coach-v1`) + `domain/learning/LearnerLevel`. 계층: 마스터(spec §8.2) → SESSION RULES(모드 7종·레벨 5종·정책 노트) → `<learner_context>`(주제·목표·역할·복습 표현, 따옴표 한 줄·80자 제한·태그/중괄호 무력화) → 대화(시스템 메시지 제거, 최근 N개, 잘리면 user부터). 테스트 16. 프롬프트는 계획의 packages/prompt_assets 대신 domain 상수로 둠(앱 하나뿐이라 패키지 분리 이득 없음) |

## 알려진 이슈
- OS 음성 인식은 플랫폼에 따라 Apple/Google/Microsoft 서버에서 처리될 수 있음(앱은 원본을 저장하지 않음) → 온보딩 고지(P1)에 포함. OS STT 경로는 PCM을 받지 않아 VAD 발화 지표 미측정 → P1-B2에서 onSoundLevelChange 활용 검토
- macOS: record_macos 2.1.1에서 echoCancel(voice processing)을 켜면 입력이 전부 0 → macOS는 끔. 스피커 사용 시 AI 목소리가 마이크로 들어가 barge-in 오검출 가능 → 헤드폰 권장 또는 P1-B1에서 재생 중 VAD 임계값 상향 검토
- MacBook 덮개를 닫으면 내장 마이크가 하드웨어적으로 꺼져 입력이 0 → 오디오 화면이 2초 무신호 시 안내
- macOS: 서명 없는 빌드라 legacy keychain 사용(`usesDataProtectionKeychain: false`). 앱 업데이트 후 키체인 접근 허용 창이 뜰 수 있음 — ADR-006 서명 결정 시 재검토
- `flutter analyze`가 한글·공백 경로에서 크래시(LSP 버그) → check.sh는 `dart analyze --fatal-infos` 사용
- Windows 빌드는 Mac에서 불가 → CI 아티팩트로만 확인

## 미해결 질문
- ADR-006 배포 방식 (Phase 3 전까지)

## 기록
- 2026-10-17 GitHub 연결, 릴리스 워크플로(ADR-010)
- 2026-10-17 스킬 16종 설치, 하네스·기획 문서 작성, 개발 환경 구성, 프로젝트 생성
