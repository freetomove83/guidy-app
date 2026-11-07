#!/usr/bin/env python3
"""앱 기본 콘텐츠(build/seed/content.json)를 Firestore에 올림 — 전시·작품·섹션

먼저: flutter test tool/export_content_test.dart

  # 로컬 에뮬레이터 (guidy-cms에서 firebase emulators:start)
  python3 tool/upload_content.py --emulator --apply

  # 실제 Firebase — 관리자 계정으로 로그인 (비밀번호는 실행 중에 입력, 저장하지 않음)
  python3 tool/upload_content.py --email 관리자이메일            # 계획만 출력
  python3 tool/upload_content.py --email 관리자이메일 --apply    # 실제로 올림
  python3 tool/upload_content.py --email 관리자이메일 --apply --delete-stale
      # content.json에 없는 기존 문서(예: 예전 시드의 a3~a5)를 지움 — 확인 문구를 입력해야 실행

같은 ID의 문서는 통째로 덮어씀. 기본값은 계획만 출력하고 아무것도 바꾸지 않음.
"""
import argparse, datetime, getpass, json, re, sys, urllib.error, urllib.parse, urllib.request
from pathlib import Path

PROJECT = "guidy-platform"
COLLECTIONS = ["exhibitions", "artworks", "sections"]
TS_FIELDS = {"archived_at", "created_at"}
ROOT = Path(__file__).resolve().parent.parent


def encode(value, key=None):
    if value is None:
        return {"nullValue": None}
    if key in TS_FIELDS and isinstance(value, str):
        return {"timestampValue": value}
    if isinstance(value, bool):
        return {"booleanValue": value}
    if isinstance(value, int):
        return {"integerValue": str(value)}
    if isinstance(value, float):
        return {"doubleValue": value}
    if isinstance(value, str):
        return {"stringValue": value}
    if isinstance(value, list):
        return {"arrayValue": {"values": [encode(v) for v in value]}}
    if isinstance(value, dict):
        return {"mapValue": {"fields": {k: encode(v, k) for k, v in value.items()}}}
    raise TypeError(f"unsupported value: {value!r}")


class Firestore:
    def __init__(self, base, token):
        self.base, self.token = base, token

    def call(self, method, path, body=None):
        req = urllib.request.Request(
            f"{self.base}/{path}", method=method,
            data=json.dumps(body).encode() if body is not None else None,
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {self.token}"})
        try:
            with urllib.request.urlopen(req) as r:
                return json.loads(r.read() or b"{}")
        except urllib.error.HTTPError as e:
            detail = json.loads(e.read() or b"{}").get("error", {})
            sys.exit(f"{method} {path} 실패: {e.code} {detail.get('status')} {detail.get('message', '')}")

    def ids(self, collection):
        found, page = [], ""
        while True:
            d = self.call("GET", f"{collection}?pageSize=300&mask.fieldPaths=__name__{page}")
            found += [doc["name"].rsplit("/", 1)[1] for doc in d.get("documents", [])]
            if "nextPageToken" not in d:
                return found
            page = "&pageToken=" + urllib.parse.quote(d["nextPageToken"])


def sign_in(email, api_key):
    password = getpass.getpass(f"{email} 비밀번호: ")
    req = urllib.request.Request(
        f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}",
        data=json.dumps({"email": email, "password": password, "returnSecureToken": True}).encode(),
        # web API 키는 허용 주소(referrer)로 제한돼 있어 localhost로 보냄
        headers={"Content-Type": "application/json", "Referer": "http://localhost/"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())["idToken"]
    except urllib.error.HTTPError as e:
        sys.exit(f"로그인 실패: {json.loads(e.read() or b'{}').get('error', {}).get('message')}")


def web_api_key(path):
    # guidy-cms의 firebase_options.dart에서 web apiKey를 읽음 (키를 이 저장소에 복사하지 않기 위해)
    m = re.search(r"static const FirebaseOptions web = FirebaseOptions\((.*?)\);", Path(path).read_text(), re.S)
    key = m and re.search(r"apiKey: '([^']+)'", m.group(1))
    if not key:
        sys.exit(f"{path}에서 web apiKey를 찾지 못했습니다")
    return key.group(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    target = p.add_mutually_exclusive_group(required=True)
    target.add_argument("--emulator", action="store_true", help="localhost:8080 에뮬레이터")
    target.add_argument("--email", help="관리자 계정 이메일 (실제 Firebase)")
    p.add_argument("--options", default=str(ROOT.parent / "guidy-cms/lib/firebase_options.dart"))
    p.add_argument("--content", default=str(ROOT / "build/seed/content.json"))
    p.add_argument("--apply", action="store_true", help="실제로 씀 (없으면 계획만 출력)")
    p.add_argument("--delete-stale", action="store_true", help="content.json에 없는 문서 삭제")
    a = p.parse_args()

    content = json.loads(Path(a.content).read_text())
    if a.emulator:
        fs = Firestore(f"http://localhost:8080/v1/projects/{PROJECT}/databases/(default)/documents", "owner")
    else:
        fs = Firestore(f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents",
                       sign_in(a.email, web_api_key(a.options)))

    stale = {}
    for c in COLLECTIONS:
        existing = set(fs.ids(c))
        stale[c] = sorted(existing - set(content[c]))
        overwrite = sorted(existing & set(content[c]))
        print(f"{c}: 올릴 문서 {len(content[c])}개 (기존 문서 덮어쓰기 {len(overwrite)}개), "
              f"content.json에 없는 기존 문서 {len(stale[c])}개{': ' + ', '.join(stale[c]) if stale[c] else ''}")

    if not a.apply:
        print("\n계획만 출력했습니다. 실제로 올리려면 --apply 를 붙여 다시 실행하세요.")
        return
    if a.delete_stale and any(stale.values()):
        if input(f"\n위 기존 문서 {sum(map(len, stale.values()))}개를 삭제합니다. 되돌릴 수 없습니다. "
                 "계속하려면 DELETE 입력 (대소문자 무관): ").strip().upper() != "DELETE":
            sys.exit("취소했습니다. 아무것도 바뀌지 않았습니다.")

    now = datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z")
    for c in COLLECTIONS:
        for doc_id, data in content[c].items():
            if c == "exhibitions":
                data = {**data, "created_at": data.get("created_at") or now}
            fs.call("PATCH", f"{c}/{doc_id}", {"fields": {k: encode(v, k) for k, v in data.items()}})
        if a.delete_stale:
            for doc_id in stale[c]:
                fs.call("DELETE", f"{c}/{doc_id}")
    print(f"\n완료: {', '.join(f'{c} {len(content[c])}개' for c in COLLECTIONS)}"
          + (f", 기존 문서 {sum(map(len, stale.values()))}개 삭제" if a.delete_stale else ""))


if __name__ == "__main__":
    main()
