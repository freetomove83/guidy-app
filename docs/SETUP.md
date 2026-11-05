# Guidy Audio Guide 세팅 가이드

> 이 문서는 맥(macOS)에서 개발을 이어가기 위한 세팅 정보입니다.
> 비밀 키 값은 포함하지 않으며, 파일 위치와 설정 항목만 기록합니다.

---

## 1. 프로젝트 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 | Guidy Audio Guide |
| 저장소 | https://github.com/freetomove83/guidy-app |
| 브랜치 | `main` |
| Android 패키지 | `com.guidyaudioguide.tour` |
| iOS Bundle ID | 인계 문서: `com.guidyaudioguide.tour` / 현재 저장소: `com.guidyaudioguide.guidyAudioGuide` **(불일치, 결정 필요)** |

---

## 2. 맥에서 먼저 확인할 것

작업 시작 전에 로컬 상태를 확인합니다.

```bash
cd ~/Documents/GitHub/guidy-app
git fetch origin
git status
git log --oneline -5
git log origin/main..HEAD --oneline   # 원격에 push 안 된 로컬 커밋
git stash list
```

확인 포인트:
- `origin/main..HEAD` 결과가 있으면 로컬 커밋이 원격에 없는 상태입니다. push 여부를 먼저 정합니다.
- `lib/firebase_options.dart`, `ios/Runner/GoogleService-Info.plist` 존재 여부를 확인합니다.

```bash
ls lib/firebase_options.dart ios/Runner/GoogleService-Info.plist
```

---

## 3. Firebase 설정

### 3-1. 프로젝트 식별 정보

| 항목 | 값 |
|---|---|
| Project ID | `guidy-platform` |
| Project Number | `354832592482` |
| Storage Bucket | `guidy-platform.firebasestorage.app` |
| Android App ID | `1:354832592482:android:40ed50da887b61d638ab3b` |
| OAuth Web Client ID | `354832592482-ugtit23j1884f013o1jis0oj8mcffb30.apps.googleusercontent.com` |
| OAuth iOS Client ID | `354832592482-m3johvcqod8ja3r4mfm1b6isp7b190mg.apps.googleusercontent.com` |

### 3-2. 설정 파일 배치

| 파일 | 용도 | 배치 위치 | Git 커밋 |
|---|---|---|---|
| `google-services.json` | Android Firebase 설정 | `android/app/` | **금지** (비밀 정보 포함) |
| `GoogleService-Info.plist` | iOS Firebase 설정 | `ios/Runner/` | **금지** |
| `*-adminsdk-*.json` | 서버용 관리자 키 | 저장소 외부 보관 | **절대 금지** |
| `lib/firebase_options.dart` | FlutterFire 생성 설정 | `lib/` | 커밋 가능 (값에 비밀 없음) |

원본 파일은 윈도우 `C:\Users\freet\Downloads\Guidy`에 있습니다. 맥으로 옮길 때는 USB나 개인 클라우드 등 안전한 경로를 사용하세요.

### 3-3. iOS URL Scheme (Google 로그인)

`ios/Runner/Info.plist`에 `GoogleService-Info.plist`의 `REVERSED_CLIENT_ID` 값을 URL Scheme으로 등록해야 합니다.

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.354832592482-m3johvcqod8ja3r4mfm1b6isp7b190mg</string>
    </array>
  </dict>
</array>
```

현재 저장소의 `Info.plist`에는 이 항목이 없습니다.

---

## 4. 맥 개발 환경

| 항목 | 버전 |
|---|---|
| macOS | 13.7.8 Ventura (인텔 x86_64) |
| Xcode | 15.4 |
| Flutter | 3.24.5 |
| Dart | 3.5.4 |
| CocoaPods | 1.17.0 |
| Ruby | 3.1.4 (rbenv) |
| 시뮬레이터 | iPhone 15 Pro Max / iOS 17.5 |

### PATH 설정 (`~/.zshrc`)

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
```

### 자주 쓰는 명령

```bash
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
cd ~/Documents/GitHub/guidy-app
flutter pub get
cd ios && pod install && cd ..
flutter devices
flutter run
```

---

## 5. 코드 작성 규칙 (Flutter 3.24.5 호환)

최신 API를 쓰면 맥에서 빌드가 깨집니다. 아래 대체 API를 사용하세요.

| 사용 금지 | 대체 |
|---|---|
| `withValues(alpha: x)` | `withOpacity(x)` |
| `activeThumbColor` | `activeColor` |
| `CardThemeData` | `CardTheme` |

`audioplayers`는 Dart 3.5.4 호환을 위해 6.4.0을 사용합니다. 현재 `pubspec.yaml`은 6.5.0이므로 맥에서 확인이 필요합니다.

---

## 6. 맥에서 해야 할 남은 작업

- [ ] `git status` / `git log origin/main..HEAD` 결과 확인
- [ ] Firebase 설정 파일 배치 (`google-services.json`, `GoogleService-Info.plist`)
- [ ] `lib/firebase_options.dart` iOS 섹션 실제 값 반영
- [ ] `Info.plist`에 `REVERSED_CLIENT_ID` URL Scheme 추가
- [ ] Bundle ID 통일 결정 (`com.guidyaudioguide.tour` 권장 여부 확인)
- [ ] iOS에서 Google 로그인 테스트
- [ ] Apple 로그인 구현 (App Store 출시 필수)

---

## 7. 보안 주의

- 비밀 키 파일은 커밋하지 않습니다. `.gitignore`에 다음 패턴이 있는지 확인하세요.

```
google-services.json
GoogleService-Info.plist
*-adminsdk-*.json
```

- 실수로 커밋했다면 키를 즉시 폐기하고 재발급받으세요. 저장소에서 지우는 것만으로는 이력에서 사라지지 않습니다.
