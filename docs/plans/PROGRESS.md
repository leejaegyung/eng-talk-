# 진행 보드

> 세션 시작 시 자동 주입된다. 태스크를 끝낼 때마다 갱신한다. 짧게 유지하고 오래된 상세는 "기록"으로 옮긴다.

**현재 Phase:** 1 (MVP) — Phase 0은 Windows 실행 확인만 남음
**대상 플랫폼:** macOS·Windows 데스크톱 (Mac에서 개발), Galaxy는 APK 배포 후 확인 (ADR-009)
**다음 태스크:** Phase 1 사용자 실사용 확인(macOS 30분 세션 → 피드백 → 복습) → v0.3.0 릴리스(Windows/Galaxy) → Phase 1 종료
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
| P1-A4 대화 정책 | ✅ | `domain/conversation/conversation_policy.dart`: 힌트 4단계(단어→문장 시작→한국어→예시, 사용자 발화 시 초기화), 빠른 동작 5종(힌트/다시/천천히/이 문장 교정/주제 변경 → 보이는 영어 요청 + 프롬프트 노트), '천천히'는 세션 내내 유지, 교정 기본은 종료 후(간격 옵션 시 주기당 1회), 세션 단계 3/4/18/5분 비례, 긴 침묵(20s) 힌트 제안. 테스트 11. 의사소통 장애 감지 시 즉시 교정은 미구현(신호 없음) |
| P1-A5 대화 화면(S06) | 🔄 | 홈 "대화 시작" → Daily · 저장된 레벨(기본 L2) · 30분. AI가 먼저 질문(숨은 시작 메시지), PromptComposer+정책 노트로 매 요청 합성, 스트리밍 자막(크게)·자막 숨기기, 빠른 동작 5종(요청 줄은 기울임), 🎤 OS 음성 + 텍스트 입력, '천천히'는 TTS 속도↓, 20초 침묵 시 힌트 제안, 상태(연결 중/듣는 중/생각 중/AI 말하는 중/내 차례), 타이머, 종료 → 시간·답변 수. 점수 비노출 위젯 테스트. 미연결 시 설정 안내. 테스트: 컨트롤러 14 + 위젯 3. 세션은 메모리만(A7에서 저장). 대화 컨트롤러는 아래 B1에서 재작성 |
| P1-A6 피드백 | ✅ | `domain/feedback/FeedbackService`: §8.4 JSON, 교정은 실제 learner turn ID + 원문 포함 여부로 검증(아니면 버림), 심각도순 최대 3·표현 5, 코드펜스 허용, 잘못된 JSON 1회 재요청 후 축약 결과. 단위 11 + **실제 모델 검증 통과** |
| P1-A7 결과·저장·복구 | ✅ | 스키마 v3(세션 설정·피드백 JSON, 턴 isRequest/speechMs, expressions·review_queue·assessments), `DriftSessionRepository`(턴을 발생 즉시 저장). S08 결과(시간·답변 수·발화 추정치), S07 교정 카드 + 다시 말하기(채점 없음). 홈 배너: 끝나지 않은 대화 이어하기/끝내고 결과. **macOS 실제 DB 강제 종료 후 복구 integration_test 통과** |
| P1-B1 음성 통합 | ✅ (코드) | 대화가 상태 머신(T7)으로 동작: 끼어들기 시 AI 음성 즉시 중단, 지연 응답 turn 거부, 일시정지. 이벤트 2종 추가(SpeechDiscarded, ResponseFailed). **남음: 실기기 5분 음성 세션** |
| P1-B1a 인식률 | ✅ (코드) | 사용자 보고(2026-10-18): 말한 단어와 다른 단어가 기록됨. 인식기에 맥락 힌트 전달(contextualPhrases: 주제·역할·목표 + 최근 AI 문장 3개의 내용어, 진단은 질문 단어), Apple 자동 문장부호. 프롬프트 coach-v3·피드백·진단에 '음성 인식 오류로 보이는 단어는 교정/감점하지 않음'. **남음: 사용자 체감 확인** |
| iOS 빌드 | 🔄 | ADR-012: iOS 플랫폼 추가, 로컬 `--no-codesign` Release 빌드 성공, CI·릴리스에 서명 없는 IPA 추가(v0.3.0). **남음: 서명 방식 결정 → 아이폰 실기 확인** |
| P1-B2 발화 지표 | ✅ | AI 발화 = TTS 실측, 사용자 발화 = 인식기 첫/마지막 부분결과 간격(추정, confidence 0.5). 양쪽 다 있을 때만 비율 표시, 결과·홈에 '추정' 표기 |
| P1-B3 연결 끊김 | ✅ | network 실패 → paused(connectionLost) → 다시 연결(실패 요청 재시도) / 읽어주기 없이 계속 / 저장하고 끝내기 |
| P1-C1 모드 정책 | ✅ | 6모드 규칙(PromptComposer). **실제 모델 평가 세트 통과**(모드별 질문 1개·후속 질문·3문장 이하·마크다운 없음). 첫 실행에서 질문 2개 연달아 묻는 문제 발견 → 프롬프트 coach-v2로 수정 후 통과 |
| P1-C2 모드·주제 설정 | ✅ | S04/S05: 6모드, 레벨 L1~L5(저장), 모드별 주제 추천+직접 입력, 역할극 상황 8종 + 역할/상황/목표 직접 입력, 20/30/45분 |
| P1-D1 레벨 진단 | ✅ | 마이크 확인 → 질문 5개(읽어줌, 음성/입력) → 텍스트 루브릭 4항목(발음·유창성 평가 안 함 고지) → 레벨 매핑(짧은 답변은 상한) → 수락/변경 저장. 실제 모델 루브릭 파싱 확인 |
| P1-D2 홈·기록·복습 | ✅ | 홈 KPI(오늘/7일 발화 추정, 연속 학습일, 완료율, 평균 답변 단어, 복습 수, 추천 주제), 기록 검색·삭제, 간격 반복 1/3/7/14/30일 |
| P1-D3 내보내기·삭제 | ✅ | JSON+CSV(데스크톱: 다운로드 폴더, 모바일: 공유), 자격증명 미포함 테스트, 전체 삭제(로그인·설정 유지) |
| UI 디자인 개편 | ✅ (코드) | Figma 'Speak Up' UI kit 참고(캔버스는 접근 불가, 커뮤니티 미리보기에서 색 추출): `app/theme.dart` — 메인 #2563EB, 강조 주황 #FE9518·노랑 #FECC17, 흰 둥근 카드(16)+옅은 테두리, 밝은 배경 #F5F7FB, 버튼·입력·칩 둥글게, 다크 테마 대응. 홈: 로고·파란 그라데이션 시작 카드·색 아이콘 KPI 타일·이어하기(주황)·진단(노랑). 대화: 내 말 파란 말풍선/AI 흰 말풍선, 원형 마이크(듣는 중 주황), 상태 점. 테스트 298 통과. **남음: 사용자 화면 확인** |

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
