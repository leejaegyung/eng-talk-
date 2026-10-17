# Phase 0 — 기술검증 (PoC)

목표: 플랫폼·오디오·보안 저장소·공급자 연동 위험을 기능 개발 전에 제거한다.
각 태스크는 **완료 기준**과 **증거**를 PROGRESS.md에 남겨야 완료다.

---

### P0-T0 개발 환경 구성
- 대상: macOS·Windows 개발, Android는 배포 후 확인 (ADR-009)
- 완료 기준: `flutter doctor`에서 Flutter/Android toolchain/Xcode ✓, macOS·APK 로컬 빌드 성공
- 증거: `flutter doctor -v` 요약

### P0-T1 Flutter 프로젝트 생성
- `apps/flutter_app`에 `flutter create --platforms=macos,windows,android --org dev.leejk` (iOS는 MVP 후 `flutter create --platforms=ios .`)
- docs/architecture.md의 lib 폴더 구조 생성, 의존성 추가: flutter_riverpod, go_router, drift, flutter_secure_storage, http, record, 재생 패키지, flutter_localizations/intl
- `analysis_options.yaml`: flutter_lints + strict-casts/strict-inference/strict-raw-types
- 완료 기준: macOS에서 빈 앱 실행, `scripts/check.sh` 통과

### P0-T2 CI
- GitHub Actions(`.github/workflows/ci.yml`): check.sh + build 매트릭스(macos, windows, apk) + 아티팩트 업로드
- 완료 기준: 3개 빌드 job 녹색, Windows 아티팩트를 사용자 PC에서 실행 확인 (원격 저장소 연결은 사용자 확인 후)

### P0-T3 오디오 입출력 PoC
- 마이크 권한(iOS Info.plist, macOS entitlements, Android RECORD_AUDIO), 녹음 → 메모리 버퍼 → 재생
- 진폭 스트림으로 간단한 VAD: 발화 시작/종료 이벤트 + `user_speech_ms` 누적
- 완료 기준: macOS 녹음·재생 성공, Windows는 CI 빌드 아티팩트로 사용자 PC 확인, Android는 APK 설치 확인, 권한 거부 시 텍스트 모드 안내
- 증거: 플랫폼별 결과 표, 헤드셋 전환 결과

### P0-T4 CredentialVault PoC
- `domain/CredentialVault` 인터페이스 + `data/vault` secure storage 구현
- 완료 기준: 저장 → 앱 재시작 → 조회 성공, 삭제 후 조회 null (S1, S5). 단위 테스트(fake) + 플랫폼 수동 확인

### P0-T5 Drift 스키마 v1
- spec §9.1 테이블 중 profiles, providers, sessions, turns, speech_metrics, corrections
- 완료 기준: 마이그레이션 테스트, in-memory DB로 CRUD 테스트, providers에 키 컬럼 없음(arch_lint)

### P0-T6 OpenAI BYOK 왕복
- `LlmProvider`/`VoiceProvider` 인터페이스 + mock + OpenAI 구현 (STT, 스트리밍 chat, TTS)
- 모델 목록 API로 선택, 오류를 ProviderFailure로 정규화
- 완료 기준: 실제 키로 "녹음 → STT → LLM → TTS → 재생" 1회 성공, 잘못된 키 → invalidKey 표시
- 증거: 왕복 지연 10회 측정 p50/p95 (구간별: STT / LLM 첫 토큰 / TTS 첫 바이트)
- ⚠ 사용자 키·과금 발생 → 실행 전 사용자 확인

### P0-T7 세션 상태 머신
- `ConversationSessionController` 순수 Dart 구현, 시퀀스 ID, 잘못된 전이 거부
- 완료 기준: 모든 전이와 거부 케이스 단위 테스트

**Phase 0 종료 기준:** macOS에서 음성 대화 1회 성공 + Windows 빌드 실행 확인 + T4·T5·T7 테스트 통과 + 지연 측정치 기록.
