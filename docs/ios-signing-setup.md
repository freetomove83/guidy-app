# iOS 실기기 서명 셋업 절차

이 문서는 guidy 앱을 **실제 iPhone에서 실행**하고, 이후 **TestFlight / App Store 배포**까지 갈 수 있도록
서명(code signing)을 준비하는 절차를 정리한 것입니다.

작성 시점 기준: Flutter 3.47.7 / Xcode 27.1 / macOS 27.0.1 (Apple Silicon)

---

## 0. 현재 상태 (2026-10-18 갱신 — 서명 셋업 완료)

서명 셋업 자체는 **완료됐습니다.** 아래는 실제로 확인한 값입니다.

| 항목 | 값 |
|---|---|
| Apple ID | 등록됨 (Xcode Settings → Accounts) |
| 팀 | `2AB9P63KNV` — Junseok Kang (Individual, **유료**) |
| 서명 인증서 | `Apple Development: Junseok Kang (S43TF2PC26)` |
| `DEVELOPMENT_TEAM` | `2AB9P63KNV` — Runner + RunnerTests, 각 3개 config, **총 6곳** |
| `CODE_SIGN_STYLE` | `Automatic` (6곳) |
| 프로비저닝 프로파일 | `iOS Team Provisioning Profile: *`, 만료 **2027-10-18** |
| Bundle ID | `com.guidyaudioguide.guidyAudioGuide` |
| 테스트 Bundle ID | `com.guidyaudioguide.guidyAudioGuide.RunnerTests` |
| iOS Deployment Target | `15.0` |
| 서명된 실기기 빌드 | `flutter build ios` → `Runner.app` **37.2MB 성공** |

프로파일 만료가 **1년 뒤**라는 점이 유료 계정의 증거입니다 (무료 Personal Team이면 7일).

### 검증 명령

```bash
security find-identity -v -p codesigning                       # 1 valid identities
codesign -dv --verbose=2 build/ios/iphoneos/Runner.app          # Authority / TeamIdentifier
security cms -D -i build/ios/iphoneos/Runner.app/embedded.mobileprovision
```

### 남은 것: 실기기 설치

실기기용 서명 빌드는 성공하지만, **실제 iPhone에 설치하려면 기기를 연결**해야 합니다 (§2 Step 4 ~ Step 7).


---

## 1. 무료 Apple ID vs 유료 개발자 프로그램

> **이 프로젝트는 이미 유료(Individual) 계정입니다** — Team `2AB9P63KNV`, 프로파일 만료 2027-10-18.
> 따라서 푸시 알림 · Sign in with Apple · TestFlight · App Store가 모두 가능하고, 7일 만료 제약도 없습니다.
> 아래는 배경 설명이니 건너뛰셔도 됩니다.

Xcode에 Apple ID를 등록하면 두 종류의 팀이 생깁니다.

### 무료 (Personal Team)

내 기기에서 테스트만 하는 용도.

- $0
- 프로비저닝 프로파일 **7일 만료** → 7일마다 다시 빌드·설치
- **App ID 10개**까지, **기기 3대**까지 (각각 7일마다 만료)
- **TestFlight 불가** (App Store Connect 업로드가 유료 전용)
- **App Store 배포 불가**
- **다음 기능 사용 불가**: 푸시 알림, Sign in with Apple, iCloud, App Groups, Apple Pay, Data Protection
  → 이건 이 앱에 치명적입니다. 알림 기능과 (심사를 위해 필요한) Apple 로그인을 붙일 수 없습니다.

### 유료 (Apple Developer Program)

- 연 $99 (개인) / $299 (기관, 2026년 기준 — 가입 화면에서 최종 확인)
- 프로파일 1년, 기기 100대 (제품군별, 연 1회 리셋)
- TestFlight, App Store, 그리고 위의 모든 capability 사용 가능

### 이 프로젝트의 결론

유료 계정이므로 **무료 계정의 제약을 고민할 필요가 없습니다.** 7일 만료도, 기능 제한도, TestFlight 제한도 없습니다.

---

## 1-1. 반드시 먼저 확인할 것: Program License Agreement (PLA)

**여기서 한 번 막혔습니다.** 팀 설정을 다 끝내고 빌드했는데도 인증서·프로파일이 발급되지 않았고,
원인은 Xcode가 아니라 **애플 개발자 계정의 최신 약관 미동의**였습니다.

증상 — `flutter build ios` 실행 시:

```
Error (Xcode): Unable to process request - PLA Update available:
You currently don't have access to this membership resource.
To resolve this issue, agree to the latest Program License Agreement in your developer account.

Error (Xcode): No profiles for 'com.guidyaudioguide.guidyAudioGuide' were found
```

`No profiles ... were found` 만 보면 팀 설정이나 Bundle ID 문제로 오해하기 쉬운데, **PLA가 원인**입니다.

**해결** — Xcode가 아니라 **웹**에서 합니다:

1. https://developer.apple.com/account 접속 후 로그인
2. 상단의 **`Review Agreement`** 배너 클릭 (또는 `Agreements` 항목)
3. 약관 맨 아래까지 스크롤 → **체크박스** ☑ → **`Submit`**
4. 다시 `flutter build ios`

동의하면 애플 서버가 인증서와 프로파일을 자동 발급합니다. 별도로 인증서를 만들 필요가 없습니다.

> `Agreements, Tax, and Banking`은 **앱 판매/세금** 관련이라 지금 필요한 것이 아닙니다.
> 찾으시는 건 **Program License Agreement**(개발자 프로그램 약관)입니다.

---

## 2. 절차

### Step 1. Xcode에 Apple ID 등록

1. Xcode 실행 → 메뉴 **Xcode → Settings...** (`Cmd + ,`)
2. **Accounts** 탭 → 왼쪽 아래 **`+`** → **Apple ID** 선택
3. Apple ID와 비밀번호 입력 (2단계 인증 코드 필요)
4. 등록되면 목록에 `Apple ID / Personal Team`이 표시됨

**확인:**

```bash
defaults read com.apple.dt.Xcode DVTDeveloperAccountManagerAppleIDLists
# Personal Team이 등록되면 IDE.Identifiers.Prod 배열에 항목이 생깁니다
```

> **참고**: "Personal Team"은 유료 프로그램에 가입하지 않은 개인 Apple ID에 자동으로 부여되는 팀입니다.
> 기존에 유료 가입한 계정이라면 팀 이름이 `성명 (Individual)` 형태로 보입니다.

### Step 2. Team ID 확인

Team ID(10자리, 예: `A1B2C3D4E5`)를 확인합니다.

- **Xcode → Settings → Accounts** → 팀 이름을 더블클릭 → 우측에 `Team ID` 표시
- 또는 https://developer.apple.com/account → **Membership details** (유료 계정)

무료 계정은 웹에서 관리 화면이 없으니 **Xcode에서만** 확인 가능합니다.

### Step 3. 프로젝트에 팀 지정

**방법 A — Xcode GUI (권장)**

1. 터미널에서 워크스페이스를 엽니다:

   ```bash
   cd /Users/kian/GensparkCode/guidy-app
   open ios/Runner.xcworkspace
   ```

   > `Runner.xcodeproj`가 아니라 **`.xcworkspace`**를 열어야 합니다.

2. 좌측 네비게이터에서 **Runner** 프로젝트 선택 → **TARGETS → Runner** 선택
3. **Signing & Capabilities** 탭:
   - **Automatically manage signing** 체크
   - **Team** 드롭다운에서 Step 1에서 등록한 팀 선택
   - Team 선택 즉시 "Signing Certificate: Apple Development: ..." 가 자동 생성됩니다
4. **TARGETS → RunnerTests**도 같은 팀으로 설정
   (RunnerTests는 테스트용 별도 App ID를 쓰므로 팀을 안 넣으면 아카이브 단계에서 실패합니다)

**방법 B — project.pbxproj 직접 편집 (CLI)**

GUI를 쓸 수 없는 환경에서만. `DEVELOPMENT_TEAM`이 Runner와 RunnerTests 두 타겟의
**각 3개 configuration(Debug/Release/Profile)** 에 들어가야 하므로 총 6곳입니다.

```bash
cd /Users/kian/GensparkCode/guidy-app
git stash list                          # 문제 생기면 되돌릴 수 있게
cp ios/Runner.xcodeproj/project.pbxproj /tmp/pbxproj.bak
```

이후 각 `CODE_SIGN_STYLE = Automatic;` 줄 **뒤에** `DEVELOPMENT_TEAM = 여기에팀ID;` 를 삽입합니다.
6곳 모두 들어갔는지 반드시 확인하세요:

```bash
grep -c "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj   # 6 이어야 함
```

> 실패하면 `/tmp/pbxproj.bak`을 되돌리면 됩니다. GUI가 훨씬 안전합니다.

### Step 4. iPhone 연결 + 신뢰 + 개발자 모드

1. **USB 케이블로 iPhone 연결** (무료 계정은 Wi-Fi 디버깅 불가)
2. iPhone 화면에 **"이 컴퓨터를 신뢰하시겠습니까?"** → **신뢰** → 기기 암호 입력
   (안 뜨면 케이블을 뽑았다 다시 꽂거나, iPhone에서 잠금 해제 후 재시도)
3. **개발자 모드 켜기** (iOS 16 이상 필수)
   - iPhone → **설정 → 개인정보 보호 및 보안 → 개발자 모드** → 켜기 → **재부팅** → 재부팅 후 다시 켜기
   - 이 메뉴는 **Xcode에 한 번 연결한 뒤에야 나타납니다.** 안 보이면 Step 5에서 Xcode를 한 번 열고 돌아오세요.
4. 연결 확인:

   ```bash
   xcrun devicectl list devices
   # 또는
   flutter devices
   ```

   기기가 `(mobile)`로 보이면 성공.

### Step 5. 기기 등록

Team을 지정한 상태에서 빌드하면 Xcode가 자동으로 기기를 개발자 포털에 등록합니다.
GUI로 명시적으로 하려면: **Xcode → Window → Devices and Simulators** → 기기 선택 → **Use for Development**.

> 이 계정은 유료이므로 **기기 100대**까지 가능합니다 (연 1회 리셋). 무료 계정의 3대 / 7일 제약은 해당 없음.

### Step 6. 빌드 & 설치

```bash
cd /Users/kian/GensparkCode/guidy-app

# 서명 포함 빌드가 되는지 확인
flutter build ios

# 실기기에서 바로 실행
flutter run -d <device-id>

# 이미 빌드된 앱만 설치
flutter install -d <device-id>
```

`flutter devices` 로 device-id를 확인하세요.

> **주의**: 서명 관련 에러가 나면 Xcode에서 한 번 열어 Fix Issue를 누르는 게 가장 빠릅니다.
> CLI만으로 자동 서명을 복구하기는 어렵습니다.

### Step 7. 기기에서 개발자 신뢰

첫 설치 후 앱을 누르면 "신뢰할 수 없는 개발자"라며 실행이 막힙니다.

iPhone → **설정 → 일반 → VPN 및 기기 관리 → 개발자 앱** → 본인 Apple ID 선택 → **"개발자 신뢰"** → 확인

이후 앱이 정상 실행됩니다.

---

## 3. 검증

```bash
# 1. 인증서가 생겼는지 (0 valid → 1 valid)
security find-identity -v -p codesigning

# 2. 서명된 실기기용 빌드 성공 여부
flutter build ios

# 3. 팀이 6곳에 들어갔는지
grep -c "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj

# 4. 기기에 설치됐는지
xcrun devicectl list devices
```

---

## 4. 프로파일 만료 (해당 없음)

무료 Personal Team이었다면 7일마다 프로파일이 만료되어 앱 실행이 막히고 재빌드가 필요합니다.

**이 계정은 유료이므로 해당 없음** — 현재 프로파일 만료일은 **2027-10-18**(1년)입니다.
만료가 다가오면 다음으로 확인하세요:

```bash
security cms -D -i build/ios/iphoneos/Runner.app/embedded.mobileprovision | plutil -extract ExpirationDate raw -
```

---

## 5. TestFlight / App Store

이미 유료 계정이므로 이 단계로 바로 갈 수 있습니다.

### 5-1. Bundle ID 등록

https://developer.apple.com/account → **Identifiers** → `+` → **App IDs** → **App**

- Bundle ID: `com.guidyaudioguide.guidyAudioGuide` (정확히 일치해야 함)
- 다른 계정이 이미 선점했다면 **바꿔야 합니다** (예: `kr.co.guidy.guidyAudioGuide`)
  바꾸는 경우 `ios/Runner.xcodeproj/project.pbxproj`의 `PRODUCT_BUNDLE_IDENTIFIER`도 함께 수정

### 5-2. App Store Connect에 앱 레코드 생성

https://appstoreconnect.apple.com → **My Apps** → `+` → **New App**

- Platform: iOS
- Bundle ID: 위에서 등록한 것 선택
- SKU: 임의 문자열 (예: `guidy-ios-001`)

### 5-3. Xcode 설정 점검

**Xcode → Runner target → General**

- **Display Name**: 홈 화면에 보일 이름 (예: `Guidy`)
- **Bundle Identifier**: 위에서 등록한 값과 일치

**Build Settings → Deployment → iOS Deployment Target**: 현재 `15.0`

### 5-4. 버전 / 빌드 번호

`pubspec.yaml`:

```yaml
version: 1.0.0+1        # 1.0.0 = 버전, +1 = 빌드 번호
```

업로드할 때마다 **빌드 번호를 반드시 올려야** 합니다 (같은 번호 재업로드 불가).
일회성으로 덮어쓰려면:

```bash
flutter build ipa --build-name=1.0.1 --build-number=2
```

### 5-5. 아카이브 생성 & 업로드

```bash
cd /Users/kian/GensparkCode/guidy-app
flutter build ipa
```

결과물:
- `build/ios/archive/Runner.xcarchive`
- `build/ios/ipa/*.ipa`

업로드 방법 (택 1):

1. **Transporter 앱** (권장, 가장 간단)
   - App Store에서 **Transporter** 설치
   - `build/ios/ipa/*.ipa` 를 드래그 앤 드롭 → **Deliver**
2. **Xcode Organizer**
   - `open build/ios/archive/Runner.xcarchive`
   - **Validate App** → 성공하면 **Distribute App** → App Store Connect
3. **CLI (App Store Connect API 키 필요)**
   ```bash
   xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa \
     --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
   ```

### 5-6. TestFlight

업로드 후 App Store Connect → **TestFlight** 탭에서 처리 상태가 `Processing` → `Ready to Test` 로 바뀌면 배포 가능.
내부 테스터(최대 100명, 심사 불필요)와 외부 테스터(심사 필요)로 나뉩니다.

### 5-7. 심사 제출

App Store Connect에서 스크린샷, 설명, 개인정보 처리방침 URL, 연령 등급 등을 채우고 **Submit for Review**.

> **이 앱의 심사 리스크**: 앱이 현재 전부 `DummyData` 기반(§6)이라
> "기능이 동작하지 않는다"는 사유로 **거절(4.2 Minimum Functionality)** 될 가능성이 높습니다.
> 실제 백엔드 연동 없이 스토어에 올리는 것은 권장하지 않습니다.

---

## 6. 출시 전 체크리스트 (이 프로젝트의 미비점)

| 항목 | 현재 | 비고 |
|---|---|---|
| 앱 아이콘 | **Flutter 기본 아이콘** | `assets/icon/app_icon.png`(512×512)가 있으나 iOS/Android에 미적용. App Store는 **1024×1024** 필요 → 512짜리는 업스케일이라 화질 저하. 1024 원본 확보 권장 |
| 런치 이미지 | Flutter 기본 | `ios/Runner/Assets.xcassets/LaunchImage.imageset` |
| 권한 설명 문구 | 없음 | QR/BLE 붙일 때 `Info.plist`에 `NSCameraUsageDescription`, `NSBluetoothAlwaysUsageDescription` 추가 필요. 없으면 **앱이 즉시 크래시** |
| 실제 기능 | 전부 `DummyData` | QR 스캔은 `lib/screens/scan/scan_screen.dart`에 "웹 미리보기용 시뮬레이션" 명시 |
| 개인정보 처리방침 | 없음 | App Store 제출 시 URL 필수 |
| `CODE_SIGN_IDENTITY` | `"iPhone Developer"` (구식) | 최신 Xcode 표기는 `"Apple Development"`. 자동 서명이 처리하지만 정리 권장 |

---

## 7. 자주 나는 에러

| 에러 | 원인 / 해결 |
|---|---|
| `PLA Update available` + `No profiles for '...' were found` | **실제로 막혔던 원인.** 팀 설정이 아니라 애플 개발자 계정의 최신 약관 미동의. §1-1 참고 — 웹에서 PLA 동의 |
| `No development certificates available to code sign app for device deployment` | Step 3의 Team 미설정. Xcode에서 Team을 고르세요 |
| `Your development team does not support the Push Notifications capability` | 무료 Personal Team의 한계 (이 계정은 유료라 해당 없음) |
| `The app identifier "..." cannot be registered to your development team` | Bundle ID가 이미 다른 계정에 등록됨. Bundle ID 변경 |
| 앱 실행 시 "신뢰할 수 없는 개발자" | Step 7 (설정 → 일반 → VPN 및 기기 관리 → 개발자 신뢰) |
| `Failed to register bundle identifier` (테스트 타겟) | RunnerTests 타겟에도 Team을 지정했는지 확인 |
| Xcode에 기기가 안 보임 | 케이블 재연결 / iPhone 잠금 해제 / 기기에서 "신뢰" 누르기 |
| 개발자 모드 메뉴가 안 보임 | Xcode에 한 번 연결해야 메뉴가 생성됨 (Step 4) |

---

## 관련 문서

- Flutter 공식: https://docs.flutter.dev/deployment/ios
- Apple 개발자 계정 개요: https://developer.apple.com/help/account/basics/about-your-developer-account/
- App capability 활성화: https://developer.apple.com/help/account/identifiers/enable-app-capabilities/
