# 진행 보드

> 세션 시작 시 자동 주입된다. 태스크를 끝낼 때마다 갱신한다. 짧게 유지하고 오래된 상세는 "기록"으로 옮긴다.

**현재 Phase:** 0 (PoC)
**대상 플랫폼:** macOS·Windows 데스크톱 (Mac에서 개발), Galaxy는 APK 배포 후 확인 (ADR-009)
**다음 태스크:** P0-T3 오디오 PoC (macOS 녹음·재생·진폭 VAD)
**Phase 0 순서:** T7 → T4 → T5 → T3 → T6(키·과금, 실행 전 확인). T2는 사용자 Windows 실행 확인 대기

## 상태
| 태스크 | 상태 | 증거 / 메모 |
|---|---|---|
| 하네스 구성 | ✅ | 훅 4종 동작 확인(포맷 훅 실제 적용됨), arch_lint 위반 샘플 5종 검출 |
| 기획 문서 | ✅ | roadmap, phase-0, phase-1, decisions(ADR-001~009) |
| P0-T0 환경 | ✅ | Flutter 3.47.7, Xcode 27.1, Android SDK 36(cmdline tools), JDK 17, CocoaPods 1.17 |
| P0-T1 프로젝트 생성 | ✅ | apps/flutter_app (macos/windows/android), check.sh 통과(테스트 5개), macOS·APK debug 빌드 성공 |
| P0-T2 CI | 🔄 | github.com/leejaegyung/eng-talk- (public). CI 4개 job 녹색, v0.1.0 릴리스(win/mac/apk) 생성. Windows PC 실행 확인 대기 |
| P0-T3 오디오 | 🔄 | 구현 완료: PCM16 스트림 녹음(record) → 메모리 → WAV → 재생(audioplayers, 전용 temp 폴더·재생 후 삭제·크래시 잔여물 정리), 순수 Dart 진폭 VAD(히스테리시스, user_speech 누적), 권한 거부 → 텍스트 모드 안내, 홈 → "오디오 테스트(개발용)" 화면. macOS 재생·S4 정리 integration_test 3개 통과. **남음: 사용자 macOS 마이크 녹음 확인, Windows/Galaxy는 다음 릴리스로 확인** |
| P0-T4 Vault | ✅ | `domain/credentials` 인터페이스 + `data/vault/SecureStorageVault`(byok. 네임스페이스, ref 검증으로 키가 키 이름에 들어가는 실수 차단). 단위 13개. macOS 실제 키체인에서 저장→재시작→조회→삭제→재시작→null 확인(integration_test 3회 실행). Windows/Android 실기 확인은 P1-A2 설정 화면에서 |
| P0-T5 Drift | ✅ | 6개 테이블 v1, FK·cascade, enum은 domain. CRUD/cascade/FK/키 컬럼 금지(S1) 테스트 + validateDatabaseSchema + 스냅샷 v1(make-migrations) |
| P0-T6 OpenAI 왕복 | ⬜ | 사용자 키 필요, 실행 전 확인 |
| P0-T7 상태 머신 | ✅ | `domain/conversation/` 순수 Dart. 시퀀스(seq)+턴 ID로 지연 응답 거부, barge-in 시 `interruptsAssistant`, 연결 끊김→paused(connectionLost)→재연결. 테스트 31개 |

## 알려진 이슈
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
