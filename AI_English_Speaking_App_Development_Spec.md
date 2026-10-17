# AI English Speaking Coach — 크로스플랫폼 애플리케이션 통합 개발 설계서

> 문서 버전: 1.0 | 작성일: 2026-10-17 | 상태: 구현 착수용 설계 초안  
> 대상: Windows / macOS / Android / iOS  
> 제품 유형: 개인 LLM API 키(BYOK)를 이용한 영어 회화 집중 학습 앱

---

## 0. 핵심 결정사항

- **앱:** Flutter + Dart (4개 플랫폼 단일 코드베이스)
- **상태 관리:** Riverpod, **라우팅:** go_router
- **로컬 DB:** SQLite(Drift 권장), 비밀정보: 운영체제별 보안 저장소(secure storage)
- **AI:** Provider Adapter를 통해 OpenAI 우선, Anthropic/Google 등 확장 가능
- **음성:** `Realtime Voice` 및 `STT → LLM → TTS` 두 가지 경로. 공급자마다 지원 범위가 달라 동일 기능을 보장하지 않음
- **보안:** BYOK 키는 절대 일반 DB, 로그, 분석 SDK에 저장하지 않음
- **실시간 세션:** 프로덕션에서는 인증된 중계/토큰 발급 백엔드를 사용. 순수 클라이언트 직접 호출은 위험을 명확히 고지한 개발용 옵션으로만 검토
- **MVP 운영:** 계정/클라우드 없이 로컬 중심으로 시작. 동기화·팀 운영·공유는 후속 단계
- **핵심 KPI:** 사용자 실제 발화 시간, 세션당 발화 턴, 영어 발화 비율, 대화 유지 시간, 7일/30일 재학습률

> 설계 목표의 **사용자 발화 80%**는 제품의 *목표 지표*이지 모델이 정확하게 보장할 수 있는 성질이 아니다. 음성활동탐지(VAD) 기반 추정과 세션 분석으로 측정하고 개선한다.

## 1. 제품 목표 및 범위

### 1.1 문제 정의

기존 영어 학습 앱은 설명·암기·객관식이 많아 실제 영어 발화 기회가 부족하다. 본 앱은 AI가 질문을 짧게 던지고 사용자가 길게 답하도록 구성해 일상/특정 테마/역할극/즉흥 발화에 대한 반복 실전 경험을 제공한다.

### 1.2 사용자 가치

1. 마이크를 켜자마자 영어 말하기를 시작한다.
2. 대화가 막힐 때 단계적 힌트를 받아 스스로 발화를 완성한다.
3. 과도한 실시간 지적 대신 대화 후 집중 교정을 받는다.
4. 이전에 틀린 표현을 새 대화에서 다시 사용할 수 있다.
5. 자신의 API 키로 모델을 선택하고 예상 사용량과 비용을 확인한다.
6. PC와 모바일에서 일관된 학습 경험을 제공한다.

### 1.3 포함 / 제외

**MVP 포함:** 기초 진단, 5단계 레벨, 6개 회화 모드, 음성·텍스트 대화, 세션 대화록, 세션 피드백, 로컬 통계, BYOK 설정, 키 확인, 마이크 권한, 기본 비용 안내.

**MVP 제외:** 소셜 커뮤니티, 강사 마켓, 영상 통화, 다인원 회화, 실시간 정밀 발음 채점, 서버 기반 멀티 디바이스 자동 동기화, 결제/구독, 자체 AI 모델 훈련.

## 2. 학습 원칙 및 경험 설계

### 2.1 핵심 정책

- 사용자 발화 시간 목표 ≥ 80%(측정 가능할 때); 결과 화면에는 실측 기준과 추정치 표시
- AI 응답은 짧게, 질문은 한 번에 하나씩
- 사용자가 1~2문장으로 답하면 이유·예시·감정·경험으로 확장
- **질문 → 기다림 → 사용자 응답 → 짧은 공감 → 후속 질문** 루프
- 기본 교정은 5~10분 단위 또는 종료 시, 즉시 교정은 요청이나 의사소통 장애 시
- 발음을 실제로 분석하지 못하면 발음 점수를 생성하지 않음
- 틀린 문장을 억지로 반복시켜 대화를 막지 않으며 자연스럽게 재사용 기회 제공
- 사용자 수준에 맞춰 속도/문장 길이/질문 난이도 조정

### 2.2 학습 단계

| 단계 | 초점 | 대표 주제 | 진급 판단 예시 |
|---|---|---|---|
| L1 | 기초 문장 | 자기소개/취미/일과 | 도움을 받아 3~5문장 연속 발화 |
| L2 | 친숙한 대화 | 계획/감정/과거 경험 | 친숙한 주제로 약 1분 설명 |
| L3 | 상황 대응 | 여행/식당/호텔/직장 | 핵심 역할극을 도움 없이 완료 |
| L4 | 의견 표현 | 비교/찬반/이유 | 근거 포함 2~3분 논리적 발화 |
| L5 | 프리토킹 | 자유 주제/즉흥 대응 | 다양한 질문에 5분가량 대화 지속 |

*CEFR은 참고 척도이며 레벨을 CEFR 공인 인증으로 표현하지 않는다.* 진급은 여러 세션과 루브릭 추세에 따라 제안하고 사용자가 수락한다.

### 2.3 회화 모드

1. `daily`: 일상 프리토킹 — 하루·취미·경험, 높은 후속 질문 밀도
2. `theme`: 테마 대화 — 사용자가 선택한 주제에 대해 깊게 확장
3. `roleplay`: 상황 역할극 — 상대 역할, 장소, 목표, 예상 돌발 상황
4. `random`: 랜덤 스피킹 — 즉흥 질문 및 회피 없는 답변 연습
5. `storytelling`: 경험·이야기 — 사건 순서, 감정, 배경, 결말까지 긴 발화
6. `opinion`: 의견/토론 — 주장·근거·반례·절충안

### 2.4 세션 구성(기본 30분)

- 3분: 워밍업 (말하기)
- 4분: 표현 활성화 (짧은 힌트 및 직접 응답)
- 18분: 집중 회화 (발화량 우선)
- 5분: 교정·복습·다음 학습 추천

20/30/45분 프리셋 및 사용자 지정 가능. 시간은 기본값이며 대화 흐름에 따라 조정한다.

### 2.5 최초 진단

1. 안내/마이크 테스트 → 2. 간단한 자기소개 → 3. 일과 설명 → 4. 과거 사건 → 5. 취향·이유 → 6. 즉흥 대응 → 7. 임시 레벨 제안.

평가 차원: 응답 적합성, 문장 형성, 어휘 다양성, 대화 지속성, 유창성(측정 가능하면), 발음(음성 품질과 실제 음성평가 기능을 확보한 경우에만). 짧은 진단의 정확도 한계를 고지한다.

## 3. 사용자 흐름과 화면 명세

### 3.1 온보딩

`언어/접근성 선택 → 개인정보·음성 처리 안내 → API 제공업체 선택 → API 키 안전 등록 → 연결/권한 테스트 → 학습 목표·일일 시간 선택 → 마이크 테스트 → 최초 진단 → 홈`

API 키 없이도 **데모/화면 탐색**은 가능하되 외부 AI 회화는 사용 불가. 연결 실패 시 잘못된 키/잔액 부족/요청 제한/네트워크 문제를 구분해 안내한다.

### 3.2 주요 화면

| ID | 화면 | 핵심 요소 |
|---|---|---|
| S01 | 온보딩/권한 | 목적 안내, 마이크/개인정보 동의 |
| S02 | API 설정 | Provider, 모델, 키 저장, 연결 테스트, 사용량 안내 |
| S03 | 홈 | 오늘의 목표, 시작 버튼, 추천 모드, 연속 학습일 |
| S04 | 학습 모드 선택 | 6개 모드, 난이도, 주제, 시간 |
| S05 | 테마/역할 설정 | 검색·추천 주제, 상대방 역할, 상황 목표 |
| S06 | 라이브 회화 | 마이크 상태, AI 상태, 간략 자막, 힌트, 일시정지, 종료 |
| S07 | 교정 화면 | 내 문장 → 자연스러운 문장 → 다시 말하기 |
| S08 | 세션 결과 | 대화 시간, 내 발화량, 턴 수, 강점/교정 항목 |
| S09 | 학습 기록 | 날짜·모드별 기록, 검색, 재학습 |
| S10 | 성장 대시보드 | 주/월 발화 시간, 약점, 레벨 추이 |
| S11 | 설정 | API/음성/언어/보관/내보내기/초기화 |

### 3.3 라이브 화면 UX

- 중앙 음성 파형 또는 큰 마이크 버튼, 상태: `연결 중 / 듣는 중 / 생각 중 / AI가 말하는 중 / 일시정지`
- 큰 자막(사용자 발화/AI 질문), 자막 숨기기 지원
- `힌트`, `다시 말해줘`, `천천히`, `이 문장 교정`, `주제 변경`, `종료`
- **기본 화면에는 점수/실수 카운터 노출 금지** (발화 위축 방지)
- 화면 잠금·앱 백그라운드 진입 시 플랫폼별 마이크 정책 준수; 권한 제한 시 적절한 일시정지
- 접근성: Dynamic Type, 키보드/스크린리더, 저시력 대비, 진동 대신 시각 알림

## 4. 시스템 아키텍처

```text
┌───────────────────────────────────────────────────┐
│ Flutter app (Windows/macOS/Android/iOS)           │
│ UI + Riverpod + Session Orchestrator              │
│ Audio I/O + VAD + Prompt/Mode Engine               │
│ Learning Analytics + Local SQLite                 │
│ Key Reference → OS Secure Storage                 │
└───────────────┬───────────────────┬───────────────┘
                │                   │
        Standard AI path        Realtime voice path
                │                   │
      Provider HTTP API     Authenticated token broker
         (policy-based)       + ephemeral credentials
                │                   │
    STT → LLM → TTS        Provider realtime session
                └─────────┬─────────┘
                          │
                  Session events, turns,
                  corrections, local stats
```

### 4.1 백엔드 전략

**MVP 추천: 로컬 우선 + 최소 인증 중계 서비스**

- 텍스트 요청 및 별도 STT/TTS는 공급자 정책에 맞춰 동작. 개인 키를 사용자가 직접 입력하더라도 악성 앱·클라이언트 분석·로그 노출 위험은 0이 아님.
- 실시간 음성은 단기 세션 자격증명 발급을 위해 인증된 **세션 브로커**를 우선 도입.
- BYOK의 서버 경유 방식에서는 사용자의 원본 키를 서버가 **일시적으로 취급**할 수 있다. 영구 저장 금지, 요청 본문/헤더 마스킹, 메모리 생명주기 최소화, TLS, 제한 정책을 반드시 적용한다.
- 브로커가 사용자 키를 수신하지 않는 설계는 공급자 인증 방식에 따라 제약이 있으므로 제품 정책 결정이 필요하다. “서버에 키를 절대 전달하지 않는다”는 약속과 “서버가 사용자 키로 토큰을 발급한다”는 구조를 동시에 주장하지 않는다.
- 브로커 운영을 원치 않는 경우: 첫 출시에서는 **STT→LLM→TTS 방식만 제공**하고 Realtime은 차기 기능으로 연기하는 것이 안전한 대안.

### 4.2 컴포넌트 책임

- `ConversationSessionController`: 대화 시작/종료, 타임아웃, 이어말하기, 상태 전환
- `ConversationPolicyEngine`: 학습 단계, 대화 모드, 힌트 단계, 교정 타이밍
- `PromptComposer`: 기본 프롬프트 + 모드 + 레벨 + 세션 요약을 안전하게 합성
- `LLMProvider`: 공급자별 요청, 스트리밍, 오류 정규화
- `VoiceProvider`: realtime/STT/TTS 가능 여부와 플랫폼별 장치 선택
- `AudioCapture`: 권한, 마이크, 볼륨 미터, 음성 구간 탐지
- `FeedbackService`: 대화 기록 기반 세션 후 주요 오류 추출
- `ProgressService`: 통계 집계와 복습 큐 작성
- `CredentialVault`: API 키 저장/조회/삭제 (OS 보안 저장소)

## 5. 권장 폴더 구조

```text
english_speaking_coach/
├── apps/
│   └── flutter_app/
│       ├── lib/
│       │   ├── app/                   # theme, routes, bootstrap
│       │   ├── core/                  # errors, logging, security
│       │   ├── features/
│       │   │   ├── onboarding/
│       │   │   ├── provider_settings/
│       │   │   ├── home/
│       │   │   ├── assessment/
│       │   │   ├── conversation/
│       │   │   ├── feedback/
│       │   │   ├── progress/
│       │   │   └── history/
│       │   ├── domain/                # entities, use_cases, interfaces
│       │   ├── data/                  # drift, repositories, API adapters
│       │   └── main.dart
│       ├── test/
│       └── integration_test/
├── services/
│   └── session_broker/                # FastAPI, optional for staged release
│       ├── app/                       # authentication, session, rate-limit
│       └── tests/
├── packages/
│   └── prompt_assets/                 # prompts and versioned rubrics
├── docs/
│   ├── architecture.md
│   ├── privacy-security.md
│   ├── api-contracts.md
│   └── release-checklist.md
└── .github/workflows/                 # CI (빌드 매트릭스)
```

## 6. 모델 공급자 추상화

### 6.1 기본 인터페이스(의사코드)

```dart
abstract interface class LlmProvider {
  Future<ProviderHealth> testConnection();
  Stream<AssistantDelta> streamChat(List<ConversationMessage> messages,
      ConversationSettings settings);
  Future<FeedbackResult> evaluateSession(SessionSummary summary);
}

abstract interface class VoiceProvider {
  Future<AudioTranscript> transcribe(AudioChunk audio);
  Stream<AudioChunk> synthesize(String text, VoiceSettings settings);
  Future<VoiceSession> startRealtime(RealtimeSessionConfig config);
  ProviderCapabilities get capabilities;
}
```

`ProviderCapabilities`: `supportsStreamingText`, `supportsRealtimeAudio`, `supportsStt`, `supportsTts`, `supportsTranscript`, `supportsUsage`, `supportsInterruptions`, `supportedPlatforms` 등. 지원 불가 조합은 UI에서 비활성화하거나 폴백으로 전환한다.

### 6.2 BYOK 모델 선택

- 공급자 선택: OpenAI / Anthropic / Gemini / 사용자 지정 호환 엔드포인트(후속)
- API 키 입력 및 마스킹, 저장 전 확인, 폐기/교체
- 모델 선택은 **최신 모델 목록 조회 또는 설정 가능한 공급자 카탈로그**를 사용; 모델 ID 하드코딩을 피한다.
- 텍스트 LLM과 음성(STT/TTS) 공급자를 각각 지정 가능. 한 공급자가 모든 음성 기능을 제공한다고 가정하지 않는다.
- 예상 비용은 해당 공급자의 실제 가격표/사용량 정보가 확보될 때만 표시, 지원하지 않으면 `비용 정보 없음`으로 표시
- ChatGPT/Claude 웹 구독과 API 청구는 별개일 수 있다는 안내 제공

## 7. 실시간 음성 엔진 상세

### 7.1 모드 A: 실시간 양방향 음성

적합 대상: 짧은 응답 지연, 자연스러운 끼어들기, 연속 대화.

1. 사용자가 대화 시작
2. 앱이 본인 인증 및 사용 가능 세션 확인
3. 브로커가 공급자 방식에 맞는 세션용 단기 인증 정보를 발급
4. 앱에서 WebRTC 등 공급자 지원 전송 방식으로 연결
5. 마이크 입력 전송, AI 오디오 수신, UI 이벤트 기록
6. 턴/대화록/사용량 이벤트 보관
7. 종료 시 결과 평가 요청 및 로컬 저장

**중요:** 실제 공급자 API의 필드, 모델, 세션 제한, 전송 프로토콜은 구현 시 공식 문서에 맞춰 검증. 브로커에서 장기 API 키를 앱에 재노출하지 않는다.

### 7.2 모드 B: STT → LLM → TTS

적합 대상: 공급자 범용 지원, 세션 관리 단순화, 텍스트 교정 용이.

```text
Mic → VAD / 음성 구간 확정 → STT → 대화 정책 엔진
    → LLM (짧은 응답 + 질문) → TTS → Speaker
                                      ↓
                               Transcript 저장
```

- LLM 텍스트 스트리밍과 TTS chunking은 지원 시 사용
- 저지연이 안 되는 환경에서는 사용자에게 상태 표시 및 텍스트 응답 폴백
- 실패한 음성 요청은 중복 과금 방지/리플레이 위험을 고려해 재시도 정책 차등 적용
- 녹음 파일 저장은 **기본 비활성화**하고 명시적 동의 시에만 저장

### 7.3 턴 제어 / 끼어들기

상태 머신:

`idle → connecting → listening → user_speaking → processing → ai_speaking → listening → paused → ended`

- 사용자 발화 중 AI 출력이 시작되지 않게 제어
- 침묵은 즉시 오류로 간주하지 않음. 힌트는 사용자가 요청하거나 설정된 긴 대기 후 제안
- AI 발화 도중 사용자 발화 감지 시 가능한 공급자에서 출력 중단(barge-in)
- 오디오 처리 지연과 UI 이벤트의 순서 역전을 방지할 시퀀스 ID 부여
- 네트워크 종료 시 `재연결 / 텍스트로 계속 / 세션 저장 후 종료` 옵션

### 7.4 발화 지표 측정

- `user_speech_ms`: 사용자 실제 음성 구간 누적
- `assistant_speech_ms`: AI 실제 출력 구간 누적
- `speaking_ratio = user_speech_ms / (user_speech_ms + assistant_speech_ms)`
- `turn_count`, `avg_user_turn_ms`, `longest_user_turn_ms`, `followup_count`
- VAD/에코/중첩 발화로 인한 오차를 표시하고 **발화시간 80%와 세션 전체 시간 80%를 혼동하지 않는다**.

## 8. 프롬프트 엔진 및 AI 행동 계약

### 8.1 구성 계층

1. `system`: 역할·안전·발화 중심 목표·출력 규칙
2. `developer`: 세션 종류·힌트/교정 로직·응답 길이 제한
3. `context`: 레벨, 관심 주제, 최근 취약 표현, 오늘 학습 목표
4. `messages`: 실제 대화 이력(토큰 예산에 맞춰 요약/절단)
5. `output schema`: 질문/교정/피드백 등 유형별 JSON 스키마(지원 시)

### 8.2 공통 마스터 프롬프트(앱 내부 리소스)

```text
ROLE: You are a friendly, adaptive, one-on-one English speaking coach.
PRIMARY GOAL: Maximize the learner's spoken English practice.
BEHAVIOR:
- Keep your spoken turns brief and natural, generally 1-2 short sentences.
- Ask only one clear question at a time, then wait for the learner.
- Encourage longer answers with context-appropriate follow-up questions.
- Do not interrupt for minor grammar errors.
- Wait patiently. If asked for help, give a word hint, then sentence starter,
  then Korean explanation, then an example only as a last resort.
- Prioritize natural conversation over lectures and grammar explanations.
- Use the learner's current level and selected conversation mode.
- Provide feedback after the session or at requested intervals.
- Never invent phonetic scores unless an audio-based measurement is available.
- When the learner is stuck, reduce complexity but preserve speaking practice.
- Let the learner speak; don't answer your own question.
SESSION:
mode={{mode}}; learner_level={{level}}; topic={{topic}};
goal={{goal}}; feedback_style={{feedback_style}}.
```

### 8.3 모드별 추가 규칙

- Daily: 친구처럼 짧게 공감하고 후속 질문; 인터뷰 형식 반복 방지
- Theme: 한 주제에서 구체 사례·비교·가정·과거/미래로 확장
- Roleplay: 설정된 역할 유지, 목표에 도달하면 추가 상황 제안
- Random: 이전 질문의 반복 방지, 난이도는 유지하되 주제 다양화
- Storytelling: 사용자가 말하는 중간에 끼어들지 않음; 이야기 흐름 유도
- Opinion: 반론은 공격적이지 않게, 주장→근거→예시를 유도

### 8.4 교정 JSON 출력 계약(예시)

```json
{
  "session_id": "uuid",
  "strengths": ["Used a clear example"],
  "corrections": [
    {
      "original": "I go there yesterday",
      "suggested": "I went there yesterday.",
      "explanation_ko": "과거 경험이므로 went를 사용해요.",
      "severity": "medium",
      "practice_prompt": "Tell me again what you did yesterday."
    }
  ],
  "expressions": ["That reminds me of..."],
  "next_topic": "Weekend plans"
}
```

- 모델 JSON은 스키마 검증 후 저장하며 내용에 없는 사용자 발화를 ‘원문’으로 꾸미지 않도록 transcript turn ID와 연결
- 교정 우선순위 2~3개, 표현 추천 5개(설정 가능)
- 근거가 부족하면 점수 생략

## 9. 로컬 데이터 모델

### 9.1 핵심 테이블

| 테이블 | 주요 컬럼 | 설명 |
|---|---|---|
| `profiles` | id, locale, target_minutes, active_level, created_at | 로컬 학습자 설정 |
| `providers` | id, name, model_id, vault_key_ref, settings_json | 키 원문 대신 vault 참조 |
| `sessions` | id, mode, topic, level, started_at, ended_at, status, provider_id | 회화 세션 |
| `turns` | id, session_id, speaker, transcript, started_at, ended_at, word_count | 대화 턴 |
| `speech_metrics` | session_id, user_ms, assistant_ms, turn_count, confidence | 발화 지표 |
| `assessments` | id, session_id, rubric_json, assessed_at | 진단/레벨 평가 |
| `corrections` | id, session_id, turn_id, original, suggested, explanation, practiced | 교정 기록 |
| `expressions` | id, phrase, meaning_ko, difficulty, source_session_id | 표현 카드 |
| `review_queue` | id, expression_id, due_at, interval_days, repetitions | 간격 반복 |
| `usage_events` | id, provider_id, model_id, tokens_in, tokens_out, audio_seconds, estimated_cost, timestamp | 비용 참고 |
| `app_settings` | key, value | 일반 환경 설정 |

### 9.2 저장/삭제 정책

- 대화록은 로컬 저장, 세션별 삭제/전체 삭제 지원
- 음성 원본 미저장 기본값. 녹음 옵션 활성화 시 암호화 저장, 보관기간 선택
- API 키는 SQLite에 저장 금지
- 백업 파일에는 키 포함 금지, 내보내기는 JSON/CSV 및 암호화 백업 옵션
- 클라우드 백업/OS 자동 백업 대상 범위 확인 및 민감정보 제외 정책 적용
- 선택형 동기화를 도입하면 명시적 동의, 암호화·계정 복구·삭제 정책을 별도 설계

## 10. 선택형 세션 브로커 API

FastAPI + HTTPS 권장. 다음은 애플리케이션 내부 계약의 예시이며 외부 AI API 경로와 다르다.

| Method | Path | 목적 |
|---|---|---|
| POST | `/v1/sessions/realtime-token` | 짧은 수명의 세션 자격증명 발급 |
| POST | `/v1/provider/test` | 프록시 방식 공급자 연결 확인 (필요 시) |
| GET | `/healthz` | 기본 헬스 체크 |

### 10.1 토큰 발급 계약 예시

```json
// request (TLS + authenticated session)
{
  "provider": "openai",
  "model": "configured-realtime-model",
  "client_session_id": "uuid"
}
```

```json
// response
{
  "session_id": "uuid",
  "ephemeral_token": "<short-lived-token>",
  "expires_at": "<ISO-8601-time>",
  "connection": { "transport": "webrtc" }
}
```

**BYOK 원본 키 전달 흐름은 별도 보안 정책 확정 필요:** 요청 body에 원본 키를 무작정 넣는 인터페이스는 추천하지 않음. 서버가 키를 보유하지 않는 설계가 공급자 API와 양립하는지 확인 후 (A) 사용자가 동의하는 일시적 키 전달, (B) 서버 측 암호화 키 보관, (C) 브로커 기능 비활성화 중 결정. API 키를 이용한 토큰 발급에는 결국 서버 측 자격증명 취급이 필요할 수 있다.

### 10.2 보안 요구사항

- TLS, 인증·권한 확인, 요청별 rate limit, 브로커 abuse 방지
- 로그/API 오류에 키·토큰·음성·대화 원문 미기록
- 토큰 유효기간 최소화, 가능한 범위의 세션/모델 권한 제한
- 공급자별 요청 금액/량 상한 및 고객별 사용량 제한
- CORS는 허용된 클라이언트/도메인으로 제한, 모바일 앱의 인증은 CORS를 보안장치로 오해하지 않음
- 장기 키 보호 및 침해 대응: 키 교체·폐기·장애 시 정책
- 메모리 덤프/디버그 로그/크래시 리포트 내 시크릿 보호

## 11. API/모델 오류 정책

| 상황 | 앱 행동 |
|---|---|
| 키 오류/권한 없음 | 사용자에게 공급자 설정 확인 및 키 교체 안내 |
| 잔액 부족/청구 문제 | 과금 안내, 회화 세션 안전 저장 |
| 모델 미지원/접근 제한 | 지원 모델 다시 선택 또는 폴백 추천 |
| rate limit | 백오프, 계속 재시도 방지, 남은 대화 저장 |
| 네트워크 끊김 | 재연결 제안, 턴 데이터 복구, 텍스트 대체 |
| 마이크 거부 | 플랫폼 권한 설정 안내, 텍스트 모드 전환 |
| 음성 품질 저하 | 헤드폰 권장, 잡음/마이크 테스트 제공 |
| 잘못된 JSON 피드백 | 스키마 재요청 1회 후 안전한 축약 결과 제공 |
| 비용 확인 불가 | 임의 비용 생성 금지, `정보 없음` 표시 |

## 12. 발화·학습 분석

### 12.1 홈 KPI

- 오늘 실제 말한 시간(분)
- 최근 7일 총 발화 시간
- 총 연습 세션/완료율
- 평균 사용자 턴 길이
- 추천 복습 문장 수
- 월별 레벨 평가 변화(충분한 근거가 있을 때만)

### 12.2 세션 종료 보고서

```text
오늘의 주제: 여행 중 호텔 체크인
연습 시간: 25분 40초
내 발화(추정): 13분 20초
AI 발화(추정): 4분 10초
내 발화 비율: 76.2% (발화 시간만 기준)
내 답변 턴: 31회
강점: 질문에 적절히 응답하고 예시를 들어 설명함
교정: 어제 일의 과거시제, 관사 사용
내일 복습: 3문장
```

*숫자는 화면 테스트용 예시이며 실제 구현에서는 이벤트 데이터로 계산.*

### 12.3 복습 추천

- 같은 오류가 여러 번 발생한 문장 우선
- 복습 시 AI가 동일 표현을 자연스럽게 사용할 주제 선택
- 단순 카드 암기보다 **다시 말하기**를 기본 액션으로 제공
- 기록이 없거나 접근 불가하면 개인화했다고 주장하지 않음

## 13. 보안·개인정보·운영 정책

1. 사용자에게 외부 모델로 텍스트/음성이 전송되는 범위 명시
2. 개인정보 처리방침에 사용 공급자, 데이터 보관/전송, 삭제 방법 설명
3. 대화와 API 키의 저장 경로 분리
4. 진단/로그/충돌보고 도구에 대화록 및 시크릿 기본 수집 금지
5. 보안 저장소를 사용할 수 없는 데스크톱 환경은 키 저장 불가 경고 또는 세션 한정 사용
6. 모바일의 마이크 사용 표시·권한 요청·백그라운드 정책 준수
7. 배포 시 앱 서명 및 업데이트 무결성 검증
8. 악성 프롬프트/간접 명령 삽입에 대비: 대화 내용은 시스템 정책을 변경하는 지시로 취급하지 않음
9. 아동 사용자 대상 서비스로 확장 시 별도 법률/동의 검토
10. 실제 서비스 공개 전 한국 및 대상 국가의 개인정보 규정과 앱스토어 규정 검토

## 14. 플랫폼별 고려사항

| 대상 | 주요 작업 | 산출물 |
|---|---|---|
| Windows | 마이크 권한·오디오 장치 변경·코드 서명·자동 업데이트 | `.msix` 또는 설치 프로그램 |
| macOS | 마이크 사용 설명, sandbox/hardened runtime 검토, notarization | 서명된 `.dmg`/`.pkg` |
| Android | 녹음 권한, 오디오 포커스, 백그라운드 제한, 기기별 오디오 테스트 | `.aab`/테스트용 `.apk` |
| iOS | 마이크 권한, 오디오 세션, 인터럽트/전화 수신 대응, 스토어 심사 | App Store/TestFlight 빌드 |

Flutter 자체가 4개 플랫폼을 지원하더라도 **오디오 플러그인, WebRTC, 보안 저장소, 시스템 권한, 라이브러리 호환성은 각 플랫폼에서 별도 통합 테스트**가 필요하다. iOS 빌드는 macOS/Xcode 환경이 필요하다.

## 15. 단계별 개발 로드맵

### Phase 0 — 기술검증(PoC)

- [ ] Flutter 앱 Windows/Android/macOS/iOS 각각 실행
- [ ] OS 마이크 권한, 녹음/재생, 헤드셋 전환 검증
- [ ] 최소 1개 공급자 BYOK 연결 테스트
- [ ] 음성 파이프라인 왕복 지연 측정
- [ ] Realtime 시 인증 중계 방식 및 비용 검증
- [ ] Drift/보안 저장소 4개 플랫폼 동작 확인

**종료 기준:** 4개 대상 플랫폼에서 최소 1회 음성 대화 성공(Realtime 미지원은 STT 경로), 키 저장 테스트 통과.

### Phase 1 — 핵심 MVP

- [ ] 온보딩/설정/키 등록 및 삭제
- [ ] 최초 레벨 진단 및 임시 레벨
- [ ] 6가지 모드와 테마 선택
- [ ] 라이브 대화 화면(텍스트 + 음성)
- [ ] 짧은 AI 질문 및 후속 질문 정책
- [ ] 세션 저장/중단/복구
- [ ] 핵심 오류 교정 및 재발화
- [ ] 세션 요약/복습 목록

**종료 기준:** 사용자 30분 세션을 시작→종료→복습까지 오류 없이 수행.

### Phase 2 — 실전 품질 개선

- [ ] 대화 중 끼어들기 및 AI 출력 중단
- [ ] 공급자 2개 이상 플러그인 지원
- [ ] 발화시간 통계 및 품질 신뢰도
- [ ] 사용 비용 추적과 제한
- [ ] 반복 표현 복습 및 성장 대시보드
- [ ] 오디오 환경별 성능 튜닝

### Phase 3 — 배포와 확장

- [ ] 자동 CI·서명·설치 파일 생성
- [ ] TestFlight/Play 내부 테스트
- [ ] 오류 리포팅 및 개인정보 검수
- [ ] 선택형 계정/암호화 동기화 검토
- [ ] 접근성/현지화/고급 학습 옵션

## 16. 테스트 전략 / 인수 기준

### 16.1 기능 테스트

- 키 저장 후 앱 재시작, 재연결 성공
- 키 삭제 후 저장소·메모리 참조 제거 확인
- 잘못된 API 키와 연결 실패 메시지 정확성
- Daily/Theme/Roleplay/Random/Storytelling/Opinion 각각 대화 시작/종료
- AI가 한 번에 여러 질문을 남발하지 않는지 평가 세트로 검사
- 1문장 답변 후 적절한 후속 질문을 생성하는지 확인
- 교정 항목이 실제 transcript와 대응하는지 검증
- 미저장 음성 원본이 파일로 남지 않는지 확인
- 세션 강제 종료 및 복구 동작

### 16.2 비기능 목표(초기 목표값; PoC로 재설정)

- 사용자 발화 목표 80%, 세션 분석에 목표 대비 달성 여부 제공
- 음성 왕복 지연: 실측 후 50/95 백분위수 공개, 공급자/네트워크별 기록
- 크래시 없는 세션 비율 ≥ 99% (안정화 단계 목표)
- 모든 화면에 키보드 및 접근성 경로 확보
- 개인정보가 로그에 기록되지 않음을 자동 검사
- 대화 백업/삭제/복원 테스트 성공

### 16.3 QA 시나리오

- 오프라인 전환/간헐적 네트워크/고지연 모바일 데이터
- Bluetooth 이어폰 연결/해제, 마이크 장치 교체
- 전화 수신·앱 전환·잠금·최소화
- 영어/한국어 혼합 발화 및 긴 침묵
- AI 응답 중 사용자 끼어들기
- 토큰 만료·키 회전·권한 취소
- 과금 한도 도달 및 공급자 장애

## 17. 개발 우선순위 / 백로그

| 우선도 | 작업 | 비고 |
|---|---|---|
| P0 | 앱 구동, 권한, 오디오 입출력 | 플랫폼 위험 선검증 |
| P0 | BYOK 보안 저장, 연결 테스트 | 민감 정보 보호 |
| P0 | 대화 엔진, 정책·프롬프트, 대화 기록 | 제품의 핵심 |
| P0 | 6개 모드, 레벨 진단, 피드백 | 학습 흐름 완성 |
| P1 | Realtime 음성 엔진, 세션 브로커 | 공급자 제약에 따라 출시 단계 조정 |
| P1 | 발화 시간 지표, 반복 연습 | 목표 KPI |
| P1 | Windows/macOS/iOS/Android E2E 테스트 | 출시에 필요 |
| P2 | 여러 공급자, 비용 대시보드, 동기화 | 확장성 |

## 18. 개발자가 바로 수행할 최초 작업

1. Flutter stable 프로젝트 생성 및 각 플랫폼 활성화
2. `go_router`, `flutter_riverpod`, Drift, secure storage 후보 플러그인 설치
3. 각 플랫폼에서 마이크 녹음/재생과 권한 PoC
4. `LlmProvider`/`VoiceProvider` 추상화 및 mock 구현
5. `SessionController` 상태 머신 구현 및 단위 테스트
6. 로컬 SQLite 테이블/마이그레이션 구현
7. Provider Settings → Daily Conversation → Feedback 순서로 세로 슬라이스 개발
8. Realtime 인증 중계 여부 결정 및 위협 모델 리뷰
9. 4개 플랫폼 자동/수동 QA 매트릭스 작성
10. 버전별 프롬프트 A/B 테스트용 평가 대화 세트 마련

## 19. 미결정 사항 (구현 전 명시적으로 선택)

- **실시간 음성 출시 방식:** PoC 통과 시 MVP 포함 vs 일반 STT→LLM→TTS 먼저 출시
- **BYOK 원본 키 처리:** 순수 로컬(가능 기능 제한) vs 일시적 인증 브로커 경유(개인정보 고지/보안 강화 필수)
- **로그인:** 최초 버전 계정 없음(추천) vs 계정/기기 동기화
- **원본 녹음:** 저장하지 않음(추천) vs 명시적 동의 저장
- **첫 공급자:** OpenAI 우선(추천), 나머지 Provider Adapter로 순차 구현
- **배포 방식:** 개인용 사이드로드 vs 앱스토어 공식 출시

**본 문서의 기본 선택:** `Flutter + local-first + OpenAI 우선 + STT 방식의 안정적 폴백 + 검증 후 Realtime 활성화 + 로컬 계정 불필요 + 원본 녹음 미저장`.

## 20. 공식 참고 문서

- Flutter 지원 플랫폼: https://docs.flutter.dev/reference/supported-platforms
- Flutter 플랫폼 통합: https://docs.flutter.dev/platform-integration
- OpenAI Realtime WebRTC 및 인증 중계: https://developers.openai.com/api/docs/guides/voice-webrtc
- OpenAI Realtime client secrets: https://developers.openai.com/api/reference/resources/realtime/subresources/client_secrets/methods/create

> **주의:** AI 모델 이름, API 파라미터, 플랫폼별 플러그인 지원, 가격, 앱스토어 정책은 구현/출시 직전에 공식 문서에서 재확인한다. 문서는 제품/아키텍처/테스트에 관한 개발 기준이며 아직 구현된 앱은 아니다.
