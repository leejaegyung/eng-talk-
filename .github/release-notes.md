## 설치 방법 (개인용, ADR-006)

| 플랫폼 | 파일 | 설치 |
|---|---|---|
| Windows | `SpeakingCoach-*-windows-x64.zip` | 압축 해제 → `speaking_coach.exe` 실행. SmartScreen 경고 시 "추가 정보 → 실행" |
| macOS | `SpeakingCoach-*-macos.zip` | 압축 해제 → 앱을 응용 프로그램으로 이동 → 처음 한 번은 우클릭 → "열기" |
| Android | `SpeakingCoach-*-android.apk` | 폰에서 다운로드 → 설치 ("알 수 없는 앱 설치" 허용). 같은 서명 키라 다음 버전부터는 **덮어 설치**하면 기록이 유지돼요 |
| iPhone | `SpeakingCoach-*-ios-unsigned.ipa` | 서명 없음 → Sideloadly 등으로 본인 Apple ID 서명 후 설치(무료 계정은 7일마다 재설치). 개발자 모드 켜기 + VPN 및 기기 관리에서 신뢰 |

### Android: v0.6.0으로 처음 바꿀 때 한 번만
v0.5.0까지는 빌드마다 서명이 달라 덮어 설치가 안 돼요. 한 번만 이렇게 해 주세요.
1. 기존 앱 → 설정 → **대화 기록 내보내기**로 `speaking-coach.json` 저장
2. 기존 앱 삭제 → 새 APK 설치
3. 새 앱 → 설정 → **백업 파일에서 복원**으로 그 파일 선택

> ChatGPT 로그인과 API 키는 백업에 들어가지 않으니 다시 로그인해 주세요.
