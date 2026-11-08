# 글꼴에 넣을 글자: 영문·라틴, KS X 1001(EUC-KR) 한글·기호(한자 제외), 앱 소스에 쓰인 모든 글자
# 사용법 (fonttools 필요, 원본: github.com/google/fonts ofl/notosanskr/NotoSansKR[wght].ttf):
#   python3 tool/font_subset_chars.py lib | tr ',' '\n' > /tmp/u.txt
#   pyftsubset 'NotoSansKR[wght].ttf' --unicodes-file=/tmp/u.txt --layout-features='*' \
#     --output-file=assets/fonts/NotoSansKR-Subset.ttf
import pathlib, sys
cps = set(range(0x20, 0x7F)) | set(range(0xA0, 0x100)) | {0x20A9, 0x2026, 0x2018, 0x2019, 0x201C, 0x201D, 0x2013, 0x2014}
for c in range(0x80, 0x10000):
    if 0x4E00 <= c <= 0x9FFF or 0xF900 <= c <= 0xFAFF or 0xD800 <= c <= 0xDFFF:
        continue
    try:
        if len(chr(c).encode('euc_kr')) == 2: cps.add(c)  # 8바이트 조합형 확장은 제외
    except UnicodeEncodeError:
        pass
for f in pathlib.Path(sys.argv[1]).rglob('*.dart'):
    cps |= {ord(ch) for ch in f.read_text(encoding='utf-8') if ord(ch) > 0x7F}
print(','.join(f'U+{c:04X}' for c in sorted(cps)))
