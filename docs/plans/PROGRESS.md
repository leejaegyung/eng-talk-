# 진행 보드

> 세션 시작 시 자동 주입된다. 태스크를 끝낼 때마다 갱신한다. 짧게 유지하고 오래된 상세는 "기록"으로 옮긴다.

**현재 Phase:** 0 (PoC)
**대상 플랫폼:** macOS·Windows 데스크톱 (Mac에서 개발), Galaxy는 APK 배포 후 확인 (ADR-009)
**다음 태스크:** P0-T4 CredentialVault
**Phase 0 순서:** T7 → T4 → T5 → T3 → T6(키·과금, 실행 전 확인). T2는 사용자 Windows 실행 확인 대기

## 상태
| 태스크 | 상태 | 증거 / 메모 |
|---|---|---|
| 하네스 구성 | ✅ | 훅 4종 동작 확인(포맷 훅 실제 적용됨), arch_lint 위반 샘플 5종 검출 |
| 기획 문서 | ✅ | roadmap, phase-0, phase-1, decisions(ADR-001~009) |
| P0-T0 환경 | ✅ | Flutter 3.47.7, Xcode 27.1, Android SDK 36(cmdline tools), JDK 17, CocoaPods 1.17 |
| P0-T1 프로젝트 생성 | ✅ | apps/flutter_app (macos/windows/android), check.sh 통과(테스트 5개), macOS·APK debug 빌드 성공 |
| P0-T2 CI | 🔄 | github.com/leejaegyung/eng-talk- (public). CI 4개 job 녹색, v0.1.0 릴리스(win/mac/apk) 생성. Windows PC 실행 확인 대기 |
| P0-T3 오디오 | ⬜ | record + audioplayers |
| P0-T4 Vault | ⬜ | |
| P0-T5 Drift | ⬜ | |
| P0-T6 OpenAI 왕복 | ⬜ | 사용자 키 필요, 실행 전 확인 |
| P0-T7 상태 머신 | ✅ | `domain/conversation/` 순수 Dart. 시퀀스(seq)+턴 ID로 지연 응답 거부, barge-in 시 `interruptsAssistant`, 연결 끊김→paused(connectionLost)→재연결. 테스트 31개 |

## 알려진 이슈
- `flutter analyze`가 한글·공백 경로에서 크래시(LSP 버그) → check.sh는 `dart analyze --fatal-infos` 사용
- Windows 빌드는 Mac에서 불가 → CI 아티팩트로만 확인

## 미해결 질문
- ADR-006 배포 방식 (Phase 3 전까지)

## 기록
- 2026-10-17 GitHub 연결, 릴리스 워크플로(ADR-010)
- 2026-10-17 스킬 16종 설치, 하네스·기획 문서 작성, 개발 환경 구성, 프로젝트 생성
