# Guidy Audio Guide 세팅 가이드

> 이 문서는 맥(macOS)에서 개발을 이어가기 위한 세팅 정보입니다.
> 비밀 키 값은 포함하지 않으며, 파일 위치와 설정 항목만 기록합니다.

---

## 1. 프로젝트 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 | Guidy Audio Guide |
| 저장소 | https://github.com/freetomove83/guidy-app |
| 브랜치 | `main` (작업 브랜치는 PR로 병합) |
| Android 패키지 | `com.guidyaudioguide.tour` |
| iOS Bundle ID | `com.guidyaudioguide.tour` (2026-11-05 Android·Firebase와 통일. 이전 값 `com.guidyaudioguide.guidyAudioGuide`) |

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
- Firebase 설정 파일 2개가 제자리에 있는지 확인합니다 (Git에 없으므로 기기마다 직접 배치).

```bash
ls ios/Runner/GoogleService-Info.plist android/app/google-services.json
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
| OAuth iOS Client ID | `354832592482-klquq36s4mg64epd6bmo087t9vpdb6go.apps.googleusercontent.com` (plist의 `CLIENT_ID`) |
| OAuth Android Client ID | `354832592482-m3johvcqod8ja3r4mfm1b6isp7b190mg.apps.googleusercontent.com` (plist의 `ANDROID_CLIENT_ID`) |

### 3-2. 설정 파일 배치

| 파일 | 용도 | 배치 위치 | Git 커밋 |
|---|---|---|---|
| `google-services.json` | Android Firebase 설정 | `android/app/` | **금지** (비밀 정보 포함) |
| `GoogleService-Info.plist` | iOS Firebase 설정 | `ios/Runner/` | **금지** |
| `*-adminsdk-*.json` | 서버용 관리자 키 | 저장소 외부 보관 | **절대 금지** |
| ~~`lib/firebase_options.dart`~~ | 사용 안 함 | — | 앱은 위 네이티브 파일로 초기화 (`Firebase.initializeApp()` 옵션 없이 호출, `lib/main.dart`의 `_initFirebase`). 웹에서 Firebase를 쓸 때만 필요 |

원본 파일은 윈도우 `C:\Users\freet\Downloads\Guidy`에 있습니다. 맥으로 옮길 때는 USB나 개인 클라우드 등 안전한 경로를 사용하세요.

### 3-3. iOS URL Scheme (Google 로그인)

`ios/Runner/Info.plist`의 `CFBundleURLTypes`에 `GoogleService-Info.plist`의 **`REVERSED_CLIENT_ID`** 값이 등록되어 있습니다 (2026-11-05 추가).

> 주의: 이전 버전 문서의 예시 값(`...m3johvcqod8...`)은 **Android** Client ID였습니다. iOS URL Scheme에는 반드시 plist의 `REVERSED_CLIENT_ID`를 그대로 사용하세요.

---

## 4. 맥 개발 환경

현재 개발 맥 (MacBook Air M3, 2026-11-05 기준):

| 항목 | 버전 |
|---|---|
| macOS | 27.0.1 (Apple Silicon arm64) |
| Xcode | 27.2 |
| Flutter | 3.47.7 (stable, `~/development/flutter`) |
| Dart | 3.13.5 |
| iOS 의존성 | Swift Package Manager (CocoaPods 불필요, `ios/Podfile` 없음) |
| 시뮬레이터 | iPhone 18 Pro |

> 예전 인텔 맥(macOS 13.7.8, Xcode 15.4, Flutter 3.24.5)은 더 이상 기준 환경이 아닙니다. 그 맥에서 빌드하려면 Flutter를 3.27 이상으로 올려야 합니다 (아래 5번 참고).

### PATH 설정 (`~/.zshrc`)

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

### 자주 쓰는 명령

```bash
cd ~/Documents/GitHub/guidy-app
flutter pub get
open ios/Runner.xcworkspace        # Xcode는 반드시 이 경로로 열기 (~/GensparkCode 사본 아님)
flutter devices
flutter run
flutter test                        # 골든 테스트 포함
```

---

## 5. 코드 작성 규칙

기준 Flutter 버전은 **3.47.7**입니다. 코드는 이미 `withValues(alpha: x)`, `activeThumbColor`, `CardThemeData` 등 Flutter 3.27+ API를 사용하므로, 3.24.5 이하에서는 빌드되지 않습니다. 구버전 API(`withOpacity` 등)로 되돌리지 말고 빌드 환경의 Flutter를 올리세요.

`audioplayers`는 `pubspec.yaml`에서 `^6.4.0`입니다.

UI를 바꾼 뒤에는 `flutter test`로 골든 테스트를 확인하고, 의도한 변경이면 `flutter test --update-goldens test/goldens`로 기준 이미지를 갱신합니다.

---

## 6. 맥에서 해야 할 남은 작업

- [x] `git status` / `git log origin/main..HEAD` 결과 확인
- [x] `GoogleService-Info.plist` 배치 (`ios/Runner/`, Xcode Runner 타깃 포함)
- [x] `google-services.json` 배치 (`android/app/`) + Android Gradle `google-services` 플러그인 4.4.4 추가 (빌드 리소스 생성 확인)
- [ ] Android 기기/에뮬레이터에서 Firebase 초기화 로그 확인 (맥에 Android 에뮬레이터 없음)
- [x] Firebase 초기화 코드 (`firebase_core`, iOS에서 `guidy-platform` 연결 확인)
- [x] `Info.plist`에 `REVERSED_CLIENT_ID` URL Scheme 추가
- [x] Bundle ID 통일: `com.guidyaudioguide.tour` (App Store 배포 프로파일은 새 ID로 재생성 필요)
- [ ] iOS에서 Google 로그인 테스트
- [ ] Apple 로그인 구현 (App Store 출시 필수)
- [ ] CMS 연동 콘솔 작업 (아래 6-1)

### 6-1. CMS(guidy-cms) 연동

앱은 시작할 때 Firestore `exhibitions`(status가 `published`인 것)·`artworks`·`sections`를 읽고, 게시된 전시가 없거나 오프라인이면 앱 기본 데이터를 씁니다 (`lib/services/content_service.dart`). 크리에이터·크리에이터 가이드는 아직 앱 기본 데이터입니다.

콘솔 작업 (한 번만):
1. **보안 규칙 게시**: Firebase 콘솔 → Firestore → 규칙에 `guidy-cms/related/firebase_rules/firestore.rules` 내용을 붙여넣고 게시 (Storage도 같은 폴더의 `storage.rules`)
2. **로그인 방식 켜기**: Authentication → 로그인 방법 → 이메일/비밀번호 사용 설정
3. **관리자 계정**: Authentication → 사용자 추가 → 생성된 UID 복사 → Firestore에 `users/{UID}` 문서를 만들고 `role` 필드(문자열) = `admin`
4. **콘텐츠 올리기**: 아래 명령. 처음엔 `--apply` 없이 실행해 계획(덮어쓸 문서, 예전 시드가 남긴 문서)을 확인

```bash
flutter test tool/export_content_test.dart
python3 tool/upload_content.py --email 관리자이메일
```

로컬 검증 (실제 Firebase에 영향 없음): guidy-cms에서 `firebase emulators:start --only auth,firestore,storage --project guidy-platform` → `python3 related/scripts/check_rules.py` (규칙 17개 확인) → 앱·CMS를 `--dart-define=USE_EMULATOR=true`로 실행.

---

## 7. 보안 주의

- 비밀 키 파일은 커밋하지 않습니다. `.gitignore`에 다음 패턴이 있는지 확인하세요.

```
google-services.json
GoogleService-Info.plist
*-adminsdk-*.json
```

- 실수로 커밋했다면 키를 즉시 폐기하고 재발급받으세요. 저장소에서 지우는 것만으로는 이력에서 사라지지 않습니다.
