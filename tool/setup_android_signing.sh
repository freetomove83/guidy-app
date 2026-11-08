#!/usr/bin/env bash
# Android 출시용(업로드) 서명 키 만들기 — 한 번만 실행
#   bash tool/setup_android_signing.sh
# 키스토어는 저장소 밖(~/Keys/guidy)에 만들고, android/key.properties(.gitignore 대상)에 위치와 비밀번호를 적는다.
# 비밀번호는 화면에 표시되지 않으며 key.properties 말고는 어디에도 저장·출력하지 않는다.
set -euo pipefail

KEY_DIR="$HOME/Keys/guidy"
STORE="$KEY_DIR/upload-keystore.jks"
ALIAS="upload"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PROPS="$REPO/android/key.properties"
# Flutter·Gradle과 같은 JDK(~/.zshrc의 JAVA_HOME)의 keytool — /usr/bin/keytool은 JDK가 없으면 동작 안 함
KEYTOOL="${JAVA_HOME:-$HOME/development/jdk/Contents/Home}/bin/keytool"
[ -x "${KEYTOOL:-}" ] || { echo "keytool을 찾지 못했습니다. 'flutter doctor -v'의 Java 경로를 알려주세요."; exit 1; }

if [ -e "$STORE" ] || [ -e "$PROPS" ]; then
  echo "이미 있습니다: $STORE 또는 $PROPS — 덮어쓰지 않고 멈춥니다."
  exit 1
fi

read -r -s -p "키 비밀번호 (6자 이상, 화면에 표시되지 않음): " PW; echo
read -r -s -p "비밀번호 확인: " PW2; echo
[ "$PW" = "$PW2" ] || { echo "두 비밀번호가 다릅니다."; exit 1; }
[ ${#PW} -ge 6 ] || { echo "6자 이상으로 해주세요."; exit 1; }

mkdir -p "$KEY_DIR" && chmod 700 "$KEY_DIR"
# 비밀번호는 환경변수로만 넘겨 명령줄·셸 기록에 남지 않게 함
export KS_PW="$PW"
"$KEYTOOL" -genkeypair -keystore "$STORE" -alias "$ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass:env KS_PW -keypass:env KS_PW \
  -dname "CN=Guidy, O=DoubleM, C=KR" >/dev/null 2>&1
chmod 600 "$STORE"

umask 077
cat > "$PROPS" <<EOF
storeFile=$STORE
storePassword=$PW
keyAlias=$ALIAS
keyPassword=$PW
EOF
unset PW PW2

echo
echo "완료: $STORE"
echo "      $PROPS (Git에 올라가지 않음)"
echo
echo "아래 지문(SHA1, SHA256)을 Claude에게 알려주세요 — 비밀값이 아닙니다."
"$KEYTOOL" -list -v -keystore "$STORE" -alias "$ALIAS" -storepass:env KS_PW | grep -E "SHA1:|SHA256:"
unset KS_PW
echo
echo "⚠ 이 키스토어 파일과 비밀번호를 잃어버리면 Play 스토어 앱을 업데이트하기 어렵습니다."
echo "  비밀번호는 비밀번호 관리자에, 파일($STORE)은 안전한 곳에 백업해 두세요."
