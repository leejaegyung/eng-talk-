# 진행 보드

> 세션 시작 시 자동 주입된다. 태스크를 끝낼 때마다 갱신한다. 짧게 유지하고 오래된 상세는 "기록"으로 옮긴다.

**현재 Phase:** 2 (품질) — 사용자 결정(2026-10-18): Phase 1 기기 확인은 Mac 자동 E2E로 대신하고 진행. Windows/Galaxy/iPhone 확인은 미완
**대상 플랫폼:** macOS·Windows 데스크톱 (Mac에서 개발), Galaxy는 APK 배포 후 확인 (ADR-009)
**다음 태스크:** 사용자 확인 대기(기기·실제 목소리·Gemini 키·이어폰). 결정 필요: ADR-006 배포 방식(서명·스토어). Realtime은 사용자 요청으로 제외
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
| P0-T6 OpenAI 왕복 (API 키, 선택 경로) | ⏸ 보류(ADR-013) | 구현: domain `LlmProvider`/`VoiceProvider`/`ProviderFailure`, `data/providers/openai`(키는 요청마다 vault에서 읽음, SSE 스트리밍, usage 토큰 수집, 오류 정규화), provider_catalog(라이브 모델 목록과 대조해 선택), 홈 → "음성 대화 테스트(개발용)"(키 입력·연결 테스트·말하기·구간별 지연·p50/p95·측정 사용량). 테스트: MockClient 18 + 컨트롤러 10 + 위젯 5. 실제 OpenAI에 가짜 키 → 401 → invalidKey 확인(과금 없음). **남음: 사용자 키로 실제 왕복 10회 측정** |
| P0-T7 상태 머신 | ✅ | `domain/conversation/` 순수 Dart. 시퀀스(seq)+턴 ID로 지연 응답 거부, barge-in 시 `interruptsAssistant`, 연결 끊김→paused(connectionLost)→재연결. 테스트 31개 |
| P0-T8 ChatGPT 구독 연결 | ✅ | Sign in with ChatGPT(오픈소스 plan usage): dynamic_agent_client 자가 등록, PKCE, 루프백 127.0.0.1 콜백, 토큰은 vault만, 갱신 직렬화·종료 오류만 세션 삭제, 로그아웃 시 revoke. `/v1/responses`(stream, store=false, instructions). 오류 3종 추가(signInRequired/planUsageLimit/planNotEligible). 홈 → "ChatGPT 대화 테스트". 테스트: auth 14 + client 12 + controller 10. **✅ 사용자 실로그인·대화 성공(2026-10-17)**. 실제 응답 확인: plan 모델 목록은 `{models:[{slug,priority,description,visibility,supported_in_api}]}` 형식 → 설명에 'fast'인 최상위 우선순위 모델 자동 선택, reasoning effort low. 첫 토큰 1.9s / 전체 2.3s(1회). 수정 이력: ext_agent_host_id는 `urn:uuid:` 형식 필수 |
| P0-T9 OS 음성 (무료) | ✅ | domain `SpeechInput`/`SpeechOutput`, data `OsSpeechInput`(speech_to_text, en_US dictation, 3초 멈춤=턴 종료)·`OsSpeechOutput`(flutter_tts en-US, 완료 대기). ChatGPT 테스트 화면에 🎤·답변 읽어주기·끼어들기(말하면 읽기 중단). macOS TTS 실기 integration_test 통과. v0.2.0 릴리스. Galaxy 로그인 → '네트워크 연결 불가': 토큰 교환이 브라우저가 앞에 있을 때(앱 백그라운드) 실행돼 차단된 것으로 추정 → 모바일은 앱 복귀 후 교환 + 완료 페이지에 '앱으로 돌아가기'(speakingcoach://signed-in) → v0.2.1. **✅ 사용자 Galaxy에서 로그인·음성 대화 확인(2026-10-17)**. Windows STT(베타)는 T2와 함께 |
| P1-A1 앱 셸·온보딩 | ✅ | `app_settings` 테이블(스키마 v2, stepByStep 마이그레이션 + 스냅샷 테스트), `SettingsStore`(domain)·`DriftSettingsStore`, `OnboardingGate` + router redirect(splash → onboarding/home, 읽기 실패 시 온보딩). S01 최소판: 소개 → 데이터 처리 안내(텍스트 전송, OS 음성 인식 서버 처리 가능, 녹음 미저장, 로컬 기록, 보안 저장소) → ChatGPT 연결 또는 나중에. 테스트: redirect 4 + 온보딩 흐름 위젯 5 + 저장소 2, macOS 실제 DB 재열기 integration_test 통과. 언어 선택·마이크 테스트·진단은 슬라이스 D |
| P1-A2 설정 | ✅ | S02/S11 최소판: ChatGPT 연결 상태·로그인/로그아웃·연결 확인(자동 선택 모델 표시), 실패 4종(로그인 필요/구독 불가/한도/네트워크) 메시지 위젯 테스트, 답변 읽어주기 기본값 저장(`voice.speak_replies`), 데이터 처리 안내(온보딩과 공유 위젯), 오픈소스 라이선스. 홈 ⚙️. API 키 입력은 ADR-011로 선택 항목 → 후속 |
| P1-A3 PromptComposer | ✅ | `domain/conversation/prompt_composer.dart`(버전 `coach-v1`) + `domain/learning/LearnerLevel`. 계층: 마스터(spec §8.2) → SESSION RULES(모드 7종·레벨 5종·정책 노트) → `<learner_context>`(주제·목표·역할·복습 표현, 따옴표 한 줄·80자 제한·태그/중괄호 무력화) → 대화(시스템 메시지 제거, 최근 N개, 잘리면 user부터). 테스트 16. 프롬프트는 계획의 packages/prompt_assets 대신 domain 상수로 둠(앱 하나뿐이라 패키지 분리 이득 없음) |
| P1-A4 대화 정책 | ✅ | `domain/conversation/conversation_policy.dart`: 힌트 4단계(단어→문장 시작→한국어→예시, 사용자 발화 시 초기화), 빠른 동작 5종(힌트/다시/천천히/이 문장 교정/주제 변경 → 보이는 영어 요청 + 프롬프트 노트), '천천히'는 세션 내내 유지, 교정 기본은 종료 후(간격 옵션 시 주기당 1회), 세션 단계 3/4/18/5분 비례, 긴 침묵(20s) 힌트 제안. 테스트 11. 의사소통 장애 감지 시 즉시 교정은 미구현(신호 없음) |
| P1-A5 대화 화면(S06) | ✅ (B1에서 재작성, Mac E2E 통과) | 홈 "대화 시작" → Daily · 저장된 레벨(기본 L2) · 30분. AI가 먼저 질문(숨은 시작 메시지), PromptComposer+정책 노트로 매 요청 합성, 스트리밍 자막(크게)·자막 숨기기, 빠른 동작 5종(요청 줄은 기울임), 🎤 OS 음성 + 텍스트 입력, '천천히'는 TTS 속도↓, 20초 침묵 시 힌트 제안, 상태(연결 중/듣는 중/생각 중/AI 말하는 중/내 차례), 타이머, 종료 → 시간·답변 수. 점수 비노출 위젯 테스트. 미연결 시 설정 안내. 테스트: 컨트롤러 14 + 위젯 3. 세션은 메모리만(A7에서 저장). 대화 컨트롤러는 아래 B1에서 재작성 |
| P1-A6 피드백 | ✅ | `domain/feedback/FeedbackService`: §8.4 JSON, 교정은 실제 learner turn ID + 원문 포함 여부로 검증(아니면 버림), 심각도순 최대 3·표현 5, 코드펜스 허용, 잘못된 JSON 1회 재요청 후 축약 결과. 단위 11 + **실제 모델 검증 통과** |
| P1-A7 결과·저장·복구 | ✅ | 스키마 v3(세션 설정·피드백 JSON, 턴 isRequest/speechMs, expressions·review_queue·assessments), `DriftSessionRepository`(턴을 발생 즉시 저장). S08 결과(시간·답변 수·발화 추정치), S07 교정 카드 + 다시 말하기(채점 없음). 홈 배너: 끝나지 않은 대화 이어하기/끝내고 결과. **macOS 실제 DB 강제 종료 후 복구 integration_test 통과** |
| P1-B1 음성 통합 | ✅ (코드) | 대화가 상태 머신(T7)으로 동작: 끼어들기 시 AI 음성 즉시 중단, 지연 응답 turn 거부, 일시정지. 이벤트 2종 추가(SpeechDiscarded, ResponseFailed). **남음: 실기기 5분 음성 세션** |
| P1-B1a 인식률 | ✅ (코드) | 사용자 보고(2026-10-18): 말한 단어와 다른 단어가 기록됨. 인식기에 맥락 힌트 전달(contextualPhrases: 주제·역할·목표 + 최근 AI 문장 3개의 내용어, 진단은 질문 단어), Apple 자동 문장부호. 프롬프트 coach-v3·피드백·진단에 '음성 인식 오류로 보이는 단어는 교정/감점하지 않음'. **남음: 사용자 체감 확인** |
| iOS 빌드 | 🔄 | ADR-012: iOS 플랫폼 추가, 로컬 `--no-codesign` Release 빌드 성공, CI·릴리스에 서명 없는 IPA 추가(v0.3.0). **남음: 서명 방식 결정 → 아이폰 실기 확인** |
| P1-B4 백그라운드 일시정지 | ✅ | spec §3.3: 앱이 숨겨지면(다른 앱·화면 잠금·최소화, `AppLifecycleListener.onHide`) 마이크·음성 중단 + 일시정지(PauseReason.background, 전용 안내), 돌아와서 이어하기. 버그 수정: 답변 생성 중 일시정지하면 AI 답이 사라지던 문제 → 조각 버리고 재개 시 다시 요청(빠른 재개 경쟁 조건 포함). 테스트: 컨트롤러 4 + 위젯 1(실제 lifecycle 전환) |
| Mac E2E | ✅ **실제 GPT 포함(2026-10-18, 97초)** | `integration_test/mac_e2e_test.dart`: 실제 macOS 앱·OS TTS·SQLite 파일·화면으로 온보딩(목표)→진단(L3)→준비(목표 기반 역할극·20분)→핸즈프리 음성·입력·힌트→백그라운드 일시정지·재개→결과·피드백·다시 말하기→홈 목표→성장 기록→복습→기록 검색→내보내기(토큰 없음)→재시작 후 유지, 39초 통과(`--dart-define=AI=scripted`). 실제 GPT 모드는 키체인 암호 창 때문에 사람이 있어야 함(평가 세트는 이미 통과). 실제 마이크 인식(`tool/stt_probe.dart` + `say`)은 macOS 권한 창 클릭 필요 → 미확인. 터미널에서 띄운 앱은 TCC가 음성 인식 접근 시 종료시킴(환경 제약, 앱 Info.plist는 정상) |
| P2-1 핸즈프리 | ✅ (코드) | AI가 말을 마치면 자동으로 듣기(설정 `voice.hands_free`, 기본 켬, 대화 화면 👂 토글·설정 스위치). 빈 결과 2회 연속이면 멈춤, 정지 버튼은 다음 AI 턴까지 재시도 안 함, 듣는 중에도 입력·빠른 동작 가능(듣기를 버리고 처리), 일시정지/재개·'읽어주기 없이 계속' 연동. 자동 끼어들기(AI 말하는 중 듣기)는 스피커 에코 문제로 보류. 테스트: 컨트롤러 8 + 위젯 1 |
| P2-2 말한 뒤 확인 | ✅ | 설정 `voice.confirm_speech`(기본 끔): 인식 결과를 입력칸에 띄우고 안내 → 고쳐서 보내기, 발화 추정치는 보낸 턴에 연결, 핸즈프리는 초안이 있으면 듣지 않음. 테스트: 컨트롤러 3 + 위젯 1 |
| P2-4 반복 실수·표현 복습 | ✅ (코드) | 최근 14일 같은 유형 교정 3회 이상 → 대화 프롬프트에 '집중 영역'(지적 없이 올바른 형태로 되받아 말하기, coach-v4), 최근 피드백 표현 5개 → `reuse_naturally`(기존 PromptComposer 필드 연결). 복습 화면에 '최근 배운 표현' + 넣어서 말하기(표현 포함 여부만 표시, 채점 없음). 실제 모델 평가에서 되받아 말하기가 안 됨 → 예시 포함 규칙(coach-v6)으로 수정, 평가 2회 연속 통과. 같은 평가에서 이야기 모드 첫 마디가 명령문(물음표 0개) → '반드시 질문 하나로 끝내기' 강화 |
| P2-9 접근성 | ✅ | `test/a11y`: 주요 화면 9곳에 Flutter 접근성 지침(라벨 있는 터치 영역, 48dp 터치 크기, 텍스트 대비 4.5:1) + 다크 모드 + 글자 2배·폰 폭(390) 넘침 없음. 발견·수정: 회색 보조 글자 대비 3.4 → 4.6(`inkMuted` #66717F), 빠른 동작 줄 색. 스크린리더: 말풍선에 '나:/코치:' 라벨, 상태 문구 live region, 듣는 중 🎤 툴팁 '듣기 멈추기'. 키보드: 기본 Tab/Space 조작(별도 단축키는 macOS 시스템 단축키와 충돌해 보류) |
| 실제 마이크 권한 | ✅ | 사용자 허용 후 앱이 음성 인식에 접근(`available: true`, 크래시 없음). 정확도는 Mac 스피커→내장 마이크 재생으로는 측정 불가(자기 출력 억제로 보임) → 사람 목소리 필요 |
| P2-5 오디오 환경 | ✅ (코드) | 인식 오류를 종류별로 구분(`SpeechIssue`: 무음/권한/네트워크/마이크/사용 중/기타, speech_to_text 오류 코드 매핑): 권한 → 입력 모드 + 설정 열기(macOS 개인정보 패널·iOS 앱 설정), 네트워크·마이크·사용 중 → 원인별 안내, 핸즈프리는 오류 시 재시도 안 함. **버그 수정:** 대화 화면에 마이크 사용 불가 안내가 아예 안 나오던 문제. iOS: TTS와 인식기가 오디오 세션 공유(playAndRecord + 스피커 기본 + 블루투스 허용) — 인식 후 답변이 수화기로 작게 나오는 문제 예방. iOS 빌드 확인. **남음: 블루투스 연결·해제 실기기 확인** |
| P2-8 두 번째 AI: Gemini 무료 | ✅ (코드) | ADR-015(Claude는 Anthropic 정책상 구독 무료 경로가 없어 제거). `data/providers/gemini`: streamGenerateContent SSE(생각 조각 제외, usage 실측: 출력+생각 토큰), 키는 vault·헤더만, 첫 턴 user·역할 교대 보정, 오류 매핑(API_KEY_INVALID/권한→invalidKey, 404→modelUnavailable, RESOURCE_EXHAUSTED·429·503→rateLimited). 모델은 무료 Flash-Lite만. `app/active_ai.dart`가 설정의 AI 선택을 매 호출마다 확인(대화·피드백·진단). 설정: AI 선택 + 키 입력(가림, 저장 즉시 비움, 확인은 모델 목록만) + 무료 등급 데이터 사용 고지. 테스트: 클라이언트 8 + 화면 흐름 2. 평가 세트 `--dart-define=AI=gemini`. **남음: 사용자 무료 키로 실제 평가** |
| P2-3 발화 지표(소리 크기) | ✅ (코드) | `domain/audio/voiced_time.dart`: 인식기 입력 레벨(onSoundLevelChange)로 말한 시간 측정. 플랫폼마다 단위가 달라(Apple dB, Android RMS) 절대값 대신 들은 범위의 최저(소음)~최고(말) 중 40% 이상 구간만 합산, 간격 250ms 초과는 제외, 범위 3 미만·보고 8개 미만이면 측정 안 함(null → 기존 인식 타이밍 추정으로 대체, 지어내지 않음). 모든 학습자 턴이 레벨로 측정되면 세션 신뢰도 0.7, 아니면 0.5. **남음: 실기기에서 기준값(40%·범위 3) 확인** |
| P2-1b 자동 끼어들기 | ✅ (코드) | 설정 '말하면 AI 말 끊기(이어폰 사용 시)'(`voice.auto_barge_in`, 기본 끔, 자동 듣기 켜져 있을 때만): AI가 말하는 동안 '지켜보기' 듣기를 열고 첫 단어가 인식되면 끼어들기(음성 즉시 중단 → 그 말을 학습자 턴으로), 아무 말 없으면 음성이 끝난 뒤 지켜보기를 닫고 평소처럼 자동 듣기. 스피커 에코 때문에 이어폰 전용 안내. 테스트 3. **남음: 실기기(이어폰) 확인** |
| P3 오류 기록·개인정보 검수 | ✅ | 서버 없는 오류 리포팅: 처리 안 된 오류(Flutter·플랫폼)를 기기의 `errors.jsonl`(최대 100건)에 기록 — 오류 종류·마스킹된 200자 메시지·앱 코드 위치만, 대화 없음. 설정 → 진단 정보 내보내기/오류 기록 지우기. 마스킹에 JWT(ChatGPT 토큰) 추가. arch_lint: 로그에 대화 내용·키 보간 금지(spec §16.2 자동 검사, 위반 샘플로 동작 확인). `docs/privacy-review.md` 데이터 목록·확인 8항목. **남음: 스토어 개인정보 라벨·처리방침(ADR-006 후)** |
| 앱 언어 선택 | ✅ | spec §3.1·S11: 기기 설정/한국어/English(`app.language`), 온보딩 첫 화면과 설정에서 변경, 즉시 반영. ko/en 문구 키 일치 확인 |
| P3 개인용 배포 | ✅ | v0.6.0 릴리스 APK 서명 `CN=Speaking Coach` 확인(첫 고정 키 버전). ADR-006 개인용 설치. Android 고정 릴리스 키(PKCS12 RSA 4096, 저장소 밖 `~/.speaking-coach-keys/`, GitHub Secrets 4개) → 업데이트 덮어 설치 가능, 로컬 서명 빌드 `CN=Speaking Coach` 확인. **버그 수정:** macOS 내보내기가 샌드박스 권한 없음으로 실패(Operation not permitted) — 다운로드 폴더 쓰기·사용자 선택 파일 읽기 권한 추가, 실제 Mac 파일 쓰기 integration_test로 확인. 백업 v2(턴 ID·복습 일정·설정 전체·학습 설정 화이트리스트, 키 없음) + 복원(병합: 같은 시작 시각·모드는 건너뜀, v1 파일도 원문으로 교정 연결, 잘못된 파일 거부) — 설정 → 백업 파일에서 복원(file_selector). 테스트: 왕복·중복·v1·거부 3 + 화면 1 |
| 인식 정확도·끊김 | ✅ (코드) | 사용자 보고(2026-10-18): 말한 것과 다른 단어, 말하는 중 끊김. (1) 후보 선택: 인식기가 주는 최대 10개 후보 중 맥락(AI 질문·주제·앞서 말한 말)과 단어가 더 많이 겹치는 후보를 고름(최상위 신뢰도 0.9 이상이면 그대로) — `domain/audio/alternate_choice.dart`. (2) Android 이어 듣기: 1~2초 멈춤으로 인식이 끝나도 바로 다시 듣고, 1.8초 안에 새 말이 없을 때만 턴 종료, 부분들을 이어 붙임(대화·진단 공통, 정지 버튼은 즉시 종료). Apple은 자체 3초 대기로 한 번만. 플러그인 콜백이 첫 인스턴스에 고정되는 문제도 수정. 테스트: 가짜 플랫폼으로 5개 + 후보 선택 4. **남음: 실기기 확인(Samsung 인식기는 재시작 시 효과음이 날 수 있음)** |
| 모바일 인식 개선 | ✅ (코드) | 사용자 보고(2026-10-18): 모바일 레벨 진단에서 음성 인식이 잘 안 됨. 원인 1: Android가 '듣기 끝' 상태를 최종 결과보다 먼저 보내 덜 정확한 부분 결과로 끝내고 있었음 → 최종 결과/완료를 최대 1.5초 기다림. 원인 2: Android가 1~2초 멈추면 듣기를 끝내 긴 답변이 잘림 → 진단 답변은 멈춰도 이어 듣고 이어 붙임(■ 또는 무음까지, 최대 90초, 앞서 말한 단어도 힌트). Android에 '기본 음성 인식 서비스를 Google로' 안내. 테스트 3. **남음: 실기기 확인, 대화 화면에도 이어 듣기 적용 여부** |
| 웹 앱(iOS 배포) | ✅ (코드) | ADR-016. Flutter web + GitHub Pages(`pages.yml`). 웹 대응: dart:io 대신 `PlatformInfo`, drift 웹 DB(공식 sqlite3.wasm·drift_worker.js 고정), fetch 스트리밍 클라이언트, 공유/다운로드 내보내기, ChatGPT 로그인 주소 붙여넣기(+화면 테스트), 웹 음성 인식 불가 안내, 개발 도구 숨김, PWA(한국어 이름·아이콘 새로 제작·테마색·홈 화면 메타·저장소 유지 요청). **헤드리스 Chrome 실제 확인:** 부팅, 온보딩, 목표 저장, ChatGPT 로그인 탭 열림(auth.openai.com), 붙여넣기 화면, 새로고침 후 기록 유지(IndexedDB). **남음: 아이폰 Safari 홈 화면 앱에서 음성 인식·실제 ChatGPT 로그인 확인** |
| 랜덤 주제 | ✅ (코드) | 사용자 요청(2026-10-18): 주제 칸에 '🎲 랜덤(AI가 정해요)' — 앱 목록에서 고르는 게 아니라 GPT가 직접 고름. 역할극은 '🎲 랜덤 상황'(상황·역할까지). `SessionSetup.aiTopic`, PromptComposer coach-v7 규칙(구체적 주제, 첫마디에 알리기, 세션마다 다른 시작 글자+접근 방식(목록 없이 다양성 유도), 최근 주제 회피 — 인용·정리). **실제 GPT 평가:** 숫자 시드만으로는 일상·테마 둘 다 '기억에 남는 식사'로 겹침 → 글자·접근 방식으로 바꾼 뒤 등대에서 한 달(가정)/시장/어릴 적 연(역할극)으로 다양해짐, 질문 1개 통과. 테스트 4 |
| 어순 체크·복습 | ✅ | 사용자 요청(2026-10-18). 피드백 JSON에 `word_order`(학습자 문장마다 최대 8개, 어순만 판정 — 시제·어휘는 보지 않음): 실제 대화 줄·정답 있음·단어 60% 이상 유지(재작성 아님)만 통과. 결과 화면 '어순 체크'(✅/↔, 바른 어순, 한국어 설명, N문장 중 M문장). 틀린 어순 → 복습에서 **교정된 문장을 소리 내어 반복**(사용자 정정: 단어 맞추기가 아님) — 🎤로 말하면 교정 문장과 단어·순서가 같은지만 판정(✅ 교정된 문장대로 / 조금 달라요, 점수 없음, 판정 공정성을 위해 인식 힌트 없음). 결과 화면 어순 행과 기존 교정 카드에도 같은 판정, 같은 답의 교정과 중복 제거, 약점 '문장 구조·어순'에 집계. 스키마 v5(corrections.kind), 백업·복원 포함. **실제 GPT:** 문법만 틀린 문장은 어순 맞음, 'Very much I like the seafood there.' → 'I like the seafood there very much.' |
| v0.7.2 | ✅ | 웹 앱(https://leejaegyung.github.io/eng-talk-/, version.json 0.7.2 확인) + 4개 설치 파일. Pages 환경에 `v*` 태그 배포 허용 |
| 반복 횟수·체크 박스 | ✅ | 사용자 요청(2026-10-18): 설정 → 복습 → 문장마다 반복 5회/10회(`review.repeats`, 백업 포함). 복습 카드마다 횟수만큼 체크 박스: 교정 문장대로 말하면 자동 체크, 인식이 틀려도 직접 체크/해제, '반복 n/N' → '반복 완료!'. 진행은 복습 화면을 보는 동안만 유지. 테스트 1(10회 설정·자동·오인식 무시·수동·완료) |
| 실제 모델 평가 CLI | ✅ (코드) | 사용자가 Xcode·Android Studio 삭제(2026-10-18) → macOS 통합 테스트(실제 GPT 평가)를 명령줄로 이전: `dart run tool/eval/sign_in.dart`(1회 브라우저 로그인, 토큰은 `~/.config/speaking-coach-eval/credentials.json` 0600 — OpenAI 문서의 CLI 방식), `flutter test tool/eval`(ChatGPT), `AI=gemini GEMINI_API_KEY=… flutter test tool/eval`. Flutter 없이 도는 data/domain 코드 그대로 사용. Android 빌드는 Homebrew SDK·JDK로 계속 가능, Mac·iOS 로컬 빌드는 불가(릴리스는 CI). **2026-10-18 사용자 로그인 후 실제 GPT 평가 10/10 통과(Xcode 없이)**, 자격증명 파일 권한 0600 확인 |
| P1-B2 발화 지표 | ✅ | AI 발화 = TTS 실측, 사용자 발화 = 인식기 첫/마지막 부분결과 간격(추정, confidence 0.5). 양쪽 다 있을 때만 비율 표시, 결과·홈에 '추정' 표기 |
| P1-B3 연결 끊김 | ✅ | network 실패 → paused(connectionLost) → 다시 연결(실패 요청 재시도) / 읽어주기 없이 계속 / 저장하고 끝내기 |
| P1-C1 모드 정책 | ✅ | 6모드 규칙(PromptComposer). **실제 모델 평가 세트 통과**(모드별 질문 1개·후속 질문·3문장 이하·마크다운 없음). 첫 실행에서 질문 2개 연달아 묻는 문제 발견 → 프롬프트 coach-v2로 수정 후 통과 |
| P1-C2 모드·주제 설정 | ✅ | S04/S05: 6모드, 레벨 L1~L5(저장), 모드별 주제 추천+직접 입력, 역할극 상황 8종 + 역할/상황/목표 직접 입력, 20/30/45분 |
| P1-D1 레벨 진단 | ✅ | 마이크 확인 → 질문 5개(읽어줌, 음성/입력) → 텍스트 루브릭 4항목(발음·유창성 평가 안 함 고지) → 레벨 매핑(짧은 답변은 상한) → 수락/변경 저장. 실제 모델 루브릭 파싱 확인 |
| P1-D2 홈·기록·복습 | ✅ | 홈 KPI(오늘/7일 발화 추정, 연속 학습일, 완료율, 평균 답변 단어, 복습 수, 추천 주제), 기록 검색·삭제, 간격 반복 1/3/7/14/30일 |
| P1-D4 학습 목표·성장 대시보드 | ✅ | spec §3.1·S10. 목표 5종(일상/여행/업무/면접/자신감 → 추천 모드)·하루 목표(10/20/30/45분): 온보딩 단계 추가(건너뛰기 가능)·설정에서 변경, 대화 준비 기본값(모드·길이)에 반영, 홈에 오늘 연습 시간(실측)/목표 진행 + 추천 모드. S10 성장 기록(7/30일): 연습 시간(실측)·말한 시간(추정, 있을 때만)·대화 수·평균 답변 길이·날짜별 막대, 자주 고친 부분(피드백 JSON에 category 4종 추가, 스키마 v4 + 데이터 보존 마이그레이션 테스트), 레벨 변화(진단 기록). **실제 모델 피드백 category 반환 확인**. 테스트 321, 폰 폭(360) 레이아웃 확인 |
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
